;------------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;------------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          call ReadCmdLine                ; read info about frame
                                                ; from command line
                call FindPosFrame               ; di = start of print frame

                call MakeFrame                  ; make frame

                call StrLen                     ; find size of text
                                                ; cx = size of text
                call FindPosText                ; find position of text
                                                ; di = start of print text
                call MakeText                   ; write text to frame

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h

;------------------------------------------------------------------------------
; MakeText      Func to write text to frame
; Entry:        bx = ptr to strat of text in command line
;               di = start of print text
;               es = videoseg
;               ah = color of text
; Exit:         None
; Destroy:      bx, si, di
;------------------------------------------------------------------------------
MakeText        proc
                mov  si, bx                     ; si = bx
                lodsb                           ; mov al, ds:[si]
                                                ; inc si
NewChar:        stosw                           ; mov es:[di], ax && di += 2
                lodsb                           ; mov al, ds:[si]
                                                ; inc si
                cmp  al, 24h                    ; if (al != '$') {
                jne  NewChar                    ; goto NewChar}

                ret
MakeText        endp

;------------------------------------------------------------------------------
; FindPosText   Func to find position of text in video memory
; Entry:        cx = len of text
; Exit:         di = start of print text
; Destroy:      di
;------------------------------------------------------------------------------
FindPosText     proc
                mov  di, 80                     ; di = 80
                sub  di, cx                     ; di = 80 - cx
                add  di, 12 * 80 * 2            ; di to some middle string
                                                ; di = start of text
                and  di, 0FFFEh                 ; make di even
                ret
FindPosText     endp

;------------------------------------------------------------------------------
; StrLen        Func to find len of string that end '$'
; Entry:        bx = start of text
;               ah = color of text
; Exit:         cx = len of text
; Destroy:      cx, si, di, bx
;------------------------------------------------------------------------------
StrLen          proc
                mov  cx, 7Fh                    ; cx = 7Fh (max len cmd line)
                mov  si, es                     ; save old value es
                mov  di, ds                     ; di = ds
                mov  es, di                     ; es = di
                mov  di, bx                     ; di = bx
                                                ; di = ptr to command line
                mov  al, '$'                    ; al = '$'
                repne scasb                     ; while (es:[di++] != al){cx--;}
                dec  di                         ; di--

                sub  di, bx                     ; di = di - bx
                mov  cx, di                     ; cx = di = len of text

                mov  es, si                     ; es = old value of es

                ret
StrLen          endp

;------------------------------------------------------------------------------
; FindPosFrame  Func to find position of frame in video memory
; Entry:        cx = len   of frame
;               dx = high  of frame
; Exit:         di = start of print frame
; Destroy:      di
;------------------------------------------------------------------------------
FindPosFrame    proc
                xor  di, di                     ; di = 0
                push ax                         ; save ax in stack

                mov  ax, 80                     ; ax = 80 (ax = len of screen)
                sub  ax, cx                     ; ax = 80 - cx
                add  di, ax                     ; di = start in string

                mov  ax, 25                     ; ax  = 25 (ax = high of screen)
                sub  ax, dx                     ; ax  = 25 - dx
                shr  ax, 1                      ; ax /= 2 | ax = number of
                                                ; first string in screen)
                push dx                         ; save dx in stack
                mov  dx, ax                     ; dx  = ax
                shl  dx, 4                      ; dx *= 16
                shl  ax, 6                      ; ax *= 64
                add  ax, dx                     ; (result: ax  = 80 * ax)
                shl  ax, 1                      ; ax *= 2
                                                ; (ax = ptr of first string
                                                ; in screen)
                pop  dx                         ; back dx from stack
                add  di, ax                     ; di = ptr of upper left cornel
                                                ; of frame
                and  di, 0FFFEh                 ; make di even
                pop  ax                         ; back ax from stack
                ret
FindPosFrame    endp

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
                call SkipSpaces                 ; skip all spaces before arg
                                                ; with high of frame
                push cx                         ; save len  of frame
                                                ; (cx) in stack
                call Atoi                       ; read info about high of frame
                                                ; and convert it to number
                                                ; in register cx
                mov  dx, cx                     ; dx      = high of frame
                pop  cx                         ; back cx = len  of frame
                call SkipSpaces                 ; skip all spaces before arg
                                                ; with color of frame
                call Atoih                      ; read info about color
                                                ; of frame from cmd line and
                                                ; record it to byte ah
                call SkipSpaces                 ; skip all spaces before arg
                                                ; with mode of frame
                call ModeFrame                  ; read mode from [bx] &&
                                                ; si = ptr to array of symbols
                                                ; to make frame
                call SkipSpaces                 ; skip all spaces before array
                                                ; with text about love
                                                ; bx = start of text
                ret
ReadCmdLine     endp

;------------------------------------------------------------------------------
; ModeFrame     Func to find mode of frame in cmd line
; Entry:        bx = ptr mode in command line
; Exit:         si = start of array with symbols for frame
;               bx = end of mode
; Destroy:      bx, si, ax
;------------------------------------------------------------------------------
ModeFrame       proc
                mov  si, bx                     ; si = ptr to number of mode
                push ax                         ; save ax in stack

                xor  ax, ax                     ; ax = 0
                lodsb                           ; mov al, ds:[si] && inc si
                sub  al, 30h                    ; al -= 30h, to get a number
                                                ; from hex of char
                                                ; if (al == 0) {
                je   Custom                     ; goto Custom }
                                                ;Style + 9 * (frame_style - 1)
                lea  si, Style                  ; si = start of 2D array Style

                push bx                         ; save bx in stack
                mov  bx, ax                     ; bx = ax
                shl  ax, 3                      ; ax *= 2^3 (ax *= 8)
                add  ax, bx                     ; ax += bx
                sub  ax, 9                      ; (result ax = 9 * (ax - 1))

                add  si, ax                     ; si += ax

                pop  bx                         ; back bx from stack
                add  bx, 1                      ; bx = next symbol
                                                ; after number of mode
                jmp  EndFindMode                ; goto EndFindMode

Custom:         add  bx, 1                      ; bx = ptr symbol after mode
                call SkipSpaces                 ; bx = start of symbols
                                                ; for array in cmd line
                mov  si, bx                     ; si = bx

                push si                         ; save si = ptr frame's symbols
                push cx                         ; save cx = len of frame
                call SkipText                   ; bx = ptr next symbol after
                                                ; array of frame's symbols
                pop  cx                         ; back cx from stack
                pop  si                         ; back si from stack
EndFindMode:    pop  ax                         ; back ax from stack
                ret
Modeframe       endp

;------------------------------------------------------------------------------
; SkipText      func to skip text
; Entry:        bx = ptr to start of text for skipping
;               ds = segment with code
;               es = video segment
; Exit:         bx = ptr to symbol after skipping text
; Destroy:      bx, al, di, cx, si
;------------------------------------------------------------------------------
SkipText        proc
                mov  cx, 7Fh                    ; cx = 7Fh (max len cmd line)
                mov  si, es                     ; save old value es
                mov  di, ds                     ; di = ds
                mov  es, di                     ; es = di
                mov  di, bx                     ; di = bx
                                                ; di = ptr to command line
                mov  al, '$'                    ; al = '$'
                repne scasb                     ; while (es:[di++] != al){cx--;}

                mov  bx, di                     ; bx = di
                mov  es, si                     ; es = old value of es

                ret
SkipText        endp

;------------------------------------------------------------------------------
; Atoih         Func to read command line and make number hex from string
;               to register ah
; Entry:        bx = start a number in command line
; Exit:         ah = hex number from cmd line
;               bx = ptr to next symbol after number in command line
; Destroy:      bx, ax, si
;------------------------------------------------------------------------------
Atoih           proc
                push cx                         ; save cx in stack
                mov  cx, 0                      ; cx = 0
                mov  si, bx                     ; si = start of number
                                                ; in cmd line
NewHexDigit:    xor  ax, ax                     ; mov ax, 0
                lodsb                           ; mov al, ds:[si] && inc si

                sub  ax, 60h                    ; if (ax > 60h){
                ja   HexDigit                   ; goto HexDigit } <---(ax > 9)
                add  ax, 30h                    ; else { ax += 30h}
HexDigit:                                       ; ax = last digit of number
                shl  cx, 4                      ; cx *= 2^4 (cx *= 16)
                add  cx, ax                     ; cx += ax
                cmp  byte ptr ds:[si], 68h      ; if (si == 'h'){
                jne  NewHexDigit                ; goto NewHexDigit: of number }

                inc  si                         ; si++, to skip 'h'
                xor  ax, ax                     ; clean ax (ax = 0)
                mov  ah, cl                     ; ah = color of frame from cl
                mov  bx, si                     ; bx = ptr of next symbol
                                                ; after number in cmd line
                pop  cx                         ; cx = old value cx from stack

                ret
Atoih           endp

;------------------------------------------------------------------------------
; Atoi          Func to read command line and make number from string
;               to register cx
; Entry:        bx = start a number in command line
; Exit:         cx = number from cmd line
;               bx = ptr to next symbol after number in command line
; Destroy:      bx, cx, si
;------------------------------------------------------------------------------
Atoi            proc
                xor  cx, cx                     ; cx = 0
                mov  si, bx                     ; si = start of number
                                                ; in cmd line
NewDigit:
                mov  ax, cx                     ; ax = cx
                shl  cx, 3                      ; cx *= 2^3 (cx *= 8)
                add  cx, ax                     ;
                add  cx, ax                     ; (result: cx *= 10)
                xor  ax, ax
                lodsb                           ; mov al, ds:[si] && inc si
                sub  ax, 30h                    ; ax = last digit of number
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
; Entry:        bx = start ptr
;               ds = segment with code
;               es = video segment
;               di = upper left cornel of frame or start of print text
;               cx = len of frame
;               si = start array of frame's symbols
; Exit:         bx = ptr to start info about frame
; Destroy:      bx, al, di, cx, si
;------------------------------------------------------------------------------
SkipSpaces      proc
StartSkip:
                push cx                         ; save cx
                push di                         ; save di
                push si                         ; save si
                mov  cx, 7Fh                    ; cx = 7Fh (max len cmd line)
                mov  si, es                     ; save old value es
                mov  di, ds                     ; di = ds
                mov  es, di                     ; es = di
                mov  di, bx                     ; di = bx
                                                ; di = ptr to command line
                mov  al, ' '                    ; al = ' '
                repe scasb                      ; while (es:[di++] != al){cx--;}
                dec  di                         ; di--
                                                ; di = first information symbol
                mov  bx, di                     ; bx = di
                mov  es, si                     ; es = old value of es

                pop  si                         ; back si
                pop  di                         ; back di
                pop  cx                         ; back cx

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
                rep stosw                       ; mov es:[di], ax && di += 2
                                                ; cx -= 1; cx = 0?; make loop
                                                ; put all middle symbols
                lodsb                           ; ax = end symbol of string
                                                ; mov al, ds:[si] && inc si
                stosw                           ; mov es:[di], ax && di += 2
                pop  di                         ; back di = start of string

                ret
MakeStrFrame    endp

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

;------------------------------------------------------------------------------
;             2D Array of frame's symbols
;№      1.1   1.2   1.3   2.1   2.2   2.3   3.1   3.2   3.3
;1--------------------------------------------------------------
Style db 0c9h, 0cdh, 0bbh, 0bah,  00h, 0bah, 0c8h, 0cdh, 0bch
      db 03h,  03h,  03h,  03h,  00h,  03h,  03h,  03h,  03h
      db 0dah, 0c4h, 0bfh, 0b3h,  00h, 0b3h, 0c0h, 0c4h, 0d9h
      db "123456789"
      db 0dch, 0dch, 0dch, 0ddh,  00h, 0deh, 0dfh, 0dfh, 0dfh
      db 024h, 024h, 024h, 024h,  00h, 024h, 024h, 024h, 024h
      db 0e0h, 0e1h, 0e7h, 0e1h, 0e0h, 0e7h, 0e7h, 0e1h, 0e0h
      db 0f4h, 02bh, 0f4h, 0b3h,  00h, 0b3h, 0f5h, 02bh, 0f5h

; 1.1 - start  symbol of first  string
; 1.2 - middle symbol of first  string
; 1.3 - end    symbol of first  string
; 2.1 - start  symbol of middle strings
; 2.2 - middle symbol of middle strings
; 2.3 - end    symbol of middle strings
; 3.1 - start  symbol of end    string
; 3.2 - middle symbol of end    string
; 3.3 - end    symbol of end    string
;------------------------------------------------------------------------------

end             Start
;------------------------------------------------------------------------------
