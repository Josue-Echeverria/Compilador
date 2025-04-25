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
	mensajeEntradaArchivo db 10,13,'Introduzca el nombre del archivo: $'
	mensajeSalidaString db 10,13,'El valor convertido a string es: $'

	stringInt db 6, 7 dup(?)
	integer dw ?
	boolValue db ?
	stringBuffer db 6, 7 dup(?)
	caracter db ?
	charAsString db 2, 2 dup(?)
	nombreArchivo db 32, 33 dup(?)
	archivoBuffer db 32 dup(?)
	stringArchivo db 32 dup(?)
datos ends

codigo segment
inicio:
	mov ax, datos
	mov ds, ax

; BOOLEANO -> STRING
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
	call imprimir_string offset stringBuffer

; ENTERO -> STRING
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
	call imprimir_string offset stringBuffer

; CHAR -> STRING
	push offset mensajeEntradaChar
	call print
	mov ah, 01h
	int 21h
	mov caracter, al
	mov byte ptr charAsString, 1
	mov charAsString+1, caracter
	call imprimir_string offset charAsString

; ARCHIVO -> STRING
	push offset mensajeEntradaArchivo
	call print
	mov dx, offset nombreArchivo
	mov ah, 0ah
	int 21h
	mov ah, 3Dh
	lea dx, nombreArchivo+2
	xor al, al
	int 21h
	jc error
	mov bx, ax
	mov ah, 3Fh
	lea dx, archivoBuffer
	mov cx, 32
	int 21h
	mov ah, 3Eh
	int 21h
	mov cl, al
	mov [stringArchivo], cl
	mov si, offset archivoBuffer
	mov di, offset stringArchivo+1
	rep movsb
	call imprimir_string offset stringArchivo

; FIN
	mov ax, 4c00h
	int 21h

imprimir_string:
	push offset mensajeSalidaString
	call print
	mov dx, [bp+4]
	mov ah, 09h
	int 21h
	ret 2

error:
	mov ax, 4c00h
	int 21h
codigo ends
end inicio
