# Operaciones
# Entradas: 2 numeros enteros
# Restricciones: numeros enteros del 1 al 10 con resultados del 1 al 10.
# Salidas: 2 resultados enteros: suma y resta

.section .data
	texto: .string "Ingrese un numero entero: "
	longitud = . -texto
	texto2: .string "Ingrese otro numero entero: "
	longitud2 = . -texto2

	resultadoSuma: .string "Suma: "
	longitudSuma = . -resultadoSuma
	resultadoResta: .string "Resta: "
	longitudResta = . -resultadoResta

.section .bss
	.lcomm a, 2
	.lcomm b, 2
	.lcomm suma, 1
	.lcomm resta, 1

.section .text
	.globl _start

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

	#Cerrar
	mov $60, %rax
	mov $0, %rdi
	syscall

_printTexto:
	mov $1, %rax
	mov $1, %rdi
	mov $texto, %rsi
	mov $longitud, %rdx
	syscall
	ret

_printTexto2:
	mov $1, %rax
	mov $1, %rdi
	mov $texto2, %rsi
	mov $longitud2, %rdx
	syscall
	ret

_getA:
	mov $0, %rax
	mov $0, %rdi
	mov $a, %rsi
	mov $2, %rdx
	syscall
	ret

_getB:
	mov $0, %rax
	mov $0, %rdi
	mov $b, %rsi
	mov $2, %rdx
	syscall
	ret

_printSuma:
	mov $1, %rax
	mov $1, %rdi
	mov $resultadoSuma, %rsi
	mov $longitudSuma, %rdx
	syscall
	ret

_printResta:
	mov $1, %rax
	mov $1, %rdi
	mov $resultadoResta, %rsi
	mov $longitudResta, %rdx
	syscall
	ret

_opSuma:
	mov (a), %rax
	sub '0', %rax # restar '0' para convertirlo de ascii a decimal

	mov (b), %rdi
	sub '0', %rdi

	#suma
	add %rdi, %rax
	add '0', %rax # sumar '0' para convertirlo de decimal a ascii

	#almacenar el resultado en 'suma'
	mov %rax, (suma)

	ret

_printResultadoSuma:
	mov $1, %rax
	mov $1, %rdi
	mov $suma, %rsi
	mov $1, %rdx
	syscall
	ret

_opResta:
	mov (a), %rax
	sub '0', %rax # restar '0' para convertirlo de ascii a decimal

	mov (b), %rdi
	sub '0', %rdi

	#resta
	sub %rdi, %rax
	add '0', %rax # sumar '0' para convertirlo de decimal a ascii

	#almacenar el resultado en 'resta'
	mov %rax, (resta)

	ret

_printResultadoResta:
	mov $1, %rax
	mov $1, %rdi
	mov $resta, %rsi
	mov $1, %rdx
	syscall
	ret
