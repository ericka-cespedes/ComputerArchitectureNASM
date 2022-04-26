; ******************************************************************
; Autores: Ericka Cespedes
;          Sara Castro
;          Jose David Martinez

; Descripcion:
;     Este programa abre un archivo de texto plano y 
;     cambia las letras de minuscula a mayuscula o viceversa
;     segun la opcion que el usuario seleccione.

;     Al final despliega el conteo total de palabras y letras
;     asi como la cantidad de letras que cambiaron y su porcentaje

; ******************************************************************

%define SYS_EXIT 60
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define ENOENT -2

%define SIZE 2048

section .text
global _start

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
; set values 2
;     1 - caracter mas bajo, a o A
;     2 - caracter mas alto, z o Z
; --------------------------------

%macro setValues 2
    mov rbx, %1 ; lowest char, A or a
    mov rdx, %2 ; highest char, Z or z
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
; set_int_string  3
;     set de registros para
;     hacer conversion
;     1 - numero
;     2 - tira
;     3 - tamano de tira
; --------------------------------

%macro set_int_string 3
    mov rax, %1
    mov rsi, %2
    mov rbp, %3-2
%endmacro

_start:
    mov al, 0xA
    mov rcx, 20
    mov byte [changed_case + rcx], al
    mov byte [letters + rcx], al
    mov byte [percentage + rcx], al
    mov byte [words + rcx], al

    print welc_len, welc
    print intr_len, intr
    read input_len, input
    call set_file_name
    print space_len, space
    call open
    print space_len, space
    call menu
    print space_len, space
    call print_statistics

    exit

; --------------------------------------
;  Abre el archivo
; --------------------------------------
open:
    ; open file
    mov rdi, file_name
    mov rsi, 0
    mov rdx, 0
    mov rax, SYS_OPEN 
    syscall

    mov [file_descriptor], rax

    cmp rax, ENOENT
    je .error

    ; read file
    mov rdi, [file_descriptor]
    mov rax, SYS_READ 
    mov rsi, buffer
    mov rdx, SIZE
    syscall

    ; close file
    mov rax, SYS_CLOSE 
    mov rdi, file_descriptor
    syscall  

    print buffer_len, buffer

    ret

    .error:
    print err_len, err
    exit

; --------------------------------------
; Despliega el menu de opciones
; --------------------------------------
menu:
    print menu_len, menu_msg
    print lower_len, lower_msg
    print upper_len, upper_msg
    print exit_len, exit_msg

    menu_loop:
    read option_len, option
    xor rcx, rcx
    mov bl, byte [option + rcx]

    cmp bl, '1'
    jb menu_loop
    cmp bl, '3'
    ja menu_loop

    cmp bl, '1'
    je lower_upper
    cmp bl, '2'
    je upper_lower
    cmp bl, '3'
    je exit

    .exit:
    exit
    ret

; --------------------------------------
; setea los valores para conversion
; de mayuscula  a minuscula
; y llama al conversor
; --------------------------------------
upper_lower:
    print space_len, space
    setValues 'A', 'Z'
    call parseText
    print newLen, newText
    ret

; --------------------------------------
; setea los valores para conversion
; de minuscula  a mayuscula
; y llama al conversor
; --------------------------------------
lower_upper:
    print space_len, space
    setValues 'a', 'z' 
    call parseText
    print newLen, newText
    ret

; --------------------------------------
; Convierte los caracteres
; y lleva la cuenta de caracteres
; y palabras
; --------------------------------------
parseText:
    xor rax, rax    ; char
    xor rcx, rcx ; counter
    xor r8, r8 ; changed
    xor r9, r9 ; letter_count
    xor r10, r10 ; word_count
    xor r11, r11

    getChar:
    mov al, byte[buffer + rcx]
    cmp al, 0
    je done

    cmp al, 0x20 ; is it a space?
    je count_word

    cmp al, 0xA ; is it a new line?
    je count_word

    continue:
    cmp al, bl
    jb add_char

    cmp al, dl
    ja add_char   

    inc r8
    xor al, 0x20
    jmp add_char

    add_char:
    mov byte[newText + rcx], al
    inc rcx
    call is_letter
    jmp getChar

    count_word:
    cmp r11, 0
    je continue
    jg inc_count

    inc_count:
    xor r11, r11
    inc r10 ; word count ++
    jmp continue

    done:
    ret

; --------------------------------------
; incrementa la cuenta de caracteres
; --------------------------------------

is_letter:
    ;Errores inmediatos
    cmp al, 65 ; validacion <65
    jl not_letra

    cmp al, 122 ; validacion >122
    jg not_letra

    ;Rango de 65 a 122
    cmp al, 91 ; validacion <61
    jl letra

    cmp al, 96 ; validacion >96
    jg letra

    ;Sino error
    letra:
    inc r9
    inc r11
    ret

    not_letra:
    nop
    ret

; --------------------------------------
; Conversion de numero a caracter
; -------------------------------------- 

int_string:
    ; rax number
    ; rsi result string
    xor rbx, rbx
    mov rbx, rbp ; counter, result string len

    _doop:
    xor rdx, rdx
    mov rcx, 10
    div rcx

    push rax
    or rax, rdx
    pop rax
    jz done

    add rdx, '0'
    mov byte [rsi + rbx], dl
    dec rbx

    jmp _doop

; --------------------------------------
; Imprime las estadisticas
; --------------------------------------

print_statistics:
    print stats_len, stats
    set_int_string r10, words, words_len
    call int_string
    print word_count_len, word_count
    print words_len, words

    set_int_string r8, changed_case, changed_len
    call int_string
    print case_changed_len, case_changed
    print changed_len, changed_case

    set_int_string r9, letters, letters_len
    call int_string
    print letter_count_len, letter_count
    print letters_len, letters

    call division
    set_int_string rax, percentage, percentage_len
    call int_string
    print p_changed_len, p_changed
    print percentage_len, percentage
    ret

; --------------------------------------
; Calcula el porcentaje de caracteres
; que cambiaron
; --------------------------------------
division:
    mov rax, r8
    imul rax, 100

    xor rdx, rdx
    mov rcx, r9
    div rcx
    
    ret

set_file_name:
    xor rcx, rcx
    xor rax, rax

    foop:
    mov al, byte[input + rcx]
    cmp al, 0xA
    je finish

    mov byte [file_name + rcx], al
    inc rcx
    jmp foop

    finish:
    mov byte [file_name + rcx], 0
    ret

section .bss
    buffer resb SIZE
    buffer_len equ $-buffer

    newText resb  SIZE
    newLen equ $-newText

    option resb 21
    option_len equ $-option

    file_name resb 20
    file_name_len equ $-file_name

    file_descriptor resb 1

    changed_case resb 21
    changed_len equ $-changed_case

    letters resb 21
    letters_len equ $-letters

    percentage resb 21
    percentage_len equ $-percentage

    words resb 21
    words_len equ $-words

    input resb 20
    input_len equ $-input

section .data
    
    welc db "Bienvenidos", 0xa
    welc_len equ $-welc

    intr db "Escriba el nombre del archivo que desea abrir:", 0xa
    intr_len equ $-intr

    space db "",0xA
    space_len equ $-space

    menu_msg db "==== MENU ====", 0xa
    menu_len equ $-menu_msg

    stats db "==== STATISTICS ====", 0xa
    stats_len equ $-stats

    lower_msg db "1. Lower to upper", 0xA
    lower_len equ $-lower_msg

    upper_msg db "2. Upper to lower", 0xA
    upper_len equ $-upper_msg

    exit_msg db "3. Exit", 0xA
    exit_len equ $-exit_msg

    word_count db "Word count: "
    word_count_len equ $-word_count

    letter_count db "Letter count: "
    letter_count_len equ $-letter_count

    case_changed db "Letter case changed: "
    case_changed_len equ $-case_changed

    p_changed db "Percentage changed: "
    p_changed_len equ $-p_changed 

    err db "Error: could not open file",0xA
    err_len equ $-err
