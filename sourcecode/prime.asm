DOSSEG
    .MODEL SMALL
    .STACK 100h
    

.DATA
    hobptr  dw 0
    hob     dw 32605 dup(0) ; allocate hob
    ; error messages
    oomstr	db	10,13,'Out of memory! Can not allocate another class.','$',0,0
    

.CODE
    jmp  START

; ------------ STANDARD FUNCTIONS BEGIN ----------:

new PROC
    mov  ax, hobptr     ; get hop size
    push ax            ; save pos. of class in stack
    add  ax, cx	       ; add size of obj
    cmp  ax, 32605
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

Integer_toString PROC
    mov  bp, sp
    sub  bp, 2
    mov  ax, [bp+4]    ; get number (first argument)
    xor  cx, cx        ; cx counts size of str
    xor  di, di        ; flag for negative numbers
    cmp  ax, 0         ; is negative?
    jge  nonneg
    inc  di            ; di == 1 == number is negative
    inc  cx
    neg  ax            ; make the number positive
nonneg:
    mov  si, 10        ; div with reg SI as many times as possible
getDigits:
    xor  dx, dx
    div  si
    add  dx, 48        ; conv digit to ASCII
    push dx
    inc  cx
    cmp  ax, 0         ; are we done?
    jg   getDigits

    push cx            ; store cx
    shl  cx, 1         ; calc str size = (2*strlen)+2
    add  cx, 2
    call new           ; alloc new str
    pop  cx            ; get original strlen
    mov  si, ax        ; ptr to str in hob
    mov  hob[si], cx   ; store size of str
    cmp  di, 0         ; is no negative?
    je   toStr
    add  si, 2         ; next pos
    mov  hob[si], '-'  ; write '-' sign
    dec  cx
toStr:
    add  si, 2         ; next pos
    pop  dx            ; get digit
    mov  hob[si], dx   ; store size of str
    loop toStr
    ret
Integer_toString ENDP

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
    push cx
    add  cx, 2	    ; add space for sizefield
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


Prime_calc PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable i
start_while1:
    ; condition code
    mov  ax, [bp-0] ; get local variable i
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_2
    xor  ax, ax ; is not <
    jmp  less_end2
less_2:
    mov  ax, 65535 ; is <
less_end2:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while1 ; condition is false
    ; fnccallGen
    push bp
    call Prime_loop
    pop bp
    ; assign
    mov  ax, [bp-0] ; get local variable i
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable i
    jmp  start_while1 ; loop once more
end_while1:
Prime_calc_end:
    pop  ax   ; de-stack local variables
    ret
Prime_calc ENDP


Prime_loop PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    ; assign
    mov  ax, 3
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable p
start_while3:
    ; condition code
    mov  ax, [bp-0] ; get local variable p
    push ax
    ; 
    mov  ax, 32000
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_4
    xor  ax, ax ; is not <
    jmp  less_end4
less_4:
    mov  ax, 65535 ; is <
less_end4:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while3 ; condition is false
    ; fnccallGen
    push bp
    mov  ax, [bp-0] ; get local variable p
    push ax
    call Prime_isPrime
    pop  cx ; de-stack arguments
    pop bp
    ; assign
    mov  ax, [bp-0] ; get local variable p
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable p
    jmp  start_while3 ; loop once more
end_while3:
Prime_loop_end:
    pop  ax   ; de-stack local variables
    ret
Prime_loop ENDP


Prime_isPrime PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    ; assign
    mov  ax, 2
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable i
start_while5:
    ; condition code
    mov  ax, [bp-0] ; get local variable i
    push ax
    ; 
    mov  ax, [bp+4] ; get argument variable p
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_6
    xor  ax, ax ; is not <
    jmp  less_end6
less_6:
    mov  ax, 65535 ; is <
less_end6:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while5 ; condition is false
    mov  ax, [bp+4] ; get argument variable p
    push ax
    ; 
    mov  ax, [bp-0] ; get local variable i
    push ax
    pop  si
    pop  ax
    xor  dx, dx
    div  si
    push dx
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_8
    xor  ax, ax  ; is !=
    jmp  eq_end8
eq_8:
    mov  ax, 65535 ; is ==
eq_end8:
    push ax
    pop  cx     ; start if_6
    cmp  cx, 0
    je   else_7
then_7:
    jmp  Prime_isPrime_end ; return
    jmp  endif_7
else_7:
    ; assign
    mov  ax, [bp-0] ; get local variable i
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable i
endif_7:
    jmp  start_while5 ; loop once more
end_while5:
Prime_isPrime_end:
    pop  ax   ; de-stack local variables
    ret
Prime_isPrime ENDP


START:
    mov  ax, @data ; setup DOS program
    mov  ds, ax
    ; allocate object main resides in
    mov  cx, 4
    call new
    mov  bp, sp     ; adjust bp to point at functions local variable
    sub  bp, 2      ;
    mov  bx, ax    ; store main's 'this' 
    ; execute mains contents
    push 0    ; push local variables to stack 
    ; assign
    ; new
    mov  cx, 4 ; size of class Prime
    call new
    push ax ; save adr pointer of object
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable ptr
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 4 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 1 ; insert strlength
    mov  hob[si+2], ' '
    push ax
    pop  ax ; get value (assign)
    push bx
                                ; value of ptr.space
    mov  bx, [bp-0] ; this of other class
    mov  hob[bx+0], ax ; set value of variable in other class
    pop  bx
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 14 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 6 ; insert strlength
    mov  hob[si+2], 'l'
    mov  hob[si+4], 'o'
    mov  hob[si+6], 'o'
    mov  hob[si+8], 'p'
    mov  hob[si+10], '!'
    mov  hob[si+12], ' '
    push ax
    pop  ax ; get value (assign)
    push bx
                                ; value of ptr.loopstr
    mov  bx, [bp-2] ; this of other class
    mov  hob[bx+2], ax ; set value of variable in other class
    pop  bx
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-0] ; push callers class' 'this'
    call Prime_calc
    pop  bx ; restore this class' 'this'
    pop  bp
    jmp  SystemExit
END

