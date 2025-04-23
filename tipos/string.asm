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

extrn stringtoint:Far, inttostring:Far, print:Far
Assume CS:codigo, DS:datos

datos segment
	mensajeEntradaBooleano db 10,13,'Introduzca un booleano (0/1): $'
	mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaChar db 10,13,'Introduzca un caracter: $'
	mensajeSalidaString db 10,13,'El valor convertido a string es: $'

	stringInt db 6, 7 dup(?)
	integer dw ?
	boolValue db ?
	stringBuffer db 6, 7 dup(?)
	character db ?
	charAsString db 2, 2 dup(?)
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
	mov charAsString+1, character

	push offset mensajeSalidaString
	call print
	mov dx, offset charAsString
	mov ah, 09h
	int 21h

	; FIN
	mov ax, 4c00h
	int 21h
codigo ends
end inicio
