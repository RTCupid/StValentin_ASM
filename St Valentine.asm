;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          mov  al, 03h                    ; start  symbol of first string
                mov  ah, 0001001b               ; color of start  symbol
                mov  bl, '-'                    ; middle symbol of first string
                mov  bh, 0001001b               ; color of middle symbol
                mov  dl, 03h                    ; end    symbol of first string
                mov  dh, 0001001b               ; color of end    symbol
                mov  cx, 40                     ; cx - len  of frame
                mov  si, 5                      ; si - high of frame
                mov  di, 10 * 80 * 2 + 20 * 2   ; di - ptr of upper left corner
                mov  bp, sp                     ; bp - up of stack
                push bp                         ; save bp
                call MakeFrame                  ; make frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;------------------------------------------------------------------------------
; MakeFrame     Func to make frame
; Entry:        ax     - start  symbol of first frame's string
;               bx     - middle symbol of first frame's string
;               dx     - end    symbol of first frame's string
;               cx     - len  of frame
;               si     - high of frame
;               di     - ptr  of upper left corner of the frame
;               bp     - up   of stack
; Exit:         None
; Destroy:      ax, bx, cx, dx, di, si
;------------------------------------------------------------------------------
MakeFrame       proc
                push bp
                push cx                         ; save cx in stack
                call MakeStrFrame               ; make first string of frame
                pop  cx                         ; pop cx from stack
                sub  si, 2                      ; si -= 2; si - number
                                                ; of middle strings
MakeMiddle:     add  di, 80                     ; di to next string
                push cx                         ; save cx
                call MakeStrFrame               ; make middle string
                pop  cx                         ; cx = saved value of cx
                                                ; cx - len of frame
                dec  si                         ; si--;
                cmp  si, 0                      ; si = 0?
                jne  MakeMiddle                 ; loop
                add  di, 80                     ; di to next string
                call MakeStrFrame               ; make end string of frame
                pop bp                          ; bp from stack
                mov sp, bp                      ; sp = bp
                add sp, 2 * 6                   ; clear stack

                ret
MakeFrame       endp

;------------------------------------------------------------------------------
; MakeStrFrame  Func to make string of frame
; Entry:        cx     - len of string
;               ax     - first symbol of string (color - ah)
;               bx     - middle symbol of string (color - ah)
;               dx     - end   symbol of string (color - ah)
;               di     - start of print
; Exit:         None
; Destroy:      di, es, ax, cx
;------------------------------------------------------------------------------
MakeStrFrame    proc
                push di                         ; ptr of start of print
                                                ; pushed to stack
                call SetEsVideoSeg              ; di = 0b800h; es = di
                pop  di                         ; ptr of start of print
                                                ; popped from stack
                stosw                           ; mov es:[di], ax && di += 2
                mov  ax, bx                     ; ax = middle symbol of string
                sub  cx, 2                      ; cx -= 2; cx = number
                                                ; of middle symbols
                call PutString                  ; put all middle symbols
                mov  ax, dx                     ; ax = end symbol of string
                stosw                           ; mov es:[di], ax && di += 2

                ret
MakeStrFrame    endp

;------------------------------------------------------------------------------
; PutString     Func to put string to consol
; Entry:        ah/ al - color/ symbol
;               cx     - size of text
;               di     - start of print
; Exit:         None
; Destroy:      es, cx
;------------------------------------------------------------------------------
PutString       proc
                push di                         ; ptr of start of print
                                                ; pushed to stack
                call SetEsVideoSeg              ; di = 0b800h; es = di
                pop di                          ; ptr of start of print
                                                ; popped from stack
NewChar:        stosw                           ; mov es:[di], ax && di += 2
                loop   NewChar                  ; cx -= 1; cx = 0?; goto NewChar
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

end             Start
;------------------------------------------------------------------------------
