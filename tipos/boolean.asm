;-------------------------------------------;
; CONVERSION DE STRING A BOOLEANO           ;
; Y LUEGO DE BOOLEANO A STRING              ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; Este programa pide un valor booleano      ;
; (1 o 0) por medio de la entrada estandar  ;
; y lo convierte a un boolean y luego lo    ;
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
extrn stringtoboolean:Far, print:Far, printBool:Far, inttobool:Far, stringtoint:Far, inttostring:Far, chartobool:Far, archivotobool:Far
Assume CS:codigo, DS:datos


datos segment

	mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaArchivo db 10,13,'Introduce el nombre del archivo: $'
	mensajeEntradaArchivoModo db 10,13,'Introduce el modo en el que desea abrir el archivo (0 = lectura, 1 = escritura, 2 = lectura y escritura): $'
	mensajeEntradaString db 10,13,'Introduce un string: $'
	mensajeEntradaChar db 10,13,'Introduce un caracter: $'
	mensajeEntradaDNA db 10,13,'Introduzca una cadena de DNA: $'
	mensajeSalida db 10,13,'El valor en un booleano es: $'
	
	valorstring db ?
	string db 32, 32 dup (?)
    true db '1 (vedadero)$'
    false db '0 (falso)$'

	valorint db ?
	stringInt db 6, 7 dup (?)
	integer dw 0

	valorArchivo db ?
	nombreArchivo db 32, 33 dup (?)
	modeArchivo db ?

	valorChar db ?
	char db ?


datos endS

codigo segment



inicio:
;---------------------------------------
;- Aqui va todo el codigo del programa -
;---------------------------------------
	
	; Se cargan los datos definidos en datos Segment
	mov ax, datos
	mov ds, ax		

;---------------------------------------
; STRING -> BOOL 
;---------------------------------------
	; Se imprime el mensaje para pedir un string 
	push offset mensajeEntradaString
	call print

	; se lee un string de la entrada estandar
	mov dx, offset string
	mov ah, 0ah
	int 21h

	; se convierte el string a un numero entero
	push offset valorstring
	push offset string
	call stringtoboolean
	
	; Se imprime el mensaje para mostrar el numero introducido
	push offset mensajeSalida
	call print

	push offset valorstring
	call printBool

;---------------------------------------
; INT -> BOOL 
;---------------------------------------
	; Se imprime el mensaje para pedir un booleano
	push offset mensajeEntradaEntero
	call print

	; se lee un entero
	mov dx, offset stringInt
	mov ah, 0ah
	int 21h


	push offset stringInt
	call stringtoint
	; el resultado de la conversion queda arriba en la pila
	pop ax
	mov integer, ax

	push offset valorint
	push offset integer
	call inttobool

	; Se imprime el mensaje para mostrar el numero introducido
	push offset mensajeSalida
	call print

	push offset valorint
	call printBool


;---------------------------------------
; CHAR -> BOOL 
;---------------------------------------

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

	push offset valorChar
	push offset char
	call chartobool

	push offset mensajeSalida
	call print

	push offset valorChar
	call printBool

;---------------------------------------
; ARCHIVO -> BOOL 
;---------------------------------------

	; Se imprime el mensaje para pedir un archivo
	push offset mensajeEntradaArchivo
	call print

	; se lee un string de la entrada estandar
	mov dx, offset nombreArchivo
	mov ah, 0ah
	int 21h

	push offset mensajeEntradaArchivoModo
	call print

	xor ax, ax
	mov ah, 01h
	int 21h
    sub al, 30h
	mov modeArchivo, al

	; se convierte el string a un numero entero
	push offset valorArchivo
	push offset modeArchivo
	push offset nombreArchivo
	call archivotobool
	
	push offset mensajeSalida
	call print

	push offset valorArchivo
	call printBool

fin:
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	