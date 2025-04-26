;-------------------------------------------;
; CONVERSION DE TIPOS A STRING              ;
;                                           ;
; Creado por: Quiros Harlen                 ;
;                                           ;
; Descripcion: convierte booleano, entero,  ;
; char a string y los muestra.              ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l int                        ;
;    tlink /v int                           ;
;                                           ;
; Fecha de creacion: Marzo 03, 2025.        ;
;-------------------------------------------;

extrn stringtoint:Far, inttostring:Far, print:Far, archivotostring:Far
Assume CS:codigo, DS:datos

datos segment
	mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaBooleano db 10,13,'Introduzca un booleano (0/1): $'
	mensajeEntradaChar db 10,13,'Introduzca un caracter: $'
	mensajeSalidaString db 10,13,'El valor convertido a string es: $'
	mensajeEntradaArchivo db 10,13,'Introduzca el nombre del archivo: $'

	stringInt db 6, 7 dup(?)
	integer dw ?
	boolValue db ?
	stringBuffer db 6, 7 dup(?), '$'
	character db ?
	charAsString db 32 dup(?), '$'
	nombreArchivo db 32, 33 dup(?)
	archivo db 255 dup('$')
datos ends

codigo segment
inicio:
	mov ax, datos
	mov ds, ax

	;---------------------------------------
	; BOOLEANO -> STRING
	;---------------------------------------
	push offset mensajeEntradaBooleano
	call print
	mov ah, 01h
	int 21h
	sub al, 30h
	mov boolValue, al

	mov byte ptr stringBuffer, 1
	mov al, boolValue
	add al, 30h
	mov stringBuffer+1, al

	push offset mensajeSalidaString
	call print
	mov dx, offset stringBuffer
	inc dx
	mov ah, 09h
	int 21h

	;---------------------------------------
	; ENTERO -> STRING
	;---------------------------------------
	push offset mensajeEntradaEntero
	call print
	mov dx, offset stringInt
	mov ah, 0ah
	int 21h

	push offset stringInt
	call stringtoint
	pop ax
	mov integer, ax

	mov bx, offset stringBuffer+6
	push offset integer
	call inttostring

	push offset mensajeSalidaString
	call print
	mov dx, offset stringBuffer
	inc dx
	add dx, 1
	mov ah, 09h
	int 21h

	;---------------------------------------
	; CHAR -> STRING
	;---------------------------------------
	push offset mensajeEntradaChar
	call print

	mov ah, 01h
	int 21h
	mov character, al

	mov byte ptr charAsString, 1
	mov al, character
	mov charAsString+1, al

	push offset mensajeSalidaString
	call print
	mov dx, offset charAsString
	inc dx
	mov ah, 09h
	int 21h

	;---------------------------------------
	; ARCHIVO -> STRING 
	;---------------------------------------
	push offset mensajeEntradaArchivo
	call print

	mov dx, offset nombreArchivo
	mov ah, 0ah
	int 21h

	push offset archivo
	push offset nombreArchivo
	call archivotostring


	push offset mensajeSalidaString
	call print
	mov dx, offset archivo
	mov ah, 09h
	int 21h

	; FIN
	mov ax, 4c00h
	int 21h
codigo ends
end inicio
