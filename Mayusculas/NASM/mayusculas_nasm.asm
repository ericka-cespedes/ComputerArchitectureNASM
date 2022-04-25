; Cadena
; Entradas: string cadena
; Restricciones: cadena de 100 bytes / caracteres
; Salidas: string cadena

section .data
	texto db "Ingrese una cadena de caracteres: "
	longitud equ $ - texto

	error db "Caracteres invalidos."
	longitudError equ $ - error

	texto2 db "Resultado: "
	longitud2 equ $ - texto2

section .bss
	cadena resb 100
	resultado resb 100

section .text
	global _start

_start:
	call PRINT_TEXTO
	call GET_INPUT
	call VALIDACIONES
	call CONVERSIONES
	call PRINT_RESULTADO

	;Cerrar
	mov rax, 60
	mov rdi, 0
	syscall

PRINT_TEXTO:
	mov rax, 1 ; rax = 1 output
	mov rdi, 1 ; rdi = 1 output
	mov rsi, texto
	mov rdx, longitud
	syscall
	ret ; return

GET_INPUT:
	mov rax, 0 ; rax = 0 input
	mov rdi, 0 ; rdi = 0 input
	mov rsi, cadena
	mov rdx, 100
	syscall
	ret ; return

VALIDACIONES:
	xor rcx, rcx ; rcx = 0

.validaciones_loop:
	xor rbx, rbx; rbx = 0
	mov bl, byte[cadena+rcx]
	inc rcx

	cmp bl, 10 ; termina
	je .fin

	;Errores inmediatos
	cmp bl, 65 ; validacion <65
	jl .error

	cmp bl, 122 ; validacion >122
	jg .error

	;Rango de 65 a 122
	cmp bl, 91 ; validacion <61
	jl .validaciones_loop

	cmp bl, 96 ; validacion >96
	jg .validaciones_loop

	;Sino error

.error:
	mov rax, 1
	mov rdi, 1
	mov rsi, error
	mov rdx, longitudError
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

.fin:
	ret

CONVERSIONES:
	xor rbx, rbx ; rbx = 0
	xor rcx, rcx ; rcx = 0

.conversiones_loop:
	mov bl, byte[cadena+rcx]

	cmp bl, 10 ; termina
	je .fin

	;Conversion de minuscula a mayuscula y viceversa
	xor bl, 0x20
	;Mayuscula o minuscula?
	; cmp al, 91 ; validacion <91
	; jb .rango_65_90 ; mayusculas

	; cmp al, 96 ; validacion >96
	; ja .rango_97_122 ; minusculas

	mov byte[resultado+rcx], bl
	inc rcx
	jmp .conversiones_loop

; ;Mayuscula a minuscula
; .rango_65_90:
; 	;bl = caracter
; 	;add bl, 32
; 	xor al, 0x20
; 	ret

; ;Minuscula a mayuscula
; .rango_97_122:
; 	;sub bl, 32
; 	xor al, 0x20
; 	ret

.fin:
	ret

PRINT_RESULTADO:
	mov rax, 1
	mov rdi, 1
	mov rsi, texto2
	mov rdx, longitud2
	syscall

	mov rax, 1
	mov rdi, 1
	mov rsi, resultado
	mov rdx, 100
	syscall
	ret