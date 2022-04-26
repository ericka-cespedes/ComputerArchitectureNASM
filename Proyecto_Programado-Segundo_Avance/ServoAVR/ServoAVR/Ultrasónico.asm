.org 0x00

start:
	ldi r28, (RAMEND & 0X00ff)
	ldi r29, (RAMEND>>8)
	out SPH, r29
	out SPL, r28

	//Inicialización de pines de registros
	call init

Main_Loop:
	//se activa la entrada de energia al sensor ultrasónico (TRIGGER 1)
	call TRIGGER_ON
	call Delay //delay de 0.6ms al sensor ultrasónico

	call TRIGGER_OFF //LOW del trigger del sensor ultrasónico
	call Delay //delay de 0.6ms al sensor ultrasónico

	sbic PIND, 2 //siguiente instrucción en cado que el PND esté en 0 :(
	cbi PORTB, 5 //limpiar instrucciones del bit del registro del Puerto B

	sbis PIND, 2 //Siguiente instrucción si el ECHO está en HIGH
	sbi PORTB, 5

	call Delay //delay de 0.6ms del sensor ultrasónico
	rjmp Main_Loop
	ret

init:
	
	sbi DDRD, 1 //Se activa el output del trigger
	cbi DDRD, 2 //Set del ECHO para la entrada
	sbi DDRB, 5//set del pin para la entrada
	cbi PORTB, 5 //se apaga el led
	ret
//Delay de 0.4 para el sensor ultrsónico
Delay:
	ldi r17, 50
SD_L1:
	ldi r18, 50
SD_L2: 
	dec r18
	brne SD_L2
	dec r17
	brne SD_L1
	ret

TRIGGER_ON:	
	sbi PORTD, 1
	ret

TRIGGER_OFF:
	cbi PORTD, 1
	ret


