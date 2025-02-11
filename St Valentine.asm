;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          lea  bx, A                      ; bx = ptr of array of symbols

                mov  ah, 09h                    ; color of frame
                mov  cx, 40                     ; len   of frame
                mov  dx, 5                      ; high  of frame
                mov  di, 10 * 80 * 2 + 20 * 2   ; start of print

                call MakeFrame                  ; make frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;------------------------------------------------------------------------------
; MakeFrame     Func to make frame
; Entry:        ah     - color of frame
;               bx     - ptr   of array of the symbols for frame
;               cx     - len   of frame
;               dx     - high  of frame
;               di     - start of print (upper left cornel)
; Exit:         None
; Destroy:      ax, bx, cx, dx, di, es
;------------------------------------------------------------------------------
MakeFrame       proc
                push di                         ; save start of print in stack
                call SetEsVideoSeg              ; di = 0b800h; es = di
                pop  di                         ; back start of print

                push cx                         ; save cx in stack
                call MakeStrFrame               ; make first string of frame
                pop  cx                         ; pop cx from stack
                sub  dx, 2                      ; dx -= 2; dx = number
                                                ; of middle strings
                lea  bx, [bx + 3]               ; bx = ptr of start symbol
                                                ; for middle string in array
MakeMiddle:     add  di, 80 * 2                 ; di to next string
                push cx                         ; save cx
                call MakeStrFrame               ; make middle string
                pop  cx                         ; cx = len of frame
                dec  dx                         ; dx--;
                cmp  dx, 0                      ; dx = 0?
                jne  MakeMiddle                 ; loop
                add  di, 80 * 2                 ; di to next string

                lea  bx, [bx + 3]               ; bx = ptr of start symbol
                                                ; for end string in array
                call MakeStrFrame               ; make end string of frame

                ret
MakeFrame       endp

;------------------------------------------------------------------------------
; MakeStrFrame  Func to make string of frame
; Entry:        ah     - color of string
;               bx     - array of symbol for string
;               cx     - len of string
;               di     - start of print string
;               es     - videoseg
; Exit:         None
; Destroy:      ax, cx, si
;------------------------------------------------------------------------------
MakeStrFrame    proc
                push di                         ; save di = start of string
                lea  si, [bx]                   ; si = array of symbols for
                                                ; this string
                lodsb                           ; ax = first symbol of string
                                                ; mov al, ds:[si] && inc si
                stosw                           ; mov es:[di], ax && di += 2

                lodsb                           ; ax = middle symbol of string
                                                ; mov al, ds:[si] && inc si
                sub  cx, 2                      ; cx -= 2; cx = number
                                                ; of middle symbols
                call PutString                  ; put all middle symbols
                lodsb                           ; ax = end symbol of string
                stosw                           ; mov es:[di], ax && di += 2
                pop  di                         ; back di = start of string

                ret
MakeStrFrame    endp

;------------------------------------------------------------------------------
; PutString     Func to put string to consol
; Entry:        ah/ al - color/ symbol
;               cx     - size of text
;               di     - start of print
;               es     - videoseg
; Exit:         None
; Destroy:      es, cx, di
;------------------------------------------------------------------------------
PutString       proc
                rep stosw                       ; mov es:[di], ax && di += 2
                                                ; cx -= 1; cx = 0?; goto NewChar
                ret
PutString       endp

;------------------------------------------------------------------------------
; SetEsVideoSeg Func to set ptr of videoseg to es
; Entry:        None
; Exit:         None
; Destroy:      es, di
;------------------------------------------------------------------------------
SetEsVideoSeg   proc
                mov  di, 0b800h                 ; VIDEOSEG
                mov  es, di                     ; es = videoseg
                ret
SetEsVideoSeg   endp

A db 0c9h, 0cdh, 0bbh, 0bah, 00h, 0bah, 0c8h, 0cdh, 0bch
                                                ; array of frame's symbols

end             Start
;------------------------------------------------------------------------------
