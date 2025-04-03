;-------------------------------------------;
; CONVERSION DE STRING A ENTERO             ;
; Y LUEGO DE ENTERO A STRING                ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; Este programa pide un numero entero entre ;
; 65535 y 0 medio de la entrada estandar y  ;
; lo convierte a un numero entero y luego lo;
; convierte a un string para mostrarlo en   ;
; la salida estandar.                       ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l int                        ;
;    tlink /v int                           ;
;                                           ;
; Fecha de creacion: Marzo 03, 2025.        ;
;-------------------------------------------;
extrn stringtoint:Far, print:Far
Assume CS:codigo, DS:datos


datos segment

	mensajeEntradaString db 10,13,'Introduce un numero entero [65535,0] : $'
	mensajeEntradaChar db 10,13,'Introduce un caracter: $'
	mensajeEntradaArchivo db 10,13,'Introduce el nombre del archivo: $'
	mensajeEntradaBoolean db 10,13,'Introduzca un valor booleano: $'
	mensajeEntradaDNA db 10,13,'Introduzca una cadena de DNA: $'
	mensajeSalida db 10,13,'El valor en un entero es: $'

	mensajeErrorOverflow db 10,13,'Error: Overflow en la conversion de string a entero $'
	mensajeErrorNoInt db 10,13,'Error: No se introdujo un numero entero $'
	string db 6, 32 dup ('$')
	integer dw 0
	stringfiedInt db 6 dup (?),'$' 
	
datos endS

codigo segment

; stringtoint macro 
; 	xor bx, bx
; 	xor cx, cx
; 	mov bl, string[1] ; longitud de la cadena
; 	inc bx
; 	mov dx, 1
; loopStringtoInt:
; 	xor ax, ax
; 	mov al, string[bx]
; 	sub al, 30h
; 	cmp al, 9
; 	ja noIntError
; 	push dx
; 	mul dx
; 	jo overflowError
; 	add integer, ax
; 	pop ax
; 	mov dx, 10
; 	mul dx
; 	mov dx, ax
; 	dec bx
; 	cmp bx, 1
; 	jne loopStringtoInt
; endM


inttostring macro 
	mov cx, 10
	mov bx, 5
	mov ax, integer
loopInttoString:
	xor dx, dx
	div cx
	add dx, 0030h
	mov stringfiedInt[bx], dl
	dec bx
	cmp ax, 0
	jne loopInttoString
endM


inicio:
;---------------------------------------
;- Aqui va todo el codigo del programa -
;---------------------------------------
	
	; Se cargan los datos definidos en datos Segment
	mov ax, datos
	mov ds, ax		

	; Se imprime el mensaje para pedir un numero 
	; push offset mensajeEntradaString
	; call print

	; ; se lee un numero entero
	mov dx, offset string
	mov ah, 0ah
	int 21h

	; push offset integer
	push offset string
	call stringtoint

	pop ax
	mov integer, ax
	; --------------------------------------------
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR EL STRING A ENTERO
	; --------------------------------------------

	; Se imprime el mensaje para pedir un caracter
	; mov dx, offset mensajeEntradaChar
	; mov ah, 9
	; int 21h

	; se lee un caracter
	; mov dx, offset string
	; mov ah, 0ah
	; int 21h

	; --------------------------------------------
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR EL CARACTER A ENTERO
	; --------------------------------------------
	
	; Se imprime el mensaje para pedir un nombre de archivo
	; mov dx, offset mensajeEntradaArchivo
	; mov ah, 9
	; int 21h

	; se lee un nombre de archivo
	;mov dx, offset string
	;mov ah, 0ah
	;int 21h

	; --------------------------------------------
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR EL ARCHIVO A ENTERO
	; --------------------------------------------








	; se convierte el string a un numero entero


	; se convierte el numero entero a un string
	inttostring
	
	; Se imprime el mensaje para mostrar el numero introducido
	push offset mensajeSalida
	call print

	; Se imprime el numero entero pasado a string
	push offset stringfiedInt
	call print
	jmp fin
	
overflowError:
	mov dx, offset mensajeErrorOverflow 
	mov ah, 9
	int 21h
	jmp fin

noIntError:
	mov dx, offset mensajeErrorNoInt
	mov ah, 9
	int 21h
	jmp fin
fin:
    ; Interrupcion para terminar la ejecucion del programa
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	