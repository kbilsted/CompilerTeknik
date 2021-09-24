;
; Udskriver ascii tegnene 0-256
TITLE 256.ASM


DOSSEG
.MODEL SMALL
.STACK 200h



.DATA
chr db 00,'$'


.CODE
JMP MAIN

Init PROC
     mov ax,@DATA
     mov ds,ax
     ret
Init ENDP





SystemExit PROC
    mov ah,4ch
    int 21h
    ret
SystemExit ENDP



MAIN: call Init
	mov cx, 256; cx initialiseres til 256
	lea dx, chr; dx load'es med offset af chr værdi

again:
	mov ah, 9	; display ASCII
	int 21h
	inc chr
	loop again 	; decr cx, loop if nonzero
	   
    call SystemExit
END
