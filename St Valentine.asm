;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          A db 9 dup(?)                   ; array of frame's symbols
                lea  bx, A                      ; bx = ptr of array of symbols

                mov  si, 0                      ; si = offset from start array
                mov  [bx][si], 03h              ; start  symbol of first string
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; middle symbol of first string
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; end    symbol of first string
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; start  symbol of middle str
                inc  si                         ; si += 1
                mov  [bx][si], 00h              ; middle symbol of middle str
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; end    symbol of middle str
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; start  symbol of end string
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; middle symbol of end string
                inc  si                         ; si += 1
                mov  [bx][si], 03h              ; end    symbol of end string

                mov  ah, 09h                    ; color of frame
                mov  cx, 20                     ; len   of frame
                mov  cx, 5                      ; high  of frame

                call MakeFrame                  ; make frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;------------------------------------------------------------------------------
; MakeFrame     Func to make frame
; Entry:        ah     - color of frame
;               bx     - ptr   of array of the symbols for frame
;               cx     - len   of frame
;               dx     - high  of frame
; Exit:         None
; Destroy:      ax, bx, cx, dx, si
;------------------------------------------------------------------------------
MakeFrame       proc
                B db 3 dup(?)                   ; B - array of symbols
                                                ; for string of frame
                lea  si, B                       ; si = B
                push cx                         ; save cx in stack
                mov  cx, 0                      ; start index of elems B
                mov  [si][cx], [bx][cx]         ; start  symbol of first string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; middle symbol of first string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; end    symbol of first string
                                                ; to array B
                pop cx                          ; save cx in stack
                call MakeStrFrame               ; make first string of frame
                pop  cx                         ; pop cx from stack
                sub  si, 2                      ; si -= 2; si - number
                                                ; of middle strings
                mov  ax, SS:[bp]                ; ax - start  symbol of
                                                ; middle strings
                mov  bx, SS:[bp + 2]            ; bx - middle symbol of
                                                ; middle strings
                mov  dx, SS:[bp + 4]            ; dx - end    symbol of
                                                ; middle strings
MakeMiddle:     add  di, 80                     ; di to next string
                push cx                         ; save cx
                call MakeStrFrame               ; make middle string
                pop  cx                         ; cx = saved value of cx
                                                ; cx - len of frame
                dec  si                         ; si--;
                cmp  si, 0                      ; si = 0?
                jne  MakeMiddle                 ; loop
                add  di, 80                     ; di to next string
                mov  ax, SS:[bp + 6]            ; ax - start  symbol of
                                                ; end strings
                mov  bx, SS:[bp + 8]            ; bx - middle symbol of
                                                ; end strings
                mov  dx, SS:[bp + 10]           ; dx - end    symbol of
                                                ; end strings
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
