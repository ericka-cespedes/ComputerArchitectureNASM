NAME = validate

$(NAME): $(NAME).o
	ld -o $(NAME) $(NAME).o

$(NAME).o: $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm

#touch cadena.asm si hay cambios
#make para ejecutar
