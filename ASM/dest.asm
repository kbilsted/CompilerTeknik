DOSSEG
    .MODEL SMALL
    .STACK 100h
    

.DATA
    hobptr  dw 0
    hob     dw 150h dup(0) ; allocate hob
    ; error messages
    oomstr	db	10,13,'Out of memory! Can not allocate another class.','$',0,0
    

.CODE
    jmp  START

; ------------ STANDARD FUNCTIONS BEGIN ----------:

new PROC
    mov  ax, hobptr     ; get hop size
    push ax            ; save pos. of class in stack
    add  ax, cx	       ; add size of obj
    cmp  ax, 150h
    jg   OutOfMem        ; if ax < HOBSIZE jump to OutOfMemory
    mov  hobptr, ax     ; save hop size
    pop  ax             ;   ax = pos. of class in hob
    ret
OutOfMem:
    mov  dx, OFFSET oomstr; write out of mem string to screen
    mov  ah, 9h
    int  21h
    jmp  SystemExit
new  ENDP

SystemOutPrint PROC
    mov  bp, sp
    sub  bp, 2
    mov  bx, [bp+4]     ; get adr of str obj
    mov  cx, hob[bx]    ; strlen
    mov  si, bx         ; source-print ptr
    add  si, 2          ; get past length field
printloop:
    mov  dx, hob[si]
    add  si, 2          ; next char
    mov  ah, 2h         ; print char
    int  21h
    loop printloop
    ret
SystemOutPrint ENDP

SystemInRead PROC
    mov  ah, 1h ; read with screen echo
    int  21h
    mov  ah, 0 ; clear AH as only AL contains userinput
    ret
SystemInRead ENDP

SystemExit PROC
    mov  ah, 4ch
    int  21h
    ret
SystemExit ENDP

toString PROC
    mov  bp, sp
    sub  bp, 2
    mov  ax, [bp+4]    ; get number (first argument)
    xor  cx, cx ; cx counts size of str
    xor  di, di ; carry if negative no
    cmp  ax, 0 ; is negative?
    jge  nonneg
    inc  di  ; di == 1 == no is negative
    inc  cx
    neg  ax    ; make the number positive
nonneg:
    mov  si, 10 ; div with reg SI as many times as possible
    cmp  ax, 0 ; is zero?
    jg   getDigits
    push '0'
    inc  cx
    jmp  toStr ; make a str
getDigits:
    xor  dx, dx
    div  si
    add  dx, 48 ; conv digit to ASCII
    push dx
    inc  cx
    cmp  ax, 0  ; are we done?
    jg   getDigits

    push cx     ; store cx
    shl  cx, 1  ; calc str size = (2*strlen)+2
    add  cx, 2
    call new    ; alloc new str
    pop  cx     ; get original strlen
    mov  si, ax ; ptr to str in hob
    mov  hob[si], cx ; store size of str
    cmp  di, 0  ; is no negative?
    je   toStr
    add  si, 2        ; next pos
    mov  hob[si], '-' ; write '-' sign
    dec  cx
toStr:
    add  si, 2       ; next pos
    pop  dx           ; get digit
    mov  hob[si], dx ; store size of str
    loop toStr
    ret
toString ENDP

String_charAt PROC
    mov  bp, sp
    sub  bp, 2
    mov  si, bx        ; pos in hob where obj begins
    mov  ax, [bp+4]    ; get (first) argument telling pos to get
    shl  ax, 1         ; ax = ax * 2 every char is 2 elems
    add  si, ax        ; pos in hob to fetch character
    mov  ax, hob[si+2] ; +2 as first field contains str_len
    ret
String_charAt ENDP

String_concat PROC
    mov  bp, sp
    sub  bp, 2
    mov  cx, hob[bx] ; size of caller str
    mov  si, [bp+4]  ; pos in hob of 2nd str len
    add  cx, hob[si] ; add 2nd str len
    add  cx, 2	    ; add space for sizefield
    push cx
    call new        ; alloc new String object
    pop  cx			; total strsize
    mov  si, ax      ; can't just use the AX
    mov  hob[si], cx ; set concat'ed String size

    mov  cx, hob[bx] ; size of str1
    add  bx, 4       ; start in 2nd pos (but why +4 instead of +2 ??)
    mov  di, ax      ; destination ptr = adr of new String obj
    add  di, 2       ; start in 2nd pos
strcat1:
    mov  si, [bx]    ; we can't just use [bx]
    mov  hob[di], si
    add  bx, 2
    add  di, 2
    loop strcat1

    mov  si, [bp+4]  ; pos in hob of 2nd str len
    mov  cx, hob[si] ; size of 2nd str len
    mov  bx, [bp+4]  ; point at start of 2nd string
    add  bx, 4       ; start in 2nd pos (but why +4??)
strcat2:
    mov  si, [bx]    ; we can't just use [bx]
    mov  hob[di], si
    add  bx, 2
    add  di, 2
    loop strcat2
    ret
String_concat ENDP
    
String_length PROC ; str_len length()
    mov  ax, hob[bx] ; first field in string
    ret
String_length ENDP
; ------------ STANDARD FUNCTIONS END ----------:


START:
    mov  ax, @data ; setup DOS program
    mov  ds, ax
    ; allocate object main resides in
    mov  cx, 0
    call new
    mov  bp, sp     ; adjust bp to point at functions local variable
    sub  bp, 2      ;
    mov  bx, ax    ; store main's 'this' 
    ; execute mains contents
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    ; assign
    mov  ax, 10
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable t
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-0] ; get local variable t
    push ax
    call toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  SystemExit
END
