; ******************************************************************
; Programa que ejecuta las cuatro operaciones basicas : suma, resta,
; multiplicacion y dividion en 64 bits.
;
; Entradas: 2 numeros enteros y la seleccion de la operacion
; Restricciones
; - 64 bits
; - solo numeros enteros positivos coo entrada y resultado
; Salidas: resultado de la operacion
;
; ******************************************************************

%define SYS_EXIT 60
%define SYS_READ 0
%define SYS_WRITE 1

%define SIZE 64

section .text
global _start

; --------------------------------
; print 2
;     1 - len
;     2 - tira de caracteres
; --------------------------------

%macro print 2
    mov rdx, %1
    mov rsi, %2
    mov rdi, 1
    mov rax, SYS_WRITE
    syscall
%endmacro

; --------------------------------
; read 2
;     1 - len
;     2 - tira de caracteres
; --------------------------------

%macro read 2
    mov rdx, %1
    mov rsi, %2
    mov rdi, 0
    mov rax, SYS_READ
    syscall
%endmacro

; --------------------------------
; exit 0
;     Salir del programa
;     
; --------------------------------

%macro exit 0
    mov rax, SYS_EXIT
    syscall
%endmacro

; --------------------------------
; set_int_string  3
;     set de registros para
;     hacer conversion de int a ascii
;     (itoa)
;     1 - numero
;     2 - tira
;     3 - tamano de tira
; --------------------------------

%macro set_int_string 3
    mov rax, %1
    mov rsi, %2
    mov rbp, %3-2
%endmacro

_start:
    mov al, 0xA
    mov rcx, 20

    print welc_len, welc
    print space_len, space
    call MENU
    print space_len, space

    exit

; --------------------------------------
; Despliega el menu de opciones
; --------------------------------------
MENU:
    print menu_len, menu_msg
    print suma_len, suma_msg
    print resta_len, resta_msg
    print multiplicacion_len, multiplicacion_msg
    print division_len, division_msg
    print exit_len, exit_msg

.menu_loop:
    read option_len, option
    xor rcx, rcx
    mov bl, byte [option + rcx]

    cmp bl, '1'
    jb .menu_loop
    cmp bl, '5'
    ja .menu_loop

    cmp bl, '1'
    je SUMA
    cmp bl, '2'
    je RESTA
    cmp bl, '3'
    je MULTIPLICACION
    cmp bl, '4'
    je DIVISION
    cmp bl, '5'
    je .exit

.exit:
    exit
    ret

; --------------------------------------
; Operaciones con los valores ingresados
; --------------------------------------
SUMA:
    call GET_INPUT
    call ATOI_NUM1
    call ATOI_NUM2

    ;rax = numero 1
    ;rbx = numero 2

    add rax, rbx

    set_int_string rax, resultado, resultado_len
    call INT_STRING
    print resultado_msg_len, resultado_msg
    print resultado_len, resultado

    ret

RESTA:
    call GET_INPUT
    call ATOI_NUM1
    call ATOI_NUM2

    ;rax = numero 1
    ;rbx = numero 2

    sub rax, rbx

    set_int_string rax, resultado, resultado_len
    call INT_STRING
    print resultado_msg_len, resultado_msg
    print resultado_len, resultado

    ret

MULTIPLICACION:
    call GET_INPUT
    call ATOI_NUM1
    call ATOI_NUM2

    ;rax = numero 1
    ;rbx = numero 2

    mul rbx ; rax = rax*rbx

    set_int_string rax, resultado, resultado_len
    call INT_STRING
    print resultado_msg_len, resultado_msg
    print resultado_len, resultado

    ret

DIVISION:
    call GET_INPUT
    call ATOI_NUM1
    call ATOI_NUM2

    ;rax = numero 1
    ;rbx = numero 2

    xor rdx, rdx
    div rbx ; rax = rax / rbx

    set_int_string rax, resultado, resultado_len
    call INT_STRING
    print resultado_msg_len, resultado_msg
    print resultado_len, resultado

    ret

; --------------------------------------
; Obtiene el input del usuario
; --------------------------------------
GET_INPUT:
    print intr1_len, intr1
    read num1_len, num1
    print intr2_len, intr2
    read num2_len, num2
    ret
; --------------------------------------
; Convierte de ASCII a INT
; --------------------------------------
ATOI_NUM1:
    xor rax, rax ; rax = resultado
    xor rcx, rcx ; rcx = contador

.convertir:
    mov rdx, 10 ; rdx = 10, divisor
    xor rbx, rbx ; rbx = 0, primer digito
    mov bl, byte[num1+rcx] ; primer digito num1 = numero y rcx = contador

    cmp bl, 10 ; termina
    je .done

    cmp bl, 48 ; validacion <48
    jl .error

    cmp bl, 57 ; validacion >57
    jg .error

    sub bl, 48 ; convertir a decimal
    add rax, rbx ; rax = rax + rbx
    mul rdx ; rax = rax*rdx con rdx = 10
    inc rcx ; rcx++

    jmp .convertir

.error:
    print error_len, error_msg
    exit

.done:
    xor rdx, rdx
    mov rbx, 10
    div rbx

    ret

ATOI_NUM2:
    push rax
    xor rax, rax ; rax = resultado
    xor rcx, rcx ; rcx = contador

.convertir:
    mov rdx, 10 ; rdx = 10, divisor
    xor rbx, rbx ; rbx = 0, primer digito
    mov bl, byte[num2+rcx] ; primer digito num1 = numero y rcx = contador

    cmp bl, 10 ; termina
    je .done

    cmp bl, 48 ; validacion <48
    jl .error

    cmp bl, 57 ; validacion >57
    jg .error

    sub bl, 48 ; convertir a decimal
    add rax, rbx ; rax = rax + rbx
    mul rdx ; rax = rax*rdx con rdx = 10
    inc rcx ; rcx++

    jmp .convertir

.error:
    print error_len, error_msg
    exit

.done:
    xor rdx, rdx
    mov rbx, 10
    div rbx

    xor rbx, rbx
    mov rbx, rax

    pop rax

    ret

; --------------------------------------
; Convierte de INT a ASCII (ITOA)
; --------------------------------------

INT_STRING:
    ; rax number
    ; rsi result string
    xor rbx, rbx
    mov rbx, rbp ; counter, result string len

.doop:
    xor rdx, rdx
    mov rcx, 10
    div rcx ; rax = rdx:rax/rcx  rdx = rax%rcx

    push rax
    or rax, rdx
    pop rax
    jz .done

    add rdx, '0'
    mov byte [rsi + rbx], dl ;bl = un digito
    dec rbx

    jmp .doop

.done:
    ret

section .bss
    option resb 21
    option_len equ $-option

    num1 resb 64
    num1_len equ $-num1

    num2 resb 64
    num2_len equ $-num2

    resultado resb 64
    resultado_len equ $-resultado

section .data
    
    welc db "Bienvenidos", 10
    welc_len equ $-welc

    menu_msg db "==== MENU ====", 10
    menu_len equ $-menu_msg

    suma_msg db "1. Ingrese 1 si desea hacer una suma", 10
    suma_len equ $-suma_msg

    resta_msg db "2. Ingrese 2 si desea hacer una resta", 10
    resta_len equ $-resta_msg

    multiplicacion_msg db "3. Ingrese 3 si desea hacer una multiplicacion", 10
    multiplicacion_len equ $-multiplicacion_msg

    division_msg db "4. Ingrese 4 si desea hacer una division", 10
    division_len equ $-division_msg

    exit_msg db "5. Exit", 10
    exit_len equ $-exit_msg

    space db "", 10
    space_len equ $-space

    intr1 db "Ingrese el primer numero: ", 10
    intr1_len equ $-intr1

    intr2 db "Ingrese el segundo numero: ", 10
    intr2_len equ $-intr2

    resultado_msg db "Resultado: ", 10
    resultado_msg_len equ $-resultado_msg

    error_msg db "Entrada invalida", 10
    error_len equ $-error_msg
