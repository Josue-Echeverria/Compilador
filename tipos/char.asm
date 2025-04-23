;-------------------------------------------;
; CONVERSION DE TIPOS A CHAR                ;
;                                           ;
; Creado por: Quirós Harlen                 ;
;                                           ;
; Descripcion: convierte booleano, entero,  ;
; string (promedio) a char y los muestra.   ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l int                        ;
;    tlink /v int                           ;
;                                           ;
; Fecha de creacion: Marzo 03, 2025.        ;
;-------------------------------------------;

extrn stringtoint:Far, stringtoboolean:Far, print:Far
Assume CS:codigo, DS:datos

datos segment
	mensajeEntradaBooleano db 10,13,'Introduzca un booleano (0/1): $'
	mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaString db 10,13,'Introduzca un string: $'
	mensajeSalidaChar db 10,13,'El caracter resultante es: $'

	stringInt db 6, 7 dup(?)
	integer dw ?
	boolValue db ?
	stringBuffer db 32, 32 dup(?)
	character db ?
datos ends

codigo segment
inicio:
	mov ax, datos
	mov ds, ax

	;---------------------------------------
	; BOOLEANO -> CHAR
	;---------------------------------------
	push offset mensajeEntradaBooleano
	call print
	mov ah, 01h
	int 21h
	sub al, 30h
	mov boolValue, al

	; Convertir booleano a char ('0' o '1')
	mov al, boolValue
	add al, 30h
	mov character, al

	push offset mensajeSalidaChar
	call print
	mov dl, character
	mov ah, 02h
	int 21h

	;---------------------------------------
	; ENTERO -> CHAR
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

	mov al, byte ptr integer
	mov character, al

	push offset mensajeSalidaChar
	call print
	mov dl, character
	mov ah, 02h
	int 21h

	;---------------------------------------
	; STRING -> CHAR (promedio truncado)
	;---------------------------------------
	push offset mensajeEntradaString
	call print
	mov dx, offset stringBuffer
	mov ah, 0ah
	int 21h

	; Calcular promedio de ASCII
	mov si, offset stringBuffer+2
	mov cl, [stringBuffer+1]
	xor ax, ax
	xor bx, bx
sumarAscii:
	mov dl, [si]
	add ax, dx
	inc si
	inc bx
	loop sumarAscii
	xor dx, dx
	div bx
	mov character, al

	push offset mensajeSalidaChar
	call print
	mov dl, character
	mov ah, 02h
	int 21h

	; FIN
	mov ax, 4c00h
	int 21h
codigo ends
end inicio
