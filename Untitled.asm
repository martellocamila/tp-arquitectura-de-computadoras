;******************************************************************************************
;Ejercicio 1 
;Programa que simula el funcionamiento de un termotanque 																					
;Velocidad de reloj: 4mhz									
;Perro Guardian: deshabilitado								
;Proteccion de codigo: OFF
;******************************************************************************************

						LIST	P=16F628A			;Tipo de PIC
						#INCLUDE <P16F628A.INC>		;Libreria
						ERRORLEVEL -302
						
;******************************************************************************************

CANT_AGUA_MAX		EQU 0x20
CANT_AGUA_ACTUAL	EQU 0x21
TEMP_AGUA			EQU 0x22
TEMP_MINIMA			EQU 0X23
TEMP_MAXIMA			EQU 0x24

CONTADOR_1			EQU 0x25	;Registros para los retardos
CONTADOR_2			EQU 0x26
CONTADOR_3			EQU 0x27						
						
;******************************************************************************************
						ORG 0x00		;Indica la direccion de la memoria de
										;programa donde situar la siguiente instruccion
;******************************************************************************************

INICIO

		BSF		STATUS,RP0					;Accedemos al banco 1
		MOVLW	B'11110000'					;Configuramos los bits RB0 RB1 RB2 RB3 como salida
		MOVWF	TRISB						;Almacenamos el valor en TRISB
		BCF		STATUS,RP0					;Volvemos al banco 0
		CLRF	PORTB

		MOVLW	D'110'						;Cargamos en w el valor de la CANT_AGUA_MAX
		MOVWF	CANT_AGUA_MAX				;Cargamos el valor de w en CANT_AGUA_MAX (CANT_AGUA_MAX = 110)
	
		MOVLW	D'50'						;Cargamos en w el valor inicial de CANT_AGUA_ACTUAL
		MOVWF	CANT_AGUA_ACTUAL			;Cargamos el valor de w en CANT_AGUA_ACTUAL (CANT_AGUA_ACTUAL = 50)	

RESTA_CANTIDADES 							;Hasta que la cantidad actual de agua sea igual a la cantidad maxima 

		SUBWF	CANT_AGUA_MAX,0				;Restamos CANT_AGUA_ACTUAL - CANT_AGUA_MAX	
		BTFSS	STATUS,Z					;Chequemos el bit Z del STATUS
		GOTO	ACCIONAR_BOMBA				;Si es 0 incrementamos el agua, si es 1 salta
		CALL	APAGAR_LED_BOMBA			;Apagamos el LED que indica que la bomba esta en accion
		CALL	LED_CANT_AGUA_ALCANZADA		;Encendemos el LED que indica que se llego a la cant de agua maxima
											;solo se prende por un segundo
		
		MOVLW 	D'20'						;Cargamos en w el valor de la TEMP_MINIMA
		MOVWF	TEMP_MINIMA					;Cargamos el valor de w en TEMP_MINIMA (TEMP_MINIMA = 20)

		MOVLW 	D'45'						;Cargamos en w el valor de la TEMP_MAXIMA
		MOVWF	TEMP_MAXIMA					;Cargamos el valor de w en TEMP_MAXIMA (TEMP_MAXIMA = 45)

		MOVLW 	D'25'						;Cargamos en w el valor incial de TEMP_AGUA
		MOVWF	TEMP_AGUA					;Cargamos el valor de w en TEMP_AGUA (TEMP_AGUA = 25)

RESTA_TEMPERATURAS 							;Cuando llega a la cantidad de agua, debemos verificar que la temperatura
											;sea igual a la TEMP_MAXIMA
		
		SUBWF	TEMP_MAXIMA,0				;Restamos TEMP_AGUA - TEMP_MAXIMA
		BTFSS	STATUS,Z					;Chequeamos el bit Z del STATUS
		GOTO	ENCENDER_RESISTENCIA		;Si la TEMP_AGUA < TEMP_MAXIMA, calentamos el agua,sino salta
		CALL 	LED_TEMP_MAXIMA_ALCANZADA	;Encendemos el LED que indica que se llego a la temp maxima
											;solo se prende por un segundo

		CALL	RETARDO_1_SEG				;Esperemos 1 segundo
		CALL	ABRIR_CANILLA				;Se abre la canilla y se comienza a decremantar el agua
		
		GOTO 	INICIO
					
;******************************************************************************************
; Subrutina para incrementar el agua actual
;******************************************************************************************

ACCIONAR_BOMBA
		
		CALL	ENCENDER_LED_BOMBA
		INCF	CANT_AGUA_ACTUAL,F		;Incrementamos en uno la CANT_AGUA_ACTUAL
		MOVFW	CANT_AGUA_ACTUAL		;Guardamos el valor en w
		GOTO	RESTA_CANTIDADES		;Volvemos a chequear 

;******************************************************************************************
; Subrutina para calentar el agua
;******************************************************************************************

ENCENDER_RESISTENCIA
		
		CALL	LED_AGUA_CALENTANDO		;Parpadeo del LED
		INCF	TEMP_AGUA,F				;Incrementamos en uno la TEMP_AGUA	
		MOVFW	TEMP_AGUA				;Guardamos el valor en w
		GOTO	RESTA_TEMPERATURAS		;Volvemos a chequear

;******************************************************************************************
; Subrutina para abrir la canilla
;******************************************************************************************	

ABRIR_CANILLA
		
		DECF	CANT_AGUA_ACTUAL,F		;La canilla se abre, es decir se comienza a decrementar el agua
		MOVLW	D'50'					;Movemos 50 a w (el valor al que debe llegar el agua actual)
		SUBWF	CANT_AGUA_ACTUAL,0		;Restamos 50 - CANT_AGUA_ACTUAL
		BTFSS	STATUS,Z				;Chequemos el bit Z del STATUS
		GOTO	ABRIR_CANILLA			;Si es 0 seguimos decrementando, si es 1 salta
		RETURN
				
;******************************************************************************************
; Subrutinas de LEDS
;******************************************************************************************

ENCENDER_LED_BOMBA
		
		BSF		PORTB,0			;Prendemos el LED en RB0
		CALL	RETARDO_1_SEG	;Retardo de 1 seg para que se vea bien
		RETURN

APAGAR_LED_BOMBA
		
		BCF		PORTB,0			;Apagamos el LED en RB0
		RETURN

LED_CANT_AGUA_ALCANZADA

		BSF		PORTB,1
		CALL	RETARDO_1_SEG
		BCF		PORTB,1
		RETURN

LED_AGUA_CALENTANDO

		BSF		PORTB,2
		CALL	RETARDO_1_SEG	;Retaro de 1 seg para el parpadeo
		BCF		PORTB,2
		CALL	RETARDO_1_SEG	;Retardo de 1 seg para que se vea bien
		RETURN

LED_TEMP_MAXIMA_ALCANZADA

		BSF		PORTB,3
		CALL	RETARDO_1_SEG
		BCF		PORTB,3
		RETURN
		 											
;******************************************************************************************
; Subrutinas de retardo
;******************************************************************************************

RETARDO_1_SEG

		MOVLW	D'10'
		MOVWF	CONTADOR_3
CICLO_3
		MOVLW	D'100'
		MOVWF	CONTADOR_2
CICLO_2
		MOVLW	D'250'
		MOVWF	CONTADOR_1
CICLO_1	
		NOP
		DECFSZ	CONTADOR_1,F
		GOTO	CICLO_1
		DECFSZ	CONTADOR_2,F
		GOTO	CICLO_2
		DECFSZ	CONTADOR_3,F
		GOTO	CICLO_3
		RETURN

		END