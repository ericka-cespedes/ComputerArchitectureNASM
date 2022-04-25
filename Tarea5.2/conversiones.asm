; Convertir un numero en decimal a decimal, binario, octal y hexadecimal
; Entradas: 1 numero entero en decimal
; Restricciones: numero de 64 bits
; Salidas: numero en decimal, binario, octal y hexadecimal

section .data
	bienvenida db "Bienvenidos. Este programa convierte de decimal a decimal, binario, octal y hexadecimal", 10, 0
	texto db "Ingrese un numero entero en decimal: ", 0
	texto_decimal db 10, "Decimal: ", 0
	texto_binario db 10, "Binario: ", 0
	texto_octal db 10, "Octal: ", 0
	texto_hexadecimal db 10, "Hexadecimal: ", 0
	error db "Numero invalido.", 10, 0
	space db 10, 0

section .bss
	input resb 64 ;input del usuario en decimal en ASCII

	resultado_decimal resb 64 ;resultado final

	binario resb 64 ;numero convertido al reves
	resultado_binario resb 64 ;resultado final

	octal resb 64 ;numero convertido al reves
	resultado_octal resb 64 ;resultado final

	hexadecimal resb 64 ;numero convertido al reves
	resultado_hexadecimal resb 64 ;resultado final

section .text
	global _start

_start:
	;Bienvenida
	mov rax, bienvenida
	call PRINT_TEXTO
	;Input
	mov rax, texto
	call PRINT_TEXTO
	call GET_INPUT

	;Conversion de ASCII a Decimal
	call ATOI

	;Input Invalido
	cmp rax, -1 ; ATOI hace un mov rax, -1 si el input es invalido
	je ERROR ; Imprime un msj de error

	;Conversion de INTs a ASCIIs
	;Conversion de Decimal a ASCII
	call ITOA
	;Conversion de Decimal a Binario en ASCII
	call ITOA_BINARIO ;Hace divisiones sucesivas y convierte a ASCII
	call REVES_BINARIO ;Le cambia el orden a los digitos
	;Conversion de Decimal a Octal en ASCII
	call ITOA_OCTAL ;Hace divisiones sucesivas y convierte a ASCII
	call REVES_OCTAL ;Le cambia el orden a los digitos
	;Conversion de Decimal a Hexadecimal en ASCII
	call ITOA_HEXADECIMAL ;Hace divisiones sucesivas y convierte a ASCII
	call REVES_HEXADECIMAL ;Le cambia el orden a los digitos
	
	;Imprimir Resultados
	;Decimal
	mov rax, texto_decimal ;Decimal:
	call PRINT_TEXTO
	mov rax, resultado_decimal ;resultado
	call PRINT_TEXTO

	;Binario
	mov rax, texto_binario ;Binario:
	call PRINT_TEXTO
	mov rax, resultado_binario ;resultado
	call PRINT_TEXTO

	;Octal
	mov rax, texto_octal ;Octal: 
	call PRINT_TEXTO
	mov rax, resultado_octal ;resultado
	call PRINT_TEXTO

	;Hexadecimal
	mov rax, texto_hexadecimal ;Hexadecimal:
	call PRINT_TEXTO
	mov rax, resultado_hexadecimal ;resultado
	call PRINT_TEXTO

	;Cuestiones esteticas, imprime fin de linea
	mov rax, space
	call PRINT_TEXTO

	jmp CERRAR

ERROR:
	mov rax, error
	call PRINT_TEXTO

CERRAR:
	mov rax, 60
	mov rdi, 0
	syscall

;input: rax contiene el string que se quiere imprimir
;output: print string en rax
PRINT_TEXTO:
	push rax ; texto original, se guarda en el stack
	xor rbx, rbx ; contador = 0
	xor rcx, rcx ; rcx = 0

.print_texto_loop:
	inc rax ; incrementa el rax para tomar el siguiente caracter
	inc rbx ; cantidad de caracteres que tiene el texto
	mov cl, [rax] ; toma un caracter del texto
	cmp cl, 0 ; cuando llega al final del texto
	jne .print_texto_loop

	mov rax, 1 ; output
	mov rdi, 1 ; output
	pop rsi ;se despliega lo que contenia rax al inicio
	mov rdx, rbx ; rdx = rbx (cantidad de caracteres)
	syscall

	ret

; Obtener un input
GET_INPUT:
	mov rax, 0 ; rax = 0 input
	mov rdi, 0 ; rdi = 0 input
	mov rsi, input ; rsi = input
	mov rdx, 8 ; 8 bytes
	syscall

	ret ; return

; Conversion de ASCIII a INT (INT en Decimal en este caso)
ATOI:
	xor rax, rax ; rax = resultado
	xor rcx, rcx ; rcx = contador

.convertir:
	mov rdx, 10 ; rdx = 10, divisor
	xor rbx, rbx ; rbx = 0, primer digito
	mov bl, byte[input+rcx] ; primer digito a =  numero y rcx = contador

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

.error: ; en la funcion _start si rax == -1 despliega un error
	mov rax, -1
	ret

.done:
	xor rdx, rdx ; rdx = 0 para que no cause error en div
	mov rbx, 10 ; rbx = 10
	div rbx ; rax = rdx:rax / rbx (10)

	ret

; Conversion de INT en decimal a ASCII
; rax contiene el numero
; rcx contiene la cantidad de digitos a convertir
ITOA:
	push rax ; rax = numero en decimal
	mov rbx, 10 ; rbx = 10, divisor

.itoa_loop:
	cmp rax, 0
	je .fin

	xor rdx, rdx ; rdx = 0 para que no cause error en div
	div rbx ; rax = rdx:rax / rbx (10)    rdx = rax%10
	add rdx, 48 ; conversion de decimal a ascii
	mov byte[resultado_decimal+rcx], dl ; inserta el digito menos significativo en la posicion rcx de resultado
	dec rcx ; rcx--
	jmp .itoa_loop

.fin:
	pop rax
	ret

; Conversion de INT en decimal a binario ASCII, se divide por 2 en vez de 10
ITOA_BINARIO:
	push rax
	mov rbx, 2 ; rbx = 10, divisor
	xor rcx, rcx

.itoa_loop:
	cmp rax, 0
	je .fin

	xor rdx, rdx ; rdx = 0 para que no cause error en div
	div rbx ; rax = rdx:rax / rbx (10)    rdx = rax%10
	add rdx, 00110000b ; conversion de decimal a ascii
	mov byte[binario+rcx], dl ; inserta el digito menos significativo en la posicion rcx de resultado
	inc rcx ; rcx++
	jmp .itoa_loop

.fin:
	mov byte[binario+rcx], 'G'
	pop rax
	ret

; Conversion de INT en decimal a octal ASCII, se divide por 8 en vez de 10
ITOA_OCTAL:
	push rax
	mov rbx, 8 ; rbx = 10, divisor
	xor rcx, rcx ; rcx = 0

.itoa_loop:
	cmp rax, 0
	je .fin

	xor rdx, rdx ; rdx = 0 para que no cause error en div
	div rbx ; rax = rdx:rax / rbx (10)    rdx = rax%10
	add rdx, 60q ; conversion de decimal a ascii
	mov byte[octal+rcx], dl ; inserta el digito menos significativo en la posicion rcx de resultado
	inc rcx ; rcx++
	jmp .itoa_loop

.fin:
	pop rax
	ret

; Conversion de INT en decimal a hexadecimal ASCII, se divide por 16 en vez de 10
ITOA_HEXADECIMAL:
	push rax
	mov rbx, 16 ; rbx = 10, divisor
	xor rcx, rcx ; rcx = 0

.itoa_loop:
	cmp rax, 0
	je .fin

	xor rdx, rdx ; rdx = 0 para que no cause error en div
	div rbx ; rax = rdx:rax / rbx (10)    rdx = rax%10

	cmp dl, 9 ;Numeros menores a letras que siguen siendo numeros
	jl .menor

	;Numeros mayores a 9 que son letras
	cmp dl, 10 ;dl=10
	je .diez

	cmp dl, 11 ;dl=11
	je .once

	cmp dl, 12 ;dl=12
	je .doce

	cmp dl, 13 ;dl=13
	je .trece

	cmp dl, 14 ;dl=14
	je .catorce

	cmp dl, 15 ;dl=15
	je .quince

.menor: ;Cambia un int <10 por ascii
	add rdx, 30h ; conversion de decimal a ascii
	jmp .add_char

.diez: ;Cambia el 10 por un 'A'
	xor rdx, rdx
	mov dl, 'A'
	jmp .add_char

.once: ;Cambia el 11 por un 'B'
	xor rdx, rdx
	mov dl, 'B'
	jmp .add_char

.doce: ;Cambia el 12 por un 'C'
	xor rdx, rdx
	mov dl, 'C'
	jmp .add_char

.trece: ;Cambia el 13 por un 'D'
	xor rdx, rdx
	mov dl, 'D'
	jmp .add_char

.catorce: ;Cambia el 14 por un 'E'
	xor rdx, rdx
	mov dl, 'E'
	jmp .add_char

.quince: ;Cambia el 15 por un 'F'
	xor rdx, rdx
	mov dl, 'F'
	jmp .add_char

.add_char: ;Agrega el caracter convertido en dl
	mov byte[hexadecimal+rcx], dl ; inserta el digito menos significativo en la posicion rcx de resultado
	inc rcx ; rcx++
	jmp .itoa_loop

.fin:
	pop rax
	ret

; Cambia el orden de los digitos de los numeros convertidos en ITOA
; binario = numero convertido al reves
; resultado_binario = binario al reves
REVES_BINARIO:
	xor rdx, rdx ;caracter
	xor rbx, rbx ;contador desde 0
	;rcx = longitud del numero convertido en ITOA_BINARIO

.reves_loop:
	cmp rcx, 0
	je .fin

	mov dl, byte[binario+rbx] ; binario + contador que empieza en 0
	mov byte[resultado_binario+rcx], dl ; resultado + lenBinario
	dec rcx ; rcx--
	inc rbx ; rbx++
	jmp .reves_loop

.fin:
	ret

; octal = numero convertido al reves
; resultado_octal = octal al reves
REVES_OCTAL:
	xor rdx, rdx ;caracter
	xor rbx, rbx ;contador desde 0
	;rcx = longitud del numero convertido en ITOA_OCTAL

.reves_loop:
	cmp rcx, 0
	je .fin

	mov dl, byte[octal+rbx] ; octal + contador que empieza en 0
	mov byte[resultado_octal+rcx], dl ; resultado + lenOctal
	dec rcx ; rcx--
	inc rbx ; rbx++
	jmp .reves_loop

.fin:
	ret

; hexadecimal = numero convertido al reves
; resultado_hexadecimal = hexadecimal al reves
REVES_HEXADECIMAL:
	xor rdx, rdx ;caracter
	xor rbx, rbx ;contador desde 0
	;rcx = longitud del numero convertido en ITOA_HEXADECIMAL

.reves_loop:
	cmp rcx, 0
	je .fin

	mov dl, byte[hexadecimal+rbx] ; hexadecimal + contador que empieza en 0
	mov byte[resultado_hexadecimal+rcx], dl ; resultado + lenHexadecimal
	dec rcx ; rcx--
	inc rbx ; rbx++
	jmp .reves_loop

.fin:
	ret