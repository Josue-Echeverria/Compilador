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
extrn stringtoint:Far, print:Far, inttostring:Far
Assume CS:codigo, DS:datos


datos segment

	mensajeEntradaString db 10,13,'Introduce un numero entero [65535,0] : $'
	mensajeEntradaChar db 10,13,'Introduce un caracter: $'
	mensajeEntradaArchivo db 10,13,'Introduce el nombre del archivo: $'
	mensajeEntradaBoolean db 10,13,'Introduzca un valor booleano: $'
	mensajeEntradaDNA db 10,13,'Introduzca una cadena de DNA: $'
	mensajeSalida db 10,13,'El valor en un entero es: $'

	char db ?
	stringfiedCharInt db 3 dup (?),'$'

	string db 6, 32 dup ('$')
	integer dw 0
			dw 0
	stringfiedInt db 6 dup (?),'$' 
	
datos endS

codigo segment


inicio:
;---------------------------------------
;- Aqui va todo el codigo del programa -
;---------------------------------------
	
	; Se cargan los datos definidos en datos Segment
	mov ax, datos
	mov ds, ax		


	; --------------------------------------------
	; CONVERTIR UN STRING A ENTERO
	; --------------------------------------------

	; Se imprime el mensaje para pedir string 
	push offset mensajeEntradaString
	call print

	; se lee un string
	mov dx, offset string
	mov ah, 0ah
	int 21h

	; Se pasa el string a entero
	push offset string
	call stringtoint
	; el resultado de la conversion queda arriba en la pila
	pop ax
	mov integer, ax

	; se convierte el numero entero a un string para mostrarlo
    mov ax, integer
	mov bx, offset stringfiedInt
	add bx, 5 
	call inttostring

	; Se imprime el mensaje para mostrar el numero introducido
	push offset mensajeSalida
	call print

	; Se imprime el numero entero pasado a string
	push offset stringfiedInt
	call print

	; --------------------------------------------
	; CONVERTIR UN CARACTER A ENTERO
	; --------------------------------------------
	
	; Se imprime el mensaje para pedir un caracter
	push offset mensajeEntradaChar
	call print

	; se lee un caracter
	; el caracter ya se lee como un numero 
	; por lo que no es necesario convertirlo a entero
	xor ax, ax
	mov ah, 01h
	int 21h
	mov char, al

	; se convierte el numero entero a un string para mostrarlo
	xor ax, ax
    mov al, char
	mov bx, offset stringfiedCharInt
	add bx, 2
	call inttostring

	; Se imprime el mensaje para mostrar el numero introducido
	push offset mensajeSalida
	call print

	; Se imprime el numero entero pasado a string
	push offset stringfiedCharInt
	call print
	
	; --------------------------------------------
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR booleano A ENTERO
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
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR EL ARCHIVO A ENTERO
	; --------------------------------------------


	; --------------------------------------------
	; AQUI DEBERIA DE IR EL CODIGO PARA CONVERTIR EL DNA A ENTERO
	; --------------------------------------------


	
fin:
    ; Interrupcion para terminar la ejecucion del programa
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	