DOSSEG
.MODEL SMALL
.STACK 200h
.DATA
.CODE
    mov ax,@DATA
    mov ds,ax
	mov cx, 32000

again:
	mov si, 2				; si = 2
	dec cx
	
primeTstStart:
	cmp si, cx 				; while cx > si
	jge primeTstEnd			
	mov ax, cx		
	xor dx, dx				
	div si
	cmp dx, 0 				; if cx % si == 0 then stop testing current number
	je primeTstEnd
	inc si					; si++
	jmp primeTstStart
primeTstEnd:
	
	loop again				; if cx > 0

    mov ah,4ch				; End of show
    int 21h
END


