# Cadena
# Entradas: string cadena
# Restricciones: cadena de 100 bytes / caracteres
# Salidas: string cadena

.section .data
	texto: .string "Ingrese una cadena de caracteres: "
	longitud = . -texto

.section .bss
	.lcomm cadena, 100

.section .text
	.globl _start

_start:
	call _printTexto
	call _getInput
	call _printInput

	# Cerrar
	mov $60, %rax # system call 60 = exit
	mov $0, %rdi # return 0
	syscall

_printTexto:
	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $texto, %rsi
	mov $longitud, %rdx
	syscall
	ret

_getInput:
	mov $0, %rax
	mov $0, %rdi
	mov $cadena, %rsi
	mov $100, %rdx
	syscall
	ret

_printInput:
	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $cadena, %rsi
	mov $100, %rdx
	syscall
	ret
