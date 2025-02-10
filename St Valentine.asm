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
                mov  cx, 40                     ; len   of frame
                mov  cx, 5                      ; high  of frame
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
; Destroy:      ax, bx, cx, dx, si, di, es
;------------------------------------------------------------------------------
MakeFrame       proc
                push di                         ; save start of print in stack
                call SetEsVideoSeg              ; di = 0b800h; es = di
                pop  di                         ; back start of print
                B db 3 dup(?)                   ; B - array of symbols
                                                ; for string of frame
                lea  si, B                      ; si = B
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
                pop  cx                         ; cx = len of frame
                push cx                         ; save cx in stack
                call MakeStrFrame               ; make first string of frame
                pop  cx                         ; pop cx from stack
                sub  dx, 2                      ; dx -= 2; dx - number
                                                ; of middle strings
                push cx                         ; save cx in stack
                mov  cx, 3                      ; start index of elems B
                mov  [si][cx], [bx][cx]         ; start  symbol of middle string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; middle symbol of middle string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; end    symbol of middle string
                                                ; to array B
                pop  cx                         ; cx = len of frame

MakeMiddle:     add  di, 80                     ; di to next string
                push cx                         ; save cx
                call MakeStrFrame               ; make middle string
                pop  cx                         ; cx = saved value of cx
                                                ; cx - len of frame
                dec  dx                         ; dx--;
                cmp  dx, 0                      ; dx = 0?
                jne  MakeMiddle                 ; loop
                add  di, 80                     ; di to next string
                push cx                         ; save cx in stack
                mov  cx, 6                      ; start index of elems B
                mov  [si][cx], [bx][cx]         ; start  symbol of end string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; middle symbol of end string
                                                ; to array B
                inc  cx                         ; cx++
                mov  [si][cx], [bx][cx]         ; end    symbol of end string
                                                ; to array B
                pop  cx                         ; cx = len of frame
                call MakeStrFrame               ; make end string of frame

                ret
MakeFrame       endp

;------------------------------------------------------------------------------
; MakeStrFrame  Func to make string of frame
; Entry:        ah     - color of string
;               cx     - len of string
;               si     - array of symbol for string
;               di     - start of print
;               es     - videoseg
; Exit:         None
; Destroy:      ax, cx, si
;------------------------------------------------------------------------------
MakeStrFrame    proc
                push di
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
                pop  di

                ret
MakeStrFrame    endp

;------------------------------------------------------------------------------
; PutString     Func to put string to consol
; Entry:        ah/ al - color/ symbol
;               cx     - size of text
;               di     - start of print
;               es     - videoseg
; Exit:         None
; Destroy:      es, cx
;------------------------------------------------------------------------------
PutString       proc
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
