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
                sub  di, cx                     ; di = ((80 - cx) / 2) * 2
                add  di, 11 * 80 * 2            ; di to some middle string
                                                ; di = start of text
                ret
FindPosText     endp

;------------------------------------------------------------------------------
; StrLen        Func to find len of string that end '$'
; Entry:        bx = start of text
; Exit:         cx = len of text
; Destroy:      cx, si
;------------------------------------------------------------------------------
StrLen          proc
                push ax                         ; save old value of ax in stack
                mov  si, bx                     ; si = bx
                xor  cx, cx                     ; cx = 0

NewSymbol:      inc  cx                         ; cx++
                lodsb                           ; mov al, ds:[si]
                                                ; inc si
                cmp  al, 24h                    ; if (al != '$') {
                jne  NewSymbol                  ; goto NewSymbol}
                pop  ax                         ; back ax from stack
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
                sub  ax, cx                     ; ax = (80 - cx) / 2) * 2
                add  di, ax                     ; di = start of string
                mov  ax, 25                     ; ax = 25 (ax = high of screen)
                sub  ax, dx                     ; ax = 25 - dx
                div  Two                        ; ax = (25 - dx)/2
                                                ; (ax = number of first string
                                                ; in screen)
                mul  StringScreen               ; ax = ((25 - dx)/2) * 80 * 2
                                                ; (ax = ptr of first string
                                                ; in screen)
                add  di, ax                     ; di = ptr of upper left cornel
                                                ; of frame
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
                lodsb                           ; mov al, ds:[si] && inc si
                sub  al, 30h                    ; al -= 30h, to get a number
                                                ; from hex of char
                cmp  al, 8                      ; if (mode = 8) {
                jne  NotMode8                   ; goto Mode8}
                lea  si, M8                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode8:       cmp  al, 7                      ; if (mode = 7) {
                jne  NotMode7                   ; goto Mode7}
                lea  si, M7                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode7:       cmp  al, 6                      ; if (mode = 6) {
                jne  NotMode6                   ; goto Mode6}
                lea  si, M6                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode6:       cmp  al, 5                      ; if (mode = 5) {
                jne  NotMode5                   ; goto Mode5}
                lea  si, M5                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode5:       cmp  al, 4                      ; if (mode = 4) {
                jne  NotMode4                   ; goto Mode4}
                lea  si, M4                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode4:       cmp  al, 3                      ; if (mode = 3) {
                jne  NotMode3                   ; goto Mode3}
                lea  si, M3                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode3:       cmp  al, 2                      ; if (mode = 2) {
                jne  NotMode2                   ; goto Mode2}
                lea  si, M2                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

NotMode2:       lea  si, M1                     ; si = ptr to mode 8 array
                jmp  EndFindMode                ; end of find mode

EndFindMode:    add  bx, 1                      ; bx = next symbol
                                                ; after number of mode
                ret
Modeframe       endp

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
                push ax                         ; save ax
                mov  ax, cx                     ; ax = cx
                mul  M                          ; ax*= 16
                mov  cx, ax                     ; cx = ax (result: cx *= 16)
                pop  ax                          ; back ax from stack
                                                ; ax = last digit of number
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
                mov  cx, 0                      ; cx = 0
                mov  si, bx                     ; si = start of number
                                                ; in cmd line
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

;------------------------------------------------------------------------------
;                   Variables
Two          db 2                                          ; Two          = 2
StringScreen db 80 * 2                                     ; StringScreen = 80 * 2
M            db 16                                         ; M            = 16
N            db 10                                         ; N            = 10
;------------------------------------------------------------------------------
;             Arrays of frame's symbols
;№     1.1   1.2   1.3   2.1   2.2   2.3   3.1   3.2   3.3
;---------------------------------------------------------------
M8  db 0c9h, 0cdh, 0bbh, 0bah,  00h, 0bah, 0c8h, 0cdh, 0bch
;---------------------------------------------------------------
M7  db  03h,  03h,  03h,  03h,  00h,  03h,  03h,  03h,  03h
;---------------------------------------------------------------
M6  db 0dah, 0c4h, 0bfh, 0b3h,  00h, 0b3h, 0c0h, 0c4h, 0d9h
;---------------------------------------------------------------
M5  db "123456789"
;---------------------------------------------------------------
M4  db 0dch, 0dch, 0dch, 0ddh,  00h, 0deh, 0dfh, 0dfh, 0dfh
;---------------------------------------------------------------
M3  db 024h, 024h, 024h, 024h,  00h, 024h, 024h, 024h, 024h
;---------------------------------------------------------------
M2  db 0e0h, 0e1h, 0e7h, 0e1h, 0e0h, 0e7h, 0e7h, 0e1h, 0e0h
;---------------------------------------------------------------
M1  db 0f4h, 02bh, 0f4h, 0b3h,  00h, 0b3h, 0f5h, 02bh, 0f5h

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
