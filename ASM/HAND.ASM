; denne source emulerer
; ---------------------
;
; class A 
; {
;	int i, j;
;	void f() 
;	{
;		j = j + 1;
; 	}
;
; 	static void main() 
; 	{
;		A p = new A();
;		p.f();
;		p.f();
; 	}	 
; }
; 
; OBJ SIZE (A = 4 bytes), (MAIN = 2 bytes)


DOSSEG
.MODEL SMALL
.STACK 100h

.DATA
HOBSIZE	dw	40h          	; constant for hobs max size
hobptr 	dw 	0             	; current size = 0
hob    	dw 	40h dup(0)		; allocate hob 

; error messages
oomstr	db	10,13,'Out of memory! Can not allocate another class.','$',0,0
exitstr	db	' Exiting...','$',0,0
prstr	db	' Printing..','$',0,0
allocstr db ' alloc()','$',0,0

.CODE
JMP start

; ---------------------   START STD FUNCTIONS   -------------------------
; allocate a new object
; AX::adrOfObj NEW(CX::sizeOfObj)		 
new PROC 
	mov  	ax, hobptr  	; get hop size
	push 	ax          	; save pos. of class in stack
	add  	ax, cx			; add size of obj
	mov		dx, HOBSIZE;
	cmp  	ax, dx 
	jg   	OutOfMem 		; if ax < HOBSIZE jump to OutOfMemory
	mov  	hobptr, ax  	; save hop size
	pop	 	ax				; ax = pos. of class in hob
	ret
new ENDP



; Exit with error msg
; void OutOfMem()
OutOfMem: 
	mov 	dx, OFFSET oomstr; write out of mem string to screen
	mov 	ah, 9h
	int 	21h
	jmp 	SystemExit


SystemExit:
    mov ah,4ch
    int 21h
    
; ---------------------   END STD FUNCTIONS   -------------------------



; ---------------------   START PRG FUNCTIONS   -------------------------
A_f PROC
	push	bp			; save old ref to stack (only do this if we have local variables or parameters)
	mov		bp, sp		; 
	push    hob[bx+2]	; push all local variable j
	push    hob[bx]		; push all local variable i
	
        mov             dx, [bp-2]      ; get j
        add dx,30h
        mov ah, 2h
        int 21h

	mov		ax, [bp-2]	; get j
	push 	ax			; j
	push	1			
	pop		ax
	pop		dx
	add		ax, dx		; j + 1	
	push 	ax
	pop		ax
        mov             [bp-2], ax      ; j's value is set

        mov             dx, [bp-2]      ; get j
        add dx,30h
        mov ah, 2h
        int 21h

	; de-stack
	pop	 	hob[bx]		; set i
	pop		hob[bx+2]	; set j
	
	pop		bp			; restore ref to stack
        ret
A_f ENDP
; ---------------------   END PRG FUNCTIONS   -------------------------



start: 
	mov 	ax,@data		; init
	mov 	ds,ax


	; allocate 'main' function
	mov		cx, 2			; size of main == 2
	call	new
	mov 	bp, sp			; pointer to local variable in main (on the stack)
	mov		bx, ax			; store main's "this" 
	push 	0				; create all the local variables (in this case only p
	
	; execute mains contents
	mov		cx, 4			; new A()
	call	new				;
	mov 	[bp-2], ax		; p = adress of A()
    
    						; p.f()
	push	bx				; save "this" for main
	mov		bx, [bp-2]		; "this" for A() in bx
	call 	A_f				; do function f
	pop		bx				; restore our "this" for main
    
    						; p.f()
	push	bx				; save "this" for main
	mov		bx, [bp-2]		; "this" for A() in bx
	call 	A_f				; do function f
	pop		bx				; restore our "this" for main

    jmp 	SystemExit

END



