.org 0x00

start:
	ldi r28, (RAMEND & 0X00ff)
	ldi r29, (RAMEND>>8)
	out SPH, r29
	out SPL, r28

	//Inicializaci�n de pines de registros
	call init

Main_Loop:
	ldi r20, 0
	
	//se activa la entrada de energia al sensor ultras�nico (TRIGGER 1)
	call TRIGGER_ON
	cpi r20, 1
	breq moverServo

	call Delay //delay de 0.6ms al sensor ultras�nico

	call TRIGGER_OFF //LOW del trigger del sensor ultras�nico
	call Delay //delay de 0.6ms al sensor ultras�nico

	sbic PIND, 2 //siguiente instrucci�n en cado que el PND est� en 0 :(
	cbi PORTB, 5 //limpiar instrucciones del bit del registro del Puerto B

	sbis PIND, 2 //Siguiente instrucci�n si el ECHO est� en HIGH
	sbi PORTB, 5 //se enciende el LED

	call Delay //delay de 0.6ms del sensor ultras�nico
	rjmp Main_Loop
	ret

init:
	
	sbi DDRD, 1 //Se activa el output del trigger
	cbi DDRD, 2 //Set del ECHO para la entrada
	sbi DDRB, 5//set del pin para la entrada
	cbi PORTB, 5 //se apaga el led
	ret
//Delay de 0.4 para el sensor ultrs�nico

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
	inc r20
	ret

TRIGGER_OFF:
	cbi PORTD, 1
	dec r20
	ret

//PARTE DE CONFIGURCI�N DEL SERVO
moverServo:
	ldi r16, 0b00000010 //se habilita el pin 9 para el servo
	out DDRB, r16 //se carga la el input del pin 10
	cbi PORTB, 1 //Se habilita la lectura del puerto B
	ldi r17, 5 //R17 Funcionar� como contador para la repetici�n del pulso
	rcall loop
	rjmp start

loop:
	CPI r17, 0 //si el ciclo termin� se lanza a un LOOP infinito
	breq loopSecundario
	sbi PORTB,1 //se manda un 1 al puerto b (carga de bit)
	call delay15ms //delay de 1.5 ms
	cbi PORTB, 1 //se limpia el bit I/0
	call delay15ms //Delay de 1.5ms
	dec r17 //se decrementa el contador
	call delay15ms //delay 1.5ms
	rjmp loop

delay15ms:
    ldi  r18, 32
    ldi  r19, 36
L1: dec  r19
    brne L1
    dec  r18
    brne L1
	ret

loopSecundario:
	rjmp loopSecundario

