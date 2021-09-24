;
; KBG prime
;
; find all primes within 31999
;
; written by KBG (c) 2000 
;
; AX contains number to be tested (from 32000 down to 0)

DOSSEG
.MODEL SMALL
.STACK 200h

.DATA

.CODE

     mov ax,@DATA
     mov ds,ax

	mov cx, 31999
again:
	mov si, 2				; si = 2
primeTsTStart:
	cmp si, cx 				; while cx > si
	je primeTstEnd			;
		
	mov ax, cx		
	xor dx, dx				
	div si
	cmp dx, 0 				; if cx % si == 0 then stop testing current number
	je primeTstEnd:
	inc si					; si++
	jmp primeTstStart
primeTstEnd:
	
	loop again				; if cx > 0

	; END OF SHOW
    mov ah,4ch
    int 21h

END


