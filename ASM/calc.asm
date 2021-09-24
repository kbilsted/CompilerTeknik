; nu anvendes dw istedet for db hvorved større tal kan anvendes'
TITLE calc.ASM

DOSSEG
.MODEL SMALL
.STACK 200h



.DATA
Txt		 db 'Tast to 1-cifrede tal:','$'
TxtOutCh dw 00,'$'; 0-termineret char
strIn	 dw 0; variabel til læsning af 1 tegn
strAdr   dw 0; pointer til in- og out-put
result   dw 0; variabel til result


.CODE
JMP Start

Init PROC
     mov ax,@DATA
     mov ds,ax
     ret
Init ENDP




; Udskriver værdi af strAdr
SystemOutPrint PROC
	mov dx, strAdr	; flyt det der skal skrives ud
	mov ah, 9h				; skriv til skærm	
    int 21h
    ret
SystemOutPrint ENDP

;;;; ENDNU IKKE TESTET
SystemOutPrintTegn PROC
	mov dx, strAdr	; flyt det der skal skrives ud
	mov ah, 2h		; skriv til skærm	
    int 21h
    ret
SystemOutPrintTegn ENDP


SystemInRead PROC
	mov ah, 1h
	int 21h
	mov strIn, ax
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
       mov bx, strIn
       

       mov TxtOutCh , '+'	; udskriv +
       mov strAdr, offset TxtOutCh 
       call SystemOutPrint
       
       call SystemInRead	; ADD andet tal i bx
       sub strIn, 48		; dvs. konverter ASCII # til #
       add bx, strIn	 
       
       
       mov TxtOutCh, '='	; udskriv =
       mov strAdr, offset TxtOutCh 
       call SystemOutPrint


       add bx, 48			; gem resultatet som ascii i result
       mov TxtOutCh, bx	
       mov strAdr, offset TxtOutCh 
       call SystemOutPrintTegn

	   
       call SystemExit
END
