;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          call ReadCmdLine                ; read info about frame
                                                ; from command line
                lea  si, A                      ; si = ptr of array of symbols

                mov  ah, 09h                    ; color of frame
                ;mov  cx, 40                     ; len   of frame
                mov  dx, 5                      ; high  of frame
                mov  di, 10 * 80 * 2 + 20 * 2   ; start of print

                call MakeFrame                  ; make frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;------------------------------------------------------------------------------
; ReadCmdLine   Func to read info about frame parametres
; Entry:        None
; Exit:         si = ptr   of array of symbols
;               ah = color of frame
;               cx = len   of frame
;               dx = high  of frame
;               bx = love letter
; Destroy:      si, ah, cx, dx, bx
;------------------------------------------------------------------------------
ReadCmdLine     proc
                mov  bx, 81h                    ; bx = start of command line
                call SkipSpaces                 ; skip all spaces before arg
                                                ; with len of frame
                call Atoi                       ; read info about len of frame
                                                ; and convert it to number
                                                ; in register cx
                ;call SkipSpaces                 ; skip all spaces before arg
                                                ; with high of frame
                ;push cx                         ; save len  of frame
                                                ; (cx) in stack
                ;call Atoi                       ; read info about high of frame
                                                ; and convert it to number
                                                ; in register cx
                ;mov  dx, cx                     ; dx      = high of frame
                ;pop  cx                         ; back cx = len  of frame
                ;call SkipSpaces                 ; skip all spaces before arg
                                                ; with color of frame
                ;call Atoih                      ; read info about color
                                                ; of frame from cmd line and
                                                ; record it to byte ah
                ;call SkipSpaces                 ; skip all spaces before arg
                                                ; with mode of frame
                ;call FindMode                   ; read mode from [bx] &&
                                                ; si = ptr to array of symbols
                                                ; to make frame
                ;call SkipSpaces                 ; skip all spaces before array
                                                ; with text about love
                                                ; bx = start of text
                ret
ReadCmdLine     endp

;------------------------------------------------------------------------------
; Atoi          Func to read command line and make number from string
;               to register cx
; Entry:        bx = start a number in command line
; Exit:         cx = number from cmd line
; Destroy:      bx, cx, si, dx
;------------------------------------------------------------------------------
Atoi            proc
                mov  cx, 0                      ; cx = 0
                mov  si, bx                     ; si = start of number
                                                ; in cmd line
                N db 10                         ; N = 10
NewDigit:       xor  ax, ax                     ; mov ax, 0
                lodsb                           ; mov al, ds:[si] && inc si
                sub  ax, 30h                    ; ax = last digit of number
                push ax                         ; save ax
                mov  ax, cx                     ; ax = cx
                mul  N                          ; ax*= 10
                mov  cx, ax                     ; cx = ax (result: cx *= 10)
                pop ax                          ; back ax from stack
                                                ; ax = last digit of number
                add  cx, ax                     ; cx += ax
                cmp  byte ptr ds:[si], 20h      ; if (si != ' ')
                jne  NewDigit                   ; goto NewDigit: of number

                mov  bx, si                     ; bx = ptr of next symbol
                                                ; after number in cmd line
                ret
Atoi            endp

;------------------------------------------------------------------------------
; SkipSpaces    Func to skip all space symbols before info about frame
; Entry:        None
; Exit:         bx = ptr to start info about frame
; Destroy:      bx
;------------------------------------------------------------------------------
SkipSpaces      proc
StartSkip:      push bx                         ; save value bx in stack
                                                ; bx = ptr to command line
                mov  byte ptr bl, [bx]          ; bl = [bx]
                cmp  bl, 20h                    ; if ([bx] != ' '){
                pop  bx                         ; back bx
                jne  EndSkip                    ; goto EndSkip:}
                inc  bx                         ; else { bx++;
                jmp  StartSkip                  ; goto StartSkip:}

EndSkip:        ret
SkipSpaces      endp

;------------------------------------------------------------------------------
; MakeFrame     Func to make frame
; Entry:        ah     - color of frame
;               si     - ptr   of array of the symbols for frame
;               cx     - len   of frame
;               dx     - high  of frame
;               di     - start of print (upper left cornel)
; Exit:         None
; Destroy:      ax, si, cx, dx, di, es
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
MakeMiddle:     add  di, 80 * 2                 ; di to next string
                push cx                         ; save cx
                push si                         ; save si
                call MakeStrFrame               ; make middle string
                pop si                          ; si = &(start symbol of
                                                ; middle strings)
                pop  cx                         ; cx = len of frame
                dec  dx                         ; dx--;
                cmp  dx, 0                      ; dx = 0?
                jne  MakeMiddle                 ; loop

                add  si, 3                      ; si = &(start symbol of
                                                ; end string)
                add  di, 80 * 2                 ; di to next string

                call MakeStrFrame               ; make end string of frame

                ret
MakeFrame       endp

;------------------------------------------------------------------------------
; MakeStrFrame  Func to make string of frame
; Entry:        ah     - color of string
;               si     - array of symbol for string
;               cx     - len of string
;               di     - start of print string
;               es     - videoseg
; Exit:         None
; Destroy:      ax, cx, si
;------------------------------------------------------------------------------
MakeStrFrame    proc
                push di                         ; save di = start of string

                lodsb                           ; ax = first symbol of string
                                                ; mov al, ds:[si] && inc si
                stosw                           ; mov es:[di], ax && di += 2

                lodsb                           ; ax = middle symbol of string
                                                ; mov al, ds:[si] && inc si
                sub  cx, 2                      ; cx -= 2; cx = number
                                                ; of middle symbols
                call PutString                  ; put all middle symbols
                lodsb                           ; ax = end symbol of string
                                                ; mov al, ds:[si] && inc si
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
                                                ; cx -= 1; cx = 0?; make loop
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
