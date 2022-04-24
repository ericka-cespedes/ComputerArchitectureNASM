;hola mundo
section .data
	mensaje db "hola mundo", 0xa
	longitud equ $ - mensaje

section .text
	global _start

_start:
	mov rdx, longitud
	mov rsi, mensaje
	mov rdi, 1
	mov rax,1
	syscall

	mov rax,60
	syscall

;nasm -f elf64 hola.asm
;ld -o hola hola.o
;./hola
