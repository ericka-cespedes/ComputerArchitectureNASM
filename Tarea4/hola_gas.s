.section .data
	mensaje: .string "hola mundo \n"
	longitud = . -mensaje

.section .text
	.globl _start

_start:
	movl $longitud,%edx
	movl $mensaje,%ecx
	movl $1,%ebx
	movl $4,%eax
	int $0x80

	movl $0,%ebx
	movl $1,%eax
	int $0x80
