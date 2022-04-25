# Cadena
# Entradas: string cadena
# Restricciones: cadena de 100 bytes / caracteres
# Salidas: string cadena

.section .data
	texto: .string "Ingrese una cadena de caracteres: "
	longitud = . -texto

	error: .string "Caracteres invalidos."
	longitudError = . -error

	texto2: .string "Resultado: "
	longitud2 = . -texto2

.section .bss
	.lcomm cadena, 100
	.lcomm resultado, 100

.section .text
	.globl _start

_start:
	call PRINT_TEXTO
	call GET_INPUT
	call VALIDACIONES
	call CONVERSIONES
	call PRINT_RESULTADO

	# Cerrar
	mov $60, %rax # system call 60 = exit
	mov $0, %rdi # return 0
	syscall

PRINT_TEXTO:
	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $texto, %rsi
	mov $longitud, %rdx
	syscall
	ret

GET_INPUT:
	mov $0, %rax
	mov $0, %rdi
	mov $cadena, %rsi
	mov $100, %rdx
	syscall
	ret

VALIDACIONES:
	xor %rcx, %rcx #rcx = 0

.validaciones_loop:
	xor %rbx, %rbx #rbx = 0
	mov byte($cadena+%rcx), %bl
	inc %rcx

	cmp $10, %bl #termina
	je .fin

	#Errores inmediatos
	cmp $65, %bl #validacion <65
	jl .error

	cmp $122, %bl #validacion >122
	jg .error

	#Rango de 65 a 122
	cmp $91, %bl #validacion <61
	jl .validaciones_loop

	cmp $96, %bl #validacion >96
	jg .validaciones_loop

	#Sino error

.error:
	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $error, %rsi
	mov $longitudError, %rdx
	syscall

	mov $60, %rax # system call 60 = exit
	mov $0, %rdi # return 0
	syscall

.fin:
	ret

CONVERSIONES:
	xor %rbx, %rbx #rbx = 0
	xor %rcx, %rcx #rcx = 0

.conversiones_loop:
	mov byte($cadena+%rcx), %bl

	cmp $10, %bl #termina
	je .fin

	xor $0x20, %bl

	mov byte($resultado+%rcx), %bl
	inc %rcx
	jmp .conversiones_loop

.fin:
	ret

PRINT_RESULTADO:
	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $texto2, %rsi
	mov $longitud2, %rdx
	syscall

	mov $1, %rax #write
	mov $1, %rdi #stdout
	mov $cadena, %rsi
	mov $100, %rdx
	syscall
	ret
