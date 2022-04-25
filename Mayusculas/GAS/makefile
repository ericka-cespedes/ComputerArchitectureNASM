NAME = mayusculas_gas

$(NAME): $(NAME).o
	ld -o $(NAME) $(NAME).o

$(NAME).o: $(NAME).s
	as -o $(NAME).o $(NAME).s

#touch cadena.asm si hay cambios
#make para ejecutar
