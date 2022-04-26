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

; --------------------------------
; is_something 1
;     1 - procedimiento
;
; Macro que llama a un procedimiento
; IS_NUMERO, IS_OPERADOR, ETC.
; para validar caracteres
; rdx = 1 si es verdadero
; rdx = 0 si es falso
;
; --------------------------------

%macro is_something 1
	xor rdx, rdx
	call %1
	cmp rdx, 1
%endmacro

; --------------------------------
; imprimir_procedimiento
;     imprime el procedimiento
;	  para resolver la ecuacion
; --------------------------------

%macro imprimir_procedimiento 0
    push rcx
    push rbx
    push rax
    mov rax, ecuacion
    call imprimir_linea
    print space_len, space
    pop rax
    pop rbx
    pop rcx
%endmacro

; --------------------------------
; start
;     funcion principal
; --------------------------------
_start:
    print welc_len, welc
    print space_len, space
    
    ;obtiene la ecuacion
   	call GET_INPUT
   	;le agrega parentesis a la ecuacion
   	call inicializar_ecuacion
   	;resuelve una tira sin parentesis
   	call resolver_tira

   	;imprime el resultado
   	print resultado_msg_len, resultado_msg
    print resultado_len, resultado

    exit

; --------------------------------
; imprimir_linea
;     procedimiento llamado por
;     imprimir_procedimiento
;     imprime solo hasta la coma
;     que indica el final de la ecuacion
; rax: lo que se va a imprimir
; rbx: cuenta los caracteres a imprimir
; rcx: caracter
; --------------------------------
imprimir_linea:
	push rax
	xor rbx, rbx

imprimir_linea_loop:
	inc rax
	inc rbx
	mov cl, [rax]
	cmp cl, ','
	jne imprimir_linea_loop

	mov rax, 1
	mov rdi, 1
	pop rsi
	mov rdx, rbx
	syscall

	ret

; --------------------------------
; inicializar ecuacion
;     le agrega parentesis iniciales
;     y finales a la ecuacion ya que
;	  hay un error al iniciar un
;     contador en -1
;
; registros usados
; rcx, rax, rbx
; --------------------------------
inicializar_ecuacion:
	xor rcx, rcx ;contador de la ecuacion vieja
	xor rax, rax ;contador de la ecuacion nueva
	;se inicializa con un parentesis por el contador
	xor rbx, rbx
	mov bl, '('
	mov [ecuacion+rax], bl
	inc rax

.inicializar:
	xor rbx, rbx
   	mov bl, byte[operation+rcx]

   	cmp bl, 10
   	je .fin

   	mov [ecuacion+rax], bl
   	inc rcx
   	inc rax

   	jmp .inicializar

.fin:
	xor rbx, rbx
	mov bl, ')'
	mov [ecuacion+rax], bl
	ret

; --------------------------------
; resolver tira
;     resuelve una tira sin
;     parentesis con orden de
;     prioridad de operaciones
;
; --------------------------------

resolver_tira:
	imprimir_procedimiento
	xor rbx, rbx ;caracter
	xor rcx, rcx ;contador
	xor r15, r15 ;inicio de la operacion cambiada
	xor r14, r14 ;final de la operacion cambiada

;multiplicacion y division con prioridad segun aparezca primero
.buscar_mul_div:
	mov bl, byte[ecuacion+rcx]
	inc rcx

	cmp bl, ','
	je .buscar_sumar

	cmp bl, 42 ; *
	je .operador

	cmp bl, 47 ; /
	je .operador

	cmp bl, 37 ; %
	je .operador

	jmp .buscar_mul_div

.buscar_division:
	xor rcx, rcx

.buscar_division_loop:
	mov bl, byte[ecuacion+rcx]
	inc rcx

	cmp bl, ','
	je .buscar_sumar

	cmp bl, 47 ; /
	je .operador

	jmp .buscar_division_loop

;suma despues de multiplicacion y division
.buscar_sumar:
	xor rcx, rcx

.buscar_sumar_loop:
	mov bl, byte[ecuacion+rcx]
	inc rcx

	cmp bl, ','
	je imprimir_resultado

	cmp bl, 43 ; +
	je .operador

	jmp .buscar_sumar_loop

;modulo despues de suma
.buscar_modulo:
	xor rcx, rcx

.buscar_modulo_loop:
	mov bl, byte[ecuacion+rcx]
	inc rcx

	cmp bl, ','
	je imprimir_resultado

	cmp bl, 37 ; %
	je .operador

	jmp .buscar_modulo_loop

;el operador ha sido encontrado
.operador:
	dec rcx

;busca el primer numero antes del operador para enviar el puntero a resolver_operacion
.buscar_inicio:
	dec rcx
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	is_something IS_MENOS
	je .buscar_inicio

	is_something IS_NUMERO
	jne .inicio_encontrado

	jmp .buscar_inicio

.inicio_encontrado:
	mov r15, rcx ;guardar el contador
	call resolver_operacion

; --------------------------------
; modificar ecuacion
;     modifica la ecuacion vieja
;     por una nueva luego de
;     resuelta una operacion
; --------------------------------

modificar_ecuacion:
	;rax tiene la operacion resuelta

	;si llega al limite, tira un error
	cmp rax, 922337203
	jg error_maximo

	xor rcx, rcx ;contador de la ecuacion nueva
	xor r8, r8 ;contador de la ecuacion vieja

.modificar_loop:
	;r15: inicio de la operacion hecha
   	cmp rcx, r15
   	je .inicio_operacion

   	xor rbx, rbx
	mov bl, byte[ecuacion+r8]

   	;final de ecuacion
   	cmp bl, 10
   	je .verificar_fin

   	;actualizamos la operacion
   	mov [ecuacion+rcx], bl
   	inc rcx
   	inc r8

   	jmp .modificar_loop

;modificar la operacion anterior por el resultado
.inicio_operacion:
	inc rcx
    cmp rax, 0
    jl .negativo

    cmp rax, 0
    je .cero
    ;else

    ;guardar el valor de rax
    xor r13, r13
    mov r13, rax
    xor r12, r12
    
    jmp .contar_digitos

;si el resultado es negativo se le agrega un menos
.negativo:
    neg rax ; de negativo a positivo

    xor rbx, rbx
    mov bl, '-'
    mov [ecuacion+rcx], bl
   	inc rcx

   	;guardar el valor de rax
    xor r13, r13
    mov r13, rax
    xor r12, r12

    jmp .contar_digitos

;si el resultado es cero, se agrega un creo
.cero:
	xor rax, rax
	mov al, '0'
	mov [ecuacion+rcx], al
	inc rcx

	;salta al final de la operacion hecha
	mov r8, r14

	jmp .modificar_loop

;cuenta los digitos para agregarlos en orden
.contar_digitos:
	cmp rax, 0
	je .itoa

	xor rdx, rdx
	xor rbx, rbx
	mov rbx, 10
	div rbx
	inc r12

	jmp .contar_digitos

;agrega los digitos de un numero del menos significativo al mas significativo
.itoa:
	mov rax, r13 ;numero que estaba en rax antes de dividir
	add rcx, r12 ;se le agrega la cantidad de digitos al contador
	dec rcx ;se decrece el contador hasta que el numero sea 0

.itoa_loop:
	cmp rax, 0
	je .itoa_fin

	xor rdx, rdx
	xor rbx, rbx
	mov rbx, 10
	div rbx ;rdx = rax%10
	add rdx, 48 ;conversion
	mov [ecuacion+rcx], dl
	dec rcx

	jmp .itoa_loop

.itoa_fin:
	;salta al final de la operacion hecha
	mov r8, r14 ;sigue al final de la operacion
	add rcx, r12 ;sigue al final del resultado
	inc rcx
	jmp .modificar_loop ;continua agregando los caracteres que faltan

;verificar si aun queda algun operador en la ecuacion
.verificar_fin:
	xor rcx, rcx

.verificar_loop:
	mov bl, byte[ecuacion+rcx]
	inc rcx

	cmp bl, ","
	je .fin

	is_something IS_MENOS
	je .verificar_loop

	is_something IS_OPERADOR
	je resolver_tira

	jmp .verificar_loop

;imprime el resultado cuando ya no hay mas operadores en la tira
.fin:
	imprimir_procedimiento
	jmp imprimir_resultado

; --------------------------------
; resolver
;     resuelve una operacion
;     numero operador numero
;
; entradas
; ecuacion y rcx
; rcx es el puntero a donde comienza la operacion
;
; registros usados
; rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
;
; --------------------------------

resolver_operacion:
	xor rax, rax ;se utiliza para dividir y multiplicar a la hora de convertir de ascii a int
	xor rbx, rbx ;caracter
	;xor rcx, rcx ;contador de ecuacion
	xor rdx, rdx ;multiplicando
	mov rdx, 10 ;*10

	xor r8, r8 ;guarda el contador en el lugar despues del operador
	xor r9, r9 ;numero 1
	xor r10, r10 ;operador
	xor r11, r11 ;numero 2
	xor r12, r12 ;cuenta los digitos del numero

.resolver:
	inc rcx
	mov bl, byte[ecuacion+rcx]

	is_something IS_MENOS
	je .resolver

	is_something IS_OPERADOR
	je .operador

	jmp .resolver

;el operador ha sido encontrado
.operador:
	mov r8, rcx ;guardar el contador

	xor r10, r10
	mov r10, rbx

.buscar_num1:
	dec rcx
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	is_something IS_NUMERO
	je .num1_encontrado

	jmp .buscar_num1

.num1_encontrado:
	sub bl, 48 ; convertir a decimal
    add rax, rbx ; rax = rax + rbx
    inc r12

;agrega el numero al reves
.num1_loop:
	dec rcx
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	is_something IS_NUMERO
	jne .num1_vuelta

	;sub bl, 48
	;push rax
	;xor rax, rax
	;add rax, rbx
	;mov rdx, 10
	;mul rdx
	;mov r9, rax
	;pop rax
	;add rax, r9
	mov rdx, 10
    mul rdx
	sub bl, 48
	add rax, rbx
	inc r12

	jmp .num1_loop

;le da vuelta al numero
.num1_vuelta:
	cmp r12, 0
	je .num1_fin

	xor r13, r13
	mov r13, 10

	;se hace push y pop de rax que tiene el valor del numero
	;para multiplicar por 10 el valor en r9 que es el numero en int
	;rax contiene el valor viejo que se divide
	;r9 contiene el valor nuevo que se suma y multiplica
	push rax
	xor rax, rax
	mov rax, r9
	mul r13
	mov r9, rax
	pop rax

	xor rdx, rdx
	div r13
	add r9, rdx

	dec r12

	jmp .num1_vuelta

;convierte a negativo el numero si es necesario
.num1_fin:
	mov rcx, r8

	cmp bl, '-'
	jne .buscar_num2

	neg r9

.buscar_num2:
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	is_something IS_NUMERO
	je .num2_encontrado

	inc rcx

	jmp .buscar_num2

.num2_encontrado:
	xor rax, rax
	sub bl, 48 ; convertir a decimal
    add rax, rbx ; rax = rax + rbx

.num2_loop:
	inc rcx
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	is_something IS_NUMERO
	jne .num2_fin

	mov rdx, 10
    mul rdx
	sub bl, 48
	add rax, rbx

	jmp .num2_loop

;mueve a r11 el numero 2 y lo convierte a negativo si es necesario
.num2_fin:
	xor r11, r11
	mov r11, rax

	mov r14, rcx ;guardar fin de la operacion
	mov rcx, r8
	inc rcx
	xor rbx, rbx
	mov bl, byte[ecuacion+rcx]

	cmp bl, '-'
	jne .operar

	neg r11

;opera de acuerdo al operador encontrado al inicio y guardado en r10
.operar:
	mov rbx, r10

	cmp bl, '+' ; +
	je SUMA

	cmp bl, '*' ; *
	je MULTIPLICACION

	cmp bl, '/' ; /
	je DIVISION

	cmp bl, '%' ; %
	je MODULO

	print error_len, error_msg
    exit

; --------------------------------------
; Validar si un caracter es un numero
; rbx (bl) tiene el caracter
; --------------------------------------
IS_NUMERO:
	cmp bl, 48 ; 0, validacion <48
	jl .not_numero

	cmp bl, 57 ; 9, validacion >57
	jg .not_numero

	jmp .numero

.numero:
	mov rdx, 1
	ret

.not_numero:
	xor rdx, rdx
	ret

; --------------------------------------
; Validar si un caracter es un operador
; rbx (bl) tiene el caracter
; --------------------------------------
IS_OPERADOR:
	cmp bl, 43 ; +
	je .operador

	cmp bl, 42 ; *
	je .operador

	cmp bl, 45 ; -
	je .operador

	cmp bl, 47 ; /
	je .operador

	cmp bl, 37 ; %
	je .operador

	jmp .not_operador

.operador:
	mov rdx, 1
	ret

.not_operador:
	xor rdx, rdx
	ret

; --------------------------------------
; Validar si un caracter es un menos
; rbx (bl) tiene el caracter
; --------------------------------------
IS_MENOS:

	cmp bl, 45 ; -
	je .operador

	jmp .not_operador

.operador:
	mov rdx, 1
	ret

.not_operador:
	xor rdx, rdx
	ret

; --------------------------------------
; Operaciones con los valores ingresados
; --------------------------------------
SUMA:
    ;call ATOI_NUM1
    ;call ATOI_NUM2

    ;rax = numero 1
    mov rax, r9
    ;rbx = numero 2
    mov rbx, r11

    add rax, rbx

    jmp modificar_ecuacion

RESTA:
    ;call ATOI_NUM1
    ;call ATOI_NUM2

    ;rax = numero 1
    mov rax, r9
    ;rbx = numero 2
    mov rbx, r11

    sub rax, rbx

    jmp modificar_ecuacion

MULTIPLICACION:
    ;call ATOI_NUM1
    ;call ATOI_NUM2

    ;rax = numero 1
    mov rax, r9
    ;rbx = numero 2
    mov rbx, r11

    mul rbx ; rax = rax*rbx

    jmp modificar_ecuacion

DIVISION:
    ;call ATOI_NUM1
    ;call ATOI_NUM2

    xor rcx, rcx
    ;rax = numero 1
    mov rax, r9
    ;rbx = numero 2
    mov rbx, r11

    ;error si se divide por 0
    cmp rbx, 0
    je division_por_cero

    cmp r9, 0
    jl .num1_negativo

    cmp r11, 0
    jl .num2_negativo

    jmp .division

.num1_negativo:
	neg rax
	inc rcx

	cmp r11, 0
	jl .num2_negativo

	jmp .division

.num2_negativo:
	neg rbx
	inc rcx

.division:
	xor rdx, rdx
    div rbx ; rax = rax / rbx

    cmp rcx, 1
    je .negativo

    jmp modificar_ecuacion

.negativo:
	neg rax

    jmp modificar_ecuacion

MODULO:
    ;call ATOI_NUM1
    ;call ATOI_NUM2

    ;rax = numero 1
    mov rax, r9
    ;rbx = numero 2
    mov rbx, r11

    xor rdx, rdx
    div rbx ; rax = rax / rbx

    xor rax, rax
    mov rax, rdx

    jmp modificar_ecuacion

; --------------------------------------
; Obtiene el input del usuario
; --------------------------------------
GET_INPUT:
    print intr_len, intr
    read len_operation, operation
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

; --------------------------------------
; Convierte de INT a ASCII para negativos (ITOA)
; --------------------------------------

INT_STRING_NEG:
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
    xor rdx, rdx
    mov dl, '-'
    mov byte[rsi + rbx], dl
    ret

; --------------------------------------
; Imprime el resultado en rax
; --------------------------------------

imprimir_resultado:
	xor rcx, rcx ;contador de la ecuacion vieja

.resultado:
	xor rbx, rbx
   	mov bl, byte[ecuacion+rcx]

   	cmp bl, ','
   	je .fin

   	mov [resultado+rcx], bl
   	inc rcx

   	jmp .resultado

.fin:
	mov bl, 10
	mov [resultado+rcx], bl

	print resultado_msg_len, resultado_msg
   	print resultado_len, resultado

    exit

division_por_cero:
	print error_cero_msg_len, error_cero_msg

    exit

error_maximo:
	print error_max_msg_len, error_max_msg

    exit

section .bss

    operation resb 1024
	len_operation equ $-operation

    resultado resb 64
    resultado_len equ $-resultado

section .data
    
    welc db "Bienvenidos", 10
    welc_len equ $-welc

    space db "", 10
    space_len equ $-space

    intr db "Ingrese la ecuacion:  ", 10
    intr_len equ $-intr

    resultado_msg db "Resultado: ", 10
    resultado_msg_len equ $-resultado_msg

    error_msg db "Entrada invalida", 10
    error_len equ $-error_msg

    error_cero_msg db "Error: division por cero", 10
    error_cero_msg_len equ $-error_cero_msg

    error_max_msg db "Error: numero maximo con signo alcanzado: 2^63 -1", 10
    error_max_msg_len equ $-error_max_msg

    ecuacion db ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 10
    len_ecuacion equ $-ecuacion
