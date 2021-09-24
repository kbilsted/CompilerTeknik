DOSSEG
    .MODEL SMALL
    .STACK 100h
    

.DATA
    hobptr  dw 0
    hob     dw 120h dup(0) ; allocate hob
    ; error messages
    oomstr	db	10,13,'Out of memory! Can not allocate another class.','$',0,0
    

.CODE
    jmp START

; ------------ STANDARD FUNCTIONS BEGIN ----------:

new PROC
    mov ax, hobptr     ; get hop size
    push ax            ; save pos. of class in stack
    add  ax, cx	       ; add size of obj
    cmp ax, 120h
    jg OutOfMem        ; if ax < HOBSIZE jump to OutOfMemory
    mov hobptr, ax     ; save hop size
    pop ax             ;   ax = pos. of class in hob
    ret
OutOfMem:
    mov dx, OFFSET oomstr; write out of mem string to screen
    mov ah, 9h
    int 21h
    jmp SystemExit
new ENDP

SystemOutPrint PROC
    mov ah, 2h
    int 21h
    ret
SystemOutPrint ENDP

SystemInRead PROC
    mov ah, 1h ; read with screen echo
    int 21h
    mov ah, 0 ; clear AH as only AL contains userinput
    ret
SystemInRead ENDP

SystemExit PROC
    mov ah, 4ch
    int 21h
    ret
SystemExit ENDP

String_charAt PROC
    mov bp, sp
    sub bp, 2
    mov si, bx        ; pos in hob where obj begins
    mov ax, [bp+4]    ; get (first) argument telling pos to get
    mov dx, 2		  ; ax = ax *2
    mul dx            ; in hob every char takes 2 places
    add si, ax        ; pos in hob to fetch character
    mov ax, hob[si+2] ; +2 as first field contains str_len
    ret
String_charAt ENDP

String_concat PROC
    mov bp, sp
    sub bp, 2
    mov cx, hob[bx] ; size of caller str
    mov si, [bp+4]  ; pos in hob of 2nd str len
    add cx, hob[si] ; add 2nd str len
    add cx, 2	    ; add space for sizefield
    push cx
    call new        ; alloc new String object
    pop cx			; total strsize
    mov si, ax      ; can't just use the AX
    mov hob[si], cx ; set concat'ed String size

    mov cx, hob[bx] ; size of str1
    add bx, 4       ; start in 2nd pos (but why +4 instead of +2 ??)
    mov di, ax      ; destination ptr = adr of new String obj
    add di, 2       ; start in 2nd pos
strcat1:
    mov si, [bx]    ; we can't just use [bx]
    mov hob[di], si
    add bx, 2
    add di, 2
    loop strcat1

    mov si, [bp+4]  ; pos in hob of 2nd str len
    mov cx, hob[si] ; size of 2nd str len
    mov bx, [bp+4]  ; point at start of 2nd string
    add bx, 4       ; start in 2nd pos (but why +4??)
strcat2:
    mov si, [bx]    ; we can't just use [bx]
    mov hob[di], si
    add bx, 2
    add di, 2
    loop strcat2
    ret
String_concat ENDP
    
String_length PROC ; str_len length()
    mov ax, hob[bx] ; first field in string
    ret
String_length ENDP

String_print PROC
    mov cx, hob[bx] ; str size
    mov si, bx   ; source-print ptr
    add si, 2
printloop:
    mov dx, hob[si]
    add si, 2 ; next char
    push cx
    push si
    xor cx, cx          ; zero cx
    call SystemOutPrint ; print dx
    pop si
    pop cx
    loop printloop
    ret
String_print ENDP
; ------------ STANDARD FUNCTIONS END ----------:


START:
    mov ax, @data ; setup DOS program
    mov ds, ax
    ; allocate 'main' function
    mov cx, 10
    call new
    mov bp, sp     ; adjust bp to point at functions local variable
    sub bp, 2      ;
    mov bx, ax    ; store main's 'this' 
    ; execute mains contents
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    ; assign
    ; string - allocate class and return pointer on stack
    mov cx, 12 ; length of 2*str + 2 
    call new
    mov si, ax ; mov (adr of obj in hob) to si
    mov hob[si], 5 ; insert strlength
    mov hob[si+2], 'h'
    mov hob[si+4], 'e'
    mov hob[si+6], 'l'
    mov hob[si+8], 'l'
    mov hob[si+10], 'o'
    push ax
    pop ax ; get value (assign)
    mov [bp-0], ax ; set local variable s1
    ; assign
    ; string - allocate class and return pointer on stack
    mov cx, 32 ; length of 2*str + 2 
    call new
    mov si, ax ; mov (adr of obj in hob) to si
    mov hob[si], 15 ; insert strlength
    mov hob[si+2], ' '
    mov hob[si+4], 'a'
    mov hob[si+6], 's'
    mov hob[si+8], 's'
    mov hob[si+10], 'e'
    mov hob[si+12], 'm'
    mov hob[si+14], 'b'
    mov hob[si+16], 'l'
    mov hob[si+18], 'y'
    mov hob[si+20], ' '
    mov hob[si+22], 'w'
    mov hob[si+24], 'o'
    mov hob[si+26], 'r'
    mov hob[si+28], 'l'
    mov hob[si+30], 'd'
    push ax
    pop ax ; get value (assign)
    mov [bp-2], ax ; set local variable s2
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov bx, [bp-0] ; push callers class' 'this'
    mov ax, [bp-2] ; get local variable s2
    push ax
    call String_concat
    pop cx ; de-stack arguments
    pop bx ; restore this class' 'this'
    pop bp
    push ax ; 'emulated' return value on the stack
    pop ax ; get value (assign)
    mov [bp-4], ax ; set local variable s3
    ; fnccallGen
    push bp
    push bx
    mov bx, [bp-4] ; push callers class' 'this'
    call String_print
    pop bx ; restore this class' 'this'
    pop bp
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov bx, [bp-4] ; push callers class' 'this'
    call String_length
    pop bx ; restore this class' 'this'
    pop bp
    push ax ; 'emulated' return value on the stack
    pop ax ; get value (assign)
    mov [bp-6], ax ; set local variable len
    ; fnccallGen
    mov ax, [bp-6] ; get local variable len
    push ax
    pop cx ; print DX ; System.out.print()
    add cx, 48 ; convert to ASCII
    mov dx, 0 ; clear DX
    mov dl, cl
    mov cx, 0 ; clear CX
    call SystemOutPrint
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov bx, [bp-0] ; push callers class' 'this'
    mov ax, 1
    push ax
    call String_charAt
    pop cx ; de-stack arguments
    pop bx ; restore this class' 'this'
    pop bp
    push ax ; 'emulated' return value on the stack
    pop ax ; get value (assign)
    mov [bp-8], ax ; set local variable c
    ; fnccallGen
    mov ax, [bp-8] ; get local variable c
    push ax
    pop cx ; print DX ; System.out.print()
;;;;;;;;;;;;;;;;;;;;;;;    add cx, 48 ; convert to ASCII
    mov dx, 0 ; clear DX
    mov dl, cl
    mov cx, 0 ; clear CX
    call SystemOutPrint
    jmp SystemExit
END
