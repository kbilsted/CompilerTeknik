; udskriver kun 1 tegn af gangen!
; test!
;
DOSSEG
.MODEL SMALL
.STACK 200h

.DATA
HOBSIZE	dw	100h          	; constant for hobs max size
hobptr 	dw 	0             	; current size = 0
hob    	dw 	100h dup(0)	; allocate hob 

; error messages


.CODE
JMP start




SystemExit:
    mov ah,4ch
    int 21h
    

start: 
	mov 	ax,@data		; init
	mov 	ds,ax
	
	mov ax, 2 ; udskriv 2 på skærmen
	add ax,30h
	mov ah,9
	mov bl,7
	mov bh,0
	mov cx, 2
	int 10h

	mov ax, 3 ; udskriv 2 på skærmen
	add ax,30h
	mov ah,9h
	mov bl,7h
	mov bh,0h
	mov cx, 1h
	int 10h

    jmp 	SystemExit

END



