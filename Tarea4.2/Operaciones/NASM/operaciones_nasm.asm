; Operaciones
; Entradas: 2 numeros enteros
; Restricciones: numeros enteros del 1 al 10 con resultados del 1 al 10.
; Salidas: 2 resultados enteros: suma y resta

section .data
	texto db "Ingrese un numero entero: "
	longitud equ $ - texto
	texto2 db "Ingrese otro numero entero: "
	longitud2 equ $ - texto2

	resultadoSuma db "Suma: "
	longitudSuma equ $ - resultadoSuma
	resultadoResta db "Resta: "
	longitudResta equ $ - resultadoResta

section .bss
	a resb 2
	b resb 2
	suma resb 1
	resta resb 1

section .text
	global _start

_start:
	call _printTexto
	call _getA
	call _printTexto2
	call _getB
	call _printSuma
	call _opSuma
	call _printResultadoSuma
	call _printResta
	call _opResta
	call _printResultadoResta

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

_printTexto2:
	mov rax, 1 ; rax = 1 output
	mov rdi, 1 ; rdi = 1 output
	mov rsi, texto2
	mov rdx, longitud2
	syscall
	ret ; return

_getA:
	mov rax, 0 ; rax = 0 input
	mov rdi, 0 ; rdi = 0 input
	mov rsi, a
	mov rdx, 2
	syscall
	ret ; return

_getB:
	mov rax, 0 ; rax = 0 input
	mov rdi, 0 ; rdi = 0 input
	mov rsi, b
	mov rdx, 2
	syscall
	ret ; return

_printSuma:
	mov rax, 1
	mov rdi, 1
	mov rsi, resultadoSuma
	mov rdx, longitudSuma
	syscall
	ret

_printResta:
	mov rax, 1
	mov rdi, 1
	mov rsi, resultadoResta
	mov rdx, longitudResta
	syscall
	ret

_opSuma:
	mov rax, [a] ; mover a al registro rax
	sub rax, '0' ; restar ascii '0' para convertirlo a un numero decimal

	mov rdi, [b] ; mover b al registro rdi
	sub rdi, '0' ; convertirlo a numero decimal

	;suma
	add rax, rdi
	add rax, '0' ; sumar '0' para convertirlo de decimal a ascii

	;almacenar el resultado en 'suma'
	mov [suma], rax

	ret

_printResultadoSuma:
	mov rax, 1
	mov rdi, 1
	mov rsi, suma
	mov rdx, 1
	syscall
	ret

_opResta:
	mov rax, [a] ; mover a al registro rax
	sub rax, '0' ; restar ascii '0' para convertirlo a un numero decimal

	mov rdi, [b] ; mover b al registro rdi
	sub rdi, '0' ; convertirlo a numero decimal

	;resta
	sub rax, rdi
	add rax, '0' ; sumar '0' para convertirlo de decimal a ascii

	;almacenar el resultado en 'resta'
	mov [resta], rax

	ret

_printResultadoResta:
	mov rax, 1
	mov rdi, 1
	mov rsi, resta
	mov rdx, 1
	syscall
	ret