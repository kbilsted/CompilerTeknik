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


A_f PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    push 0 ; put all local variables on stack
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 4
    push ax
    ; 
    mov  ax, 2
    push ax
    pop  dx
    pop  ax
    or   ax, dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 12
    push ax
    ; 
    mov  ax, 10
    push ax
    pop  dx
    pop  ax
    and  ax, dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 1
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 4
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    sub  ax, dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 2
    push ax
    ; 
    mov  ax, 3
    push ax
    pop  dx
    pop  ax
    mul  dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 25
    push ax
    ; 
    mov  ax, 5
    push ax
    pop  si
    pop  ax
    xor  dx, dx
    div  si
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 23
    push ax
    ; 
    mov  ax, 8
    push ax
    pop  si
    pop  ax
    xor  dx, dx
    div  si
    push dx
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, 6
    push ax
    ; 
    ; monadic begin
    mov  ax, 2
    push ax
    pop  ax
    neg  ax
    push ax
    pop  dx
    pop  ax
    sub  ax, dx
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    ; monadic begin
    mov  ax, 65528
    push ax
    pop  ax
    not  ax
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 1
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_2
    xor  ax, ax  ; is !=
    jmp  eq_end2
eq_2:
    mov  ax, 65535 ; is ==
eq_end2:
    push ax
    pop  cx     ; start if_0
    cmp  cx, 0
    je   else_1
then_1:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_1
else_1:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_1:
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_4
    xor  ax, ax  ; is !=
    jmp  eq_end4
eq_4:
    mov  ax, 65535 ; is ==
eq_end4:
    push ax
    pop  cx     ; start if_2
    cmp  cx, 0
    je   else_3
then_3:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_3
else_3:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_3:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jne  neq_6
    xor  ax, ax  ; is ==
    jmp  neq_end6
neq_6:
    mov  ax, 65535 ; is !=
neq_end6:
    push ax
    pop  cx     ; start if_4
    cmp  cx, 0
    je   else_5
then_5:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_5
else_5:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_5:
    ; assign
    mov  ax, 1
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jne  neq_8
    xor  ax, ax  ; is ==
    jmp  neq_end8
neq_8:
    mov  ax, 65535 ; is !=
neq_end8:
    push ax
    pop  cx     ; start if_6
    cmp  cx, 0
    je   else_7
then_7:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_7
else_7:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_7:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_10
    xor  ax, ax ; is not <
    jmp  less_end10
less_10:
    mov  ax, 65535 ; is <
less_end10:
    push ax
    pop  cx     ; start if_8
    cmp  cx, 0
    je   else_9
then_9:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_9
else_9:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_9:
    ; assign
    mov  ax, 1
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_12
    xor  ax, ax ; is not <
    jmp  less_end12
less_12:
    mov  ax, 65535 ; is <
less_end12:
    push ax
    pop  cx     ; start if_10
    cmp  cx, 0
    je   else_11
then_11:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_11
else_11:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_11:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jle  lequal_14
    xor  ax, ax  ; is not <=
    jmp  lequal_end14
lequal_14:
    mov  ax, 65535 ; is <=
lequal_end14:
    push ax
    pop  cx     ; start if_12
    cmp  cx, 0
    je   else_13
then_13:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_13
else_13:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_13:
    ; assign
    mov  ax, 1
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jle  lequal_16
    xor  ax, ax  ; is not <=
    jmp  lequal_end16
lequal_16:
    mov  ax, 65535 ; is <=
lequal_end16:
    push ax
    pop  cx     ; start if_14
    cmp  cx, 0
    je   else_15
then_15:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_15
else_15:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_15:
    ; assign
    mov  ax, 2
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jle  lequal_18
    xor  ax, ax  ; is not <=
    jmp  lequal_end18
lequal_18:
    mov  ax, 65535 ; is <=
lequal_end18:
    push ax
    pop  cx     ; start if_16
    cmp  cx, 0
    je   else_17
then_17:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_17
else_17:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_17:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; monadic begin
    mov  ax, 1
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_20
    xor  ax, ax  ; is !=
    jmp  eq_end20
eq_20:
    mov  ax, 65535 ; is ==
eq_end20:
    push ax
    pop  ax
    not  ax
    push ax
    pop  cx     ; start if_18
    cmp  cx, 0
    je   else_19
then_19:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_19
else_19:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_19:
    ; monadic begin
    mov  ax, 1
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_22
    xor  ax, ax  ; is !=
    jmp  eq_end22
eq_22:
    mov  ax, 65535 ; is ==
eq_end22:
    push ax
    pop  ax
    not  ax
    push ax
    pop  cx     ; start if_20
    cmp  cx, 0
    je   else_21
then_21:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_21
else_21:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_21:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_24
    xor  ax, ax  ; is !=
    jmp  eq_end24
eq_24:
    mov  ax, 65535 ; is ==
eq_end24:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_25
    xor  ax, ax  ; is !=
    jmp  eq_end25
eq_25:
    mov  ax, 65535 ; is ==
eq_end25:
    push ax
    pop  dx
    pop  ax
    and  ax, dx
    push ax
    pop  cx     ; start if_22
    cmp  cx, 0
    je   else_23
then_23:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_23
else_23:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_23:
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_27
    xor  ax, ax  ; is !=
    jmp  eq_end27
eq_27:
    mov  ax, 65535 ; is ==
eq_end27:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_28
    xor  ax, ax  ; is !=
    jmp  eq_end28
eq_28:
    mov  ax, 65535 ; is ==
eq_end28:
    push ax
    pop  dx
    pop  ax
    and  ax, dx
    push ax
    pop  cx     ; start if_25
    cmp  cx, 0
    je   else_26
then_26:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_26
else_26:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_26:
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_30
    xor  ax, ax  ; is !=
    jmp  eq_end30
eq_30:
    mov  ax, 65535 ; is ==
eq_end30:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_31
    xor  ax, ax  ; is !=
    jmp  eq_end31
eq_31:
    mov  ax, 65535 ; is ==
eq_end31:
    push ax
    pop  dx
    pop  ax
    and  ax, dx
    push ax
    pop  cx     ; start if_28
    cmp  cx, 0
    je   else_29
then_29:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_29
else_29:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_29:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_33
    xor  ax, ax  ; is !=
    jmp  eq_end33
eq_33:
    mov  ax, 65535 ; is ==
eq_end33:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_34
    xor  ax, ax  ; is !=
    jmp  eq_end34
eq_34:
    mov  ax, 65535 ; is ==
eq_end34:
    push ax
    pop  dx
    pop  ax
    or   ax, dx
    push ax
    pop  cx     ; start if_31
    cmp  cx, 0
    je   else_32
then_32:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_32
else_32:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_32:
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_36
    xor  ax, ax  ; is !=
    jmp  eq_end36
eq_36:
    mov  ax, 65535 ; is ==
eq_end36:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_37
    xor  ax, ax  ; is !=
    jmp  eq_end37
eq_37:
    mov  ax, 65535 ; is ==
eq_end37:
    push ax
    pop  dx
    pop  ax
    or   ax, dx
    push ax
    pop  cx     ; start if_34
    cmp  cx, 0
    je   else_35
then_35:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_35
else_35:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_35:
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_39
    xor  ax, ax  ; is !=
    jmp  eq_end39
eq_39:
    mov  ax, 65535 ; is ==
eq_end39:
    push ax
    ; 
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_40
    xor  ax, ax  ; is !=
    jmp  eq_end40
eq_40:
    mov  ax, 65535 ; is ==
eq_end40:
    push ax
    pop  dx
    pop  ax
    or   ax, dx
    push ax
    pop  cx     ; start if_37
    cmp  cx, 0
    je   else_38
then_38:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+4] ; get class variable strtrue
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_38
else_38:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+2] ; get class variable strfalse
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
endif_38:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
start_while41:
    ; condition code
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 0
    push ax
    ; equal
    pop  dx
    pop  ax
    cmp  ax, dx
    je   eq_42
    xor  ax, ax  ; is !=
    jmp  eq_end42
eq_42:
    mov  ax, 65535 ; is ==
eq_end42:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while41 ; condition is false
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable j
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    jmp  start_while41 ; loop once more
end_while41:
    ; assign
    mov  ax, 6
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
start_while43:
    ; condition code
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 5
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_44
    xor  ax, ax ; is not <
    jmp  less_end44
less_44:
    mov  ax, 65535 ; is <
less_end44:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while43 ; condition is false
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable j
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    jmp  start_while43 ; loop once more
end_while43:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
start_while45:
    ; condition code
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 5
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_46
    xor  ax, ax ; is not <
    jmp  less_end46
less_46:
    mov  ax, 65535 ; is <
less_end46:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while45 ; condition is false
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable j
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 1
    push ax
    pop  dx
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    jmp  start_while45 ; loop once more
end_while45:
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    mov  ax, 0
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
start_while47:
    ; condition code
    mov  ax, [bp-2] ; get local variable j
    push ax
    ; 
    mov  ax, 5
    push ax
    pop  dx
    pop  ax
    cmp  ax, dx
    jl   less_48
    xor  ax, ax ; is not <
    jmp  less_end48
less_48:
    mov  ax, 65535 ; is <
less_end48:
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while47 ; condition is false
    jmp  end_while47 ; break
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable j
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  start_while47 ; loop once more
end_while47:
    jmp  A_f_end ; return
    ; assign
    mov  ax, 42
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable j
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable j
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
A_f_end:
    pop  ax   ; de-stack local variables
    pop  ax   ; de-stack local variables
    ret
A_f ENDP


A_g PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    ; assign
    mov  ax, 3
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable pp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-0] ; get local variable pp
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp+4] ; get argument variable x
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp+6] ; get argument variable y
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
A_g_end:
    pop  ax   ; de-stack local variables
    ret
A_g ENDP


B_g PROC
    mov  bp, sp ; adjust bp to point at functions local variable
    sub  bp, 2
    push 0 ; put all local variables on stack
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 34 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 16 ; insert strlength
    mov  hob[si+2], 'h'
    mov  hob[si+4], 'e'
    mov  hob[si+6], 'j'
    mov  hob[si+8], ' '
    mov  hob[si+10], 'f'
    mov  hob[si+12], 'r'
    mov  hob[si+14], 'a'
    mov  hob[si+16], ' '
    mov  hob[si+18], 'o'
    mov  hob[si+20], 'b'
    mov  hob[si+22], 'j'
    mov  hob[si+24], 'e'
    mov  hob[si+26], 'k'
    mov  hob[si+28], 't'
    mov  hob[si+30], ' '
    mov  hob[si+32], 'B'
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable s
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-0] ; get local variable s
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
B_g_end:
    pop  ax   ; de-stack local variables
    ret
B_g ENDP


START:
    mov  ax, @data ; setup DOS program
    mov  ds, ax
    ; allocate object main resides in
    mov  cx, 6
    call new
    mov  bp, sp     ; adjust bp to point at functions local variable
    sub  bp, 2      ;
    mov  bx, ax    ; store main's 'this' 
    ; execute mains contents
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 14 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 6 ; insert strlength
    mov  hob[si+2], 'D'
    mov  hob[si+4], 'a'
    mov  hob[si+6], 't'
    mov  hob[si+8], 'a'
    mov  hob[si+10], 'm'
    mov  hob[si+12], 'a'
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable s
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 6 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 2 ; insert strlength
    mov  hob[si+2], 't'
    mov  hob[si+4], '!'
    push ax
    pop  ax ; get value (assign)
    mov  [bp-2], ax ; set local variable s2
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 4 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 1 ; insert strlength
    mov  hob[si+2], ' '
    push ax
    pop  ax ; get value (assign)
    mov  hob[bx+0], ax ; set class variable space
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-0] ; push callers class' 'this'
    call String_length
    pop  bx ; restore this class' 'this'
    pop  bp
    push  ax ; 'emulated' return value on the stack
    pop  ax ; get value (assign)
    mov  [bp-4], ax ; set local variable i
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-4] ; get local variable i
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-0] ; push callers class' 'this'
    mov  ax, [bp-2] ; get local variable s2
    push ax
    call String_concat
    pop  cx ; de-stack arguments
    pop  bx ; restore this class' 'this'
    pop  bp
    push  ax ; 'emulated' return value on the stack
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable s
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-0] ; get local variable s
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-0] ; push callers class' 'this'
    call String_length
    pop  bx ; restore this class' 'this'
    pop  bp
    push  ax ; 'emulated' return value on the stack
    pop  ax ; get value (assign)
    mov  [bp-4], ax ; set local variable i
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-4] ; get local variable i
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-0] ; push callers class' 'this'
    mov  ax, 2
    push ax
    call String_charAt
    pop  cx ; de-stack arguments
    pop  bx ; restore this class' 'this'
    pop  bp
    push  ax ; 'emulated' return value on the stack
    pop  ax ; get value (assign)
    mov  [bp-6], ax ; set local variable c
    ; fnccallGen
    push bp
    push bx
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-6] ; get local variable c
    push ax
    call Integer_toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    push ax ; store generated String
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, hob[bx+0] ; get class variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 4 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 1 ; insert strlength
    mov  hob[si+2], 'F'
    push ax
    pop  ax ; get value (assign)
    mov  hob[bx+2], ax ; set class variable strfalse
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 4 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 1 ; insert strlength
    mov  hob[si+2], 'T'
    push ax
    pop  ax ; get value (assign)
    mov  hob[bx+4], ax ; set class variable strtrue
    ; fnccallGen
    push bp
    call A_f
    pop bp
    ; assign
    ; new
    mov  cx, 0 ; size of class B
    call new
    push ax ; save adr pointer of object
    pop  ax ; get value (assign)
    mov  [bp-8], ax ; set local variable bptr
    ; fnccallGen
    push bp
    mov  ax, 1
    push ax
    mov  ax, 2
    push ax
    call A_g
    pop  cx ; de-stack arguments
    pop  cx ; de-stack arguments
    pop bp
    ; fnccallGen
    push bp
    push bx
    mov  bx, [bp-8] ; push callers class' 'this'
    call B_g
    pop  bx ; restore this class' 'this'
    pop  bp
    jmp  SystemExit
END

