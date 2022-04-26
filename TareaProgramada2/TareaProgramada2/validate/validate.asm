;VERIFIACIÓN DE CARÁCTERES en NASM
;Utilización de arquitectura x64, desarrollado en NASM, nomenclatura INTEL
;Arquitectura de Computadores | IC3101
;Profesor: M.Sc Eduardo Canessa Montero
;Estudiante: José David Martínez Garay
;2018

%define SYS_EXIT 60
%define SYS_READ 0
%define SYS_WRITE 1

%define SIZE 64
%define MAX 9223372036854775807

section .data
	
	bienvenida db "¡Bienvenido! Por favor digite la ecuación a validar: ", 0xA
	len_bienvenida equ $-bienvenida

	;Si la operacion es valida o no lanza un msj indicando ello
	error_msg db "Entrada invalida", 10
    error_len equ $-error_msg

	intr db "Ingrese la ecuacion:  ", 10
    intr_len equ $-intr

    error_max_tam db "Error: La ecuacion debe ser de 1024 caracteres", 10
    error_max_tam_len equ $-error_max_tam


section .bss

	input resb 2000
	len_input equ $-input

	equation resb 2000
	equation_len equ $-equation

	datoEntrada resb 1024 ;Se aparta una variable con capacidad de 64 bytes
	len_datoEntrada equ $-datoEntrada

	operation resb 1024
    operation_len equ $-operation

	nueva_ecuacion resb 1024
	len_nueva_ecuacion equ $-nueva_ecuacion


section .text

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
; validacion
;     procedimiento que revisa
;     parentesis y congruencia
;     entre cantidad de operadores
;     y variables
;
; --------------------------------
	
validacion:
	xor rax, rax
	xor rcx, rcx
	xor rdx, rdx

	;Procedmiiento que verifica si una ecuación es valida
	.cicloValidacion: 

	 	;Se toma el primer byte y se mueve a bl
		mov bl, byte[nueva_ecuacion+rcx]
		
		;si llega al final se retorna
		cmp bl, 0xA
		je .fin
		
		cmp bl, '('
		je .sumar

		cmp bl, ')'
		je .restar

		cmp bl, '+'
		je .is_operando

        cmp bl, '*'
		je .is_operando

        cmp bl, '/'
		je .is_operando

		cmp bl, '%'
		je .is_operando

		cmp bl, '0'
		ja .is_numero


		;Procedimiento que incrementa el contador para pasar al siguiente byte y se retorna al ciclovalidacion

		.continuar:
			inc rcx
			jmp .cicloValidacion
			ret
	
	
	.is_numero:
        cmp rdx, 2
        je .restar_operando

        cmp rdx, 0
        je .sumar_numero

        jmp .continuar

    .sumar_numero:
        mov rdx, 1
        jmp .continuar

    .restar_operando:
        mov rdx, 1
        dec rax
        jmp .continuar

	.is_operando:
        inc rax
        cmp rdx, 1
        je .was_number
        jmp .continuar
    
    .was_number:
        mov rdx, 2
        jmp .continuar

	;Suma al registro rax ya que se utiliza como contador
	.sumar:
		inc rax	

        cmp rdx, 2
        je .restar_operando

		jmp .continuar

	;Se resta al registro rax
	.restar:
        dec rax
        cmp rdx, 0
        je .sumar_numero
		jmp .continuar

	.fin:
		cmp rax, 0
		jne reprobado

		jmp aprobado
	
	aprobado:
		ret ;retorna
		
	reprobado:
		print error_len, error_msg
		exit
		
    

global _start

_start:
	
	call GET_INPUT
	call cortar_ecuacion
	call modificarEQ
	call validacion
	call remover_espacios
	call change
	print operation_len, operation
		
	exit


; --------------------------------------
; Obtiene el input del usuario
; --------------------------------------
GET_INPUT:
    print intr_len, intr
    read len_input, input
    ret

; --------------------------------
; cortar ecuacion
;     procedimiento que elimina
;     los espacios de la ecuacion
;     para enviarla a validacion
;     
;     solamente corta la ecuacion
;     sin variables
;
; --------------------------------

cortar_ecuacion:
	xor rax, rax ;contador nueva ecuacion
	xor rcx, rcx ;contador vieja ecuacion
	xor rbx, rbx ;caracter

.cortar:
	; maximo tamano de 1024 caracteres
	cmp rcx, 1024
	jg error_maximo_tamano

	mov bl, byte[input+rcx]

	cmp bl, ','
	je .fin

	cmp bl, 10
	je .fin

	inc rcx
	cmp bl, " "
	je .cortar

	mov [datoEntrada+rax], bl
	inc rax

	jmp .cortar

.fin:
	mov bl, 10
	mov [datoEntrada+rax], bl
	print len_datoEntrada, datoEntrada
	ret

; --------------------------------
; error maximo tamano
;     imprime un error cuando se llega
;     el limite de 1024 caracteres
;     de la ecuacion
; --------------------------------

error_maximo_tamano:
	print error_max_tam_len, error_max_tam

    exit

; --------------------------------
; remover espacios
;     procedimiento que agrega
;     la ecuacion modificada en
;     validacion y elimina los
;     espacios de las variables
;     ademas de agregar una coma
;     final de las variables
;
;      nueva_ecuacion es la ecuacion modificada en validacion
;      equation es el resultado
;      input es el input obtenido al inicio con las variables
;
; --------------------------------

remover_espacios:
	xor rax, rax ;contador nueva ecuacion
	xor rcx, rcx ;contador vieja ecuacion
	xor rbx, rbx ;caracter

.cortar:
	mov bl, byte[nueva_ecuacion+rcx]

	;cuando se llega al final
	cmp bl, 10
	je .cortar_letras

	inc rcx
	cmp bl, " "
	je .cortar ;no se agregan los espacios

	mov [equation+rax], bl
	inc rax

	jmp .cortar

.cortar_letras:
	xor rcx, rcx ;contador vieja ecuacion
	xor rbx, rbx ;caracter

;busca el inicio de las variables
;cuando se encuentra la coma, la ecuacion ya termino
.cortar_letras_loop:
	mov bl, byte[input+rcx]

	;solamente si es una ecuacion sin variables, se salta el procedimiento
	cmp bl, 10
	je .done

	;busca el inicio de la seccion de variables
	cmp bl, ','
	je .inicio

	inc rcx

	jmp .cortar_letras_loop

;agrega solamente las variables como x=10,y=20, sin espacios
.inicio:
	xor rbx, rbx
	mov bl, byte[input+rcx]

	; se ha llegado al final del input
	cmp bl, 10
	je .fin

	inc rcx
	cmp bl, " "
	je .inicio ;no se agregan los espacios

	mov [equation+rax], bl
	inc rax

	jmp .inicio

;se ha llegado al final del input
.fin:
	dec rcx
	mov bl, byte[input+rcx]

	;si no tiene una coma, se le agrega
	cmp bl, ','
	jne .agregar_coma

	inc rcx

	mov bl, 10
	mov [equation+rax], bl
	print equation_len, equation
	ret

;si no se le agrego una coma, se le agrega al final
.agregar_coma:
	inc rcx

	mov bl, ','
	mov [equation+rax], bl

	inc rcx
	inc rax

	mov bl, 10
	mov [equation+rax], bl
	print equation_len, equation
	ret

;solamente si es una ecuacion sin variables
;se salta el procedimiento
;no tiene que corregir el input de variables
.done:
	mov bl, 10
	mov [equation+rax], bl
	print equation_len, equation
	ret	

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
; Validar si un caracter es una letra
; rbx (bl) tiene el caracter
; --------------------------------------
IS_LETRA:
	;Rango de 97 a 122
	cmp bl, 97 ; validacion <97
	jl .not_letra

	cmp bl, 122 ; validacion >122
	jg .not_letra

.letra:
	mov rdx, 1
	ret

.not_letra:
	xor rdx, rdx
	ret

; --------------------------------------
; Validar si un caracter es un parentesis inicial
; rbx (bl) tiene el caracter
; --------------------------------------
IS_PARENTESIS_INICIAL:
	cmp bl, 40 ; (
	je .parentesis_inicial

	cmp bl, 91 ; [
	je .parentesis_inicial

	cmp bl, 123 ; {
	je .parentesis_inicial

	jmp .not_parentesis_inicial

.parentesis_inicial:
	mov rdx, 1
	ret

.not_parentesis_inicial:
	xor rdx, rdx
	ret

; --------------------------------------
; Validar si un caracter es un parentesis final
; rbx (bl) tiene el caracter
; --------------------------------------
IS_PARENTESIS_FINAL:
	cmp bl, 41 ; )
	je .parentesis_final

	cmp bl, 93 ; ]
	je .parentesis_final

	cmp bl, 125 ; }
	je .parentesis_final

	jmp .not_parentesis_final

.parentesis_final:
	mov rdx, 1
	ret

.not_parentesis_final:
	xor rdx, rdx
	ret

; --------------------------------------
; Modificar la ecuacion ingresada
; rax: contador de ecuacion nueva
; rdx: (dl) en caso de necesitar agregar un caracter
; rcx: contador de datoEntrada (ecuacion anterior)
; rbx: (bl) tiene el caracter
;
; El procedimiento consiste en crear
; una ecuacion nueva que modifique la
; ingresada, tanto para validar como
; para operar
; Ejemplo = 2x = 2*x
; --------------------------------------
modificarEQ:
	xor rax, rax
	xor rdx, rdx
	xor rcx, rcx
	xor rbx, rbx

	mov bl, byte[datoEntrada+rcx] ;toma un byte

	mov byte[nueva_ecuacion+rax], bl ;lo mueve a una nueva variable

	inc rcx ;contador de datoEntrada
	inc rax ;contador de ecuacion

	;Si un caracter es numero, letra, operador o parentesis
	is_something IS_NUMERO
	je .numero

	is_something IS_LETRA
	je .letra

	is_something IS_OPERADOR
	je .operador

	is_something IS_PARENTESIS_INICIAL
	je .parentesis_inicial

	is_something IS_PARENTESIS_FINAL
	je .parentesis_final

	jmp reprobado ;Sino, no es valido

;Si el caracter es numero
.numero:
	xor rbx, rbx
	mov bl, byte[datoEntrada+rcx]
	inc rcx

	cmp bl, 10
	je .fin

	is_something IS_NUMERO
	je .numero_numero

	is_something IS_LETRA
	je .numero_letra

	is_something IS_OPERADOR
	je .factor_operador

	is_something IS_PARENTESIS_INICIAL
	je .factor_parentesisinicial

	is_something IS_PARENTESIS_FINAL
	je .factor_parentesisfinal

	jmp reprobado

;Combinaciones posibles
.numero_numero: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .numero

.numero_letra: ;2x = 2*x
	xor rdx, rdx
	mov dl, '*'

	mov byte[nueva_ecuacion+rax], dl
	inc rax

	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .letra

.factor_operador: ;2+ x+ )+ sin cambios

	is_something IS_MENOS
	je .factor_menos

	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .operador

.factor_menos: ;2- = 2+- x- = x+- )- = )+-
	xor rdx, rdx
	mov dl, '+'

	mov byte[nueva_ecuacion+rax], dl
	inc rax

	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .operador

.factor_parentesisinicial: ;2( = 2*( x( = x*( )( = )*( 
	xor rdx, rdx
	mov dl, '*'

	mov byte[nueva_ecuacion+rax], dl
	inc rax

	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .parentesis_inicial

.factor_parentesisfinal: ; sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .parentesis_final

;Si el caracter es letra
.letra:
	xor rbx, rbx
	mov bl, byte[datoEntrada+rcx]
	inc rcx

	cmp bl, 10
	je .fin

	is_something IS_LETRA
	je .letra_letra

	is_something IS_OPERADOR
	je .factor_operador

	is_something IS_PARENTESIS_INICIAL
	je .factor_parentesisinicial

	is_something IS_PARENTESIS_FINAL
	je .factor_parentesisfinal

	jmp reprobado

;Combinaciones posibles
.letra_letra: ;xy = x*y
	xor rdx, rdx
	mov dl, '*'

	mov byte[nueva_ecuacion+rax], dl
	inc rax

	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .letra

;Si el caracter es operador
.operador:
	xor rbx, rbx
	mov bl, byte[datoEntrada+rcx]
	inc rcx

	cmp bl, 10
	je .fin

	is_something IS_NUMERO
	je .operador_pari_numero

	is_something IS_LETRA
	je .operador_pari_letra

	is_something IS_MENOS
	je .operador_menos

	is_something IS_PARENTESIS_INICIAL
	je .operador_parentesisinicial

	jmp reprobado

;Combinaciones posibles
.operador_pari_numero: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .numero

.operador_pari_letra: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .letra

.operador_menos: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .operador

.operador_parentesisinicial: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .parentesis_inicial

;Si el caracter es parentesis inicial (
.parentesis_inicial:
	xor rbx, rbx
	mov bl, byte[datoEntrada+rcx]
	inc rcx

	cmp bl, 10
	je .fin

	is_something IS_NUMERO
	je .operador_pari_numero

	is_something IS_LETRA
	je .operador_pari_letra

	is_something IS_MENOS
	je .pari_menos

	is_something IS_PARENTESIS_INICIAL
	je .pari_pari

	jmp reprobado

;Combinaciones posibles
.pari_menos: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .operador

.pari_pari: ;sin cambios
	mov byte[nueva_ecuacion+rax], bl
	inc rax

	jmp .parentesis_inicial

;Si el caracter es parentesis final )
.parentesis_final:
	xor rbx, rbx
	mov bl, byte[datoEntrada+rcx]
	inc rcx

	cmp bl, 10
	je .fin

	is_something IS_OPERADOR
	je .factor_operador

	is_something IS_PARENTESIS_INICIAL
	je .factor_parentesisinicial

	is_something IS_PARENTESIS_FINAL
	je .factor_parentesisfinal

	jmp reprobado

;Fin del procedimiento
.fin:
	mov byte[nueva_ecuacion+rax], bl
	print len_nueva_ecuacion, nueva_ecuacion
	ret

; procedimiento para reemplazar letras por numeros
change:
	xor rax, rax
	xor rcx, rcx
	mov al, 0xA
    mov rcx, operation_len-1
    mov byte [operation + rcx], al

    xor rax, rax
    xor rcx, rcx
    xor rbx, rbx
    xor rdx, rdx
    xor r11, r11

    ; buscar el final de la ecuacion 
    .end_of_equation:
        mov dl, byte[equation+rax]
        inc rax
        
        cmp dl, ','
        je .set_end

        ; si llega al final es por que no tiene
        ; valores para reemplazar
        cmp dl, 0xA
        je .copy_equation

        jmp .end_of_equation
    
    ; guarda la posicion final
    .set_end:
        xor r9, r9
        mov r9, rax
        jmp .read_equation

    ; copiar ecuacion en caso de que no tenga letras
    .copy_equation:
        xor rcx, rcx
        xor rbx, rbx

        .copy_loop:
            mov bl,  byte[equation+rcx]

            cmp bl, 0xA
            je .done

            mov byte[operation+rcx],bl
            inc rcx

            jmp .copy_loop

    ; lee la ecuacion
    .read_equation:
        mov bl, byte[equation+rcx]

        ; si es letra, buscar el valor de la letra
        is_something IS_LETRA
        je .set_value

        ; si esta en 0 y no es letra, significa que empieza
        ; con parentesis, entonces los agrega
        cmp rcx, 0
        je .add_brackets

        cmp bl, 0xA
        je .done

        ; si llega a la coma, significa que llego al final
        ; de la ecuacion
        cmp bl, ','
        je .done

        inc rcx

        jmp .read_equation

    ; agregar parentesis iniciales
    .add_brackets:
        inc r11
        mov byte[operation+rcx], bl
        inc rcx
        mov bl, byte[equation+rcx]

        is_something IS_LETRA
        je .read_equation

        jmp .add_brackets

    ; guarda la posicion donde quedo la ecuacionn
    .set_value:
        xor r10, r10
        mov r10, rcx
        jmp .find_value
    
    ; buscar el valor numerico de esa letra
    .find_value:
        xor rdx, rdx
        xor rax, rax
        mov rax, r9
        
        .find_loop:
            mov dl, byte[equation+rax]
            inc rax

            cmp bl, dl
            je .skip_equal
   
            jmp .find_loop
        
        ; saltar el signo de igual
        .skip_equal:
            inc rax
            mov rcx, r11 ; posicion donde quedo la "nueva ecuacion"
            jmp .add_number
        
        ; reemplaza la letra por el numero en la "nueva ecuacion"
        .add_number:           
            mov dl, byte[equation + rax]
            inc rax

            cmp dl, ','
            je .reset_value

            mov byte[operation + rcx], dl
            inc rcx

            jmp .add_number
        
        ; setea todo para continuar
        .reset_value:
            mov r11, rcx
            xor rbx, rbx
            xor rax, rax
            mov rax, r11
            xor rcx, rcx
            mov rcx, r10
            inc rcx
            jmp .next_stuff

        ; agrega los signos o parentesis que aparezcan despues de la letra
        .next_stuff:
            mov bl, byte[equation+rcx]
            is_something IS_LETRA
            jz .next_variable

            cmp bl, ','
            je .done

            mov byte[operation + rax], bl
            inc rcx
            inc rax

            jmp .next_stuff

        ; se prepara para buscar la siguiente variable
        .next_variable:
            xor r11, r11
            mov r11, rax
            xor rcx, rcx
            mov rcx, r10
            inc rcx  
            jmp .read_equation      

    .done:
    ret