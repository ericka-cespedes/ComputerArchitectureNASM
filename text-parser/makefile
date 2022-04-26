#generic makefile
NAME = case

$(NAME): $(NAME).o
	ld $(NAME).o -o $(NAME)

$(NAME).o: $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm

