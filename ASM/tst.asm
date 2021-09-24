TITLE TEST.ASM

DOSSEG
.MODEL SMALL
.STACK 200h



.DATA
Txt		 db 'Tast to 1-cifrede tal:','$'
TxtOutCh db 00,'$'; 0-termineret char
strIn	 db 0; variabel til læsning af 1 tegn
strAdr   db 0; pointer til in- og out-put
result   db 0; variabel til result


.CODE
JMP Start

Init PROC
     mov ax,@DATA
     mov ds,ax
     ret
Init ENDP




; Udskriver værdi af strAdr
SystemOutPrint PROC
	mov dl, strAdr	; flyt det der skal skrives ud
	mov dh, 0
	mov ah, 9h				; skriv til skærm	
    int 21h
    ret
SystemOutPrint ENDP


;
; denne proc er ikke testet!!
SystemOutPrintTegn PROC
	mov dl, strAdr	; flyt det der skal skrives ud
	mov dh, 0
	mov ah, 2h		; skriv til skærm	
    int 21h
    ret
SystemOutPrintTegn ENDP


SystemInRead PROC
	mov ah, 1h
	int 21h
	mov strIn, al
	ret
SystemInRead ENDP
	
SystemExit PROC
    mov ah,4ch
    int 21h
    ret
SystemExit ENDP



Start: call Init

       mov strAdr, offset Txt; klargør udskrivning
       call SystemOutPrint	 ; udskriv
       
       ; hent første tal i bx
       call SystemInRead;
       sub strIn, 48		; dvs. konverter ASCII # til #
       mov bl, strIn
       

       mov TxtOutCh , '+'	; udskriv +
       mov strAdr, offset TxtOutCh 
       call SystemOutPrint
       
       call SystemInRead	; ADD andet tal i bx
       sub strIn, 48		; dvs. konverter ASCII # til #
       add bl, strIn	 
       
       
       add bl, 48			; gem resultatet som ascii i result
       mov result, bl	

       	
       mov TxtOutCh, '='	; udskriv =
       mov strAdr, offset TxtOutCh 
       call SystemOutPrint

       
       ; udskriv resultat
		mov dl, result
		mov dh, 0
		mov ah, 2h				; skriv til skærm	
    	int 21h

       ;mov TxtOutCh[0], result
       ;mov TxtOutCh[1], '$'
       ;mov (TxtOutCh)+, result
       ;mov strAdr, offset result
       ;call SystemOutPrint
      
;       mov strAdr, result
       ;call SystemOutPrint
	   
       call SystemExit
END
