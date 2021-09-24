DOSSEG
.MODEL SMALL
.STACK 200h



.DATA
Tekst    DB 'Hello',13,10,'$'



.CODE
JMP Start

Init PROC
     mov ax,@DATA
     mov ds,ax
     ret
Init ENDP



TekstUd PROC
        mov AH,9
        mov dx,OFFSET Tekst
        int 21h
        ret
TekstUd ENDP



TilDos PROC
       mov ah,4ch
       int 21h
       ret
TilDos ENDP



Start: call Init


       call TekstUd
       call TilDos
       END
