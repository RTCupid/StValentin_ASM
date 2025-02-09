;-------------------------------------------------------------------------
;                       Asm Task to Valentine's day
;                         (c) 2025 Muratov Artyom
;-------------------------------------------------------------------------
.model tiny
.code
org 100h
Start:          mov  al, 'A'                    ; symbol
                mov  ah, 0001010b               ; color
                mov  cx, 10                     ; size of string
                call PutString

                mov  ax, 4c00h                  ; DOS Fn 4ch = exit (al)
                int  21h
;-------------------------------------------------------------------------
; Func to put string to consol
; Entry:   al/ ah - symbol/ color
;          cx     - size of text
; Exit:    None
; Destroy: di, es, cx, ax
;-------------------------------------------------------------------------
PutString       proc
                mov  di, 0b800h                 ; VIDEOSEG
                mov  es, di                     ; es = videoseg
                mov  di, 10 * 80 * 2 + 30 * 2   ; di = start of print
NewChar:        stosw                           ; mov es:[di], ax && di += 2
                loop   NewChar                  ; cx -= 1; cx = 0?; goto NewChar
                ret
PutString       endp

end             Start
;-------------------------------------------------------------------------

