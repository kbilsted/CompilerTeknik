TITLE STACK TEST


DOSSEG
.MODEL SMALL
.STACK 200h

.DATA

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

a PROC
	mov ax, sp
	mov dx, ax ; print
	mov ah, 2h ; skriv til skærm	
    int 21h

ret
ENDP

MAIN: call Init

	mov ax, sp
	mov dx, ax ; print
	mov ah, 2h ; skriv til skærm	
    int 21h

	call a

	mov ax, sp
	mov dx, ax ; print
	mov ah, 2h ; skriv til skærm	
    int 21h

	mov ax, '.'
	mov dx, ax ; print
	mov ah, 2h ; skriv til skærm	
    int 21h
	
    call SystemExit
END
