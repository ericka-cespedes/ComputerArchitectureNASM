; Cadena
; Entradas: string cadena
; Restricciones: cadena de 100 bytes / caracteres
; Salidas: string cadena

section .data
	texto db "Ingrese una cadena de caracteres: "
	longitud equ $ - texto

section .bss
	cadena resb 100

section .text
	global _start

_start:
	call _printTexto
	call _getInput
	call _printInput

	;Cerrar
	mov rax, 60
	mov rdi, 0
	syscall

_printTexto:
	mov rax, 1 ; rax = 1 output
	mov rdi, 1 ; rdi = 1 output
	mov rsi, texto
	mov rdx, longitud
	syscall
	ret ; return

_getInput:
	mov rax, 0 ; rax = 0 input
	mov rdi, 0 ; rdi = 0 input
	mov rsi, cadena
	mov rdx, 100
	syscall
	ret ; return

_printInput:
	mov rax, 1
	mov rdi, 1
	mov rsi, cadena
	mov rdx, 100
	syscall
	ret