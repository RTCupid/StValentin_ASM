;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          mov  al, 03h                    ; first  symbol of string
                mov  ah, 0001001b               ; color of first  symbol
                mov  bl, '-'                    ; middle symbol of string
                mov  bh, 0001001b               ; color of middle symbol
                mov  dl, 03h                    ; end    symbol of string
                mov  dh, 0001001b               ; color of end    symbol
                mov  cx, 40                     ; size of string
                mov  di, 10 * 80 * 2 + 20 * 2   ; di = start of print
                call MakeStrFrame               ; make string of frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;------------------------------------------------------------------------------
; MakeFrame      Func to make frame
; Entry:
; Exit:
; Destroy:
;------------------------------------------------------------------------------
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
; Destroy:      di, es, cx
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
