start:
	rjmp LedManager

LedManager:
	call TURN_ON
	call delayLED
	call TURN_OFF
	call delayLED
	rjmp LedManager

TURN_ON:
	ldi r24, 0b00000001
	sts 0x25, r24
	ret

TURN_OFF:
	ldi r24, 0b00000000
	sts 0x25, r24
	ret

delayLED:
	ldi  r18, 82
    ldi  r19, 31
    ldi  r20, 4
L3: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	ret

loop2:
	rjmp loop2