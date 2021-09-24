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
    push 0    ; push local variables to stack 
    push 0    ; push local variables to stack 
    ; assign
    ; string - allocate class and return pointer on stack
    mov  cx, 4 ; length of 2*str + 2 
    call new
    mov  si, ax ; mov (adr of obj in hob) to si
    mov  hob[si], 1 ; insert strlength
    mov  hob[si+2], '*'
    push ax
    pop  ax ; get value (assign)
    mov  [bp-0], ax ; set local variable space
    ; assign
    mov  ax, 1
    push ax
    pop  ax ; get value (assign)
    mov  [bp-4], ax ; set local variable p
start_while1:
    ; condition code
    mov  ax, [bp-4] ; get local variable p
    push ax
    ; 
    mov  ax, 100
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
    ; assign
    mov  ax, 2
    push ax
    pop  ax ; get value (assign)
    mov  [bp-6], ax ; set local variable div
start_while3:
    ; condition code
    mov  ax, [bp-6] ; get local variable div
    push ax
    ; 
    mov  dx, [bp-4] ; get local variable p
    pop  ax
    cmp  ax, dx
    jne  neq_4
    xor  ax, ax  ; is ==
    jmp  neq_end4
neq_4:
    mov  ax, 65535 ; is !=
neq_end4:
    push ax
    ; 
    mov  ax, [bp-4] ; get local variable p
    push ax
    ; 
    mov  si, [bp-6] ; get local variable div
    pop  ax
    xor  dx, dx
    div  si
    push dx
    ; 
    mov  dx, 0
    pop  ax
    cmp  ax, dx
    jne  neq_5
    xor  ax, ax  ; is ==
    jmp  neq_end5
neq_5:
    mov  ax, 65535 ; is !=
neq_end5:
    push ax
    pop  dx
    pop  ax
    and  ax, dx
    push ax
    pop  ax ; compare condition code
    cmp  ax, 0
    je   end_while3 ; condition is false
    ; assign
    mov  ax, [bp-6] ; get local variable div
    push ax
    ; 
    mov  dx, 1
    pop  dx
    pop  ax
    add  ax, dx
    mov  [bp-6], ax ; set local variable div
    jmp  start_while3 ; loop once more
end_while3:
    mov  ax, [bp-6] ; get local variable div
    push ax
    ; 
    mov  dx, [bp-4] ; get local variable p
    ; equal

    pop  ax
    cmp  ax, dx
    je   eq_7
    xor  ax, ax  ; is !=
    jmp  eq_end7
eq_7:
    mov  ax, 65535 ; is ==
eq_end7:
    push ax
    pop  cx     ; start if_5
    cmp  cx, 0
    je   else_6
then_6:
    ; assign
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-4] ; get local variable p
    push ax
    call toString
    pop  cx ; de-stack arguments
    pop  bx
    pop  bp
    mov  [bp-2], ax ; set local variable no
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-2] ; get local variable no
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    ; fnccallGen
    push bp
    push bx
    mov  ax, [bp-0] ; get local variable space
    push ax
    call SystemOutPrint
    pop  cx ; de-stack argument
    pop  bx
    pop  bp
    jmp  endif_6
else_6:
endif_6:
    ; assign
    mov  ax, [bp-4] ; get local variable p
    push ax
    ; 
    mov  dx, 1
    pop  ax
    add  ax, dx
    push ax
    pop  ax ; get value (assign)
    mov  [bp-4], ax ; set local variable p
    jmp  start_while1 ; loop once more
end_while1:
    jmp  SystemExit
END
