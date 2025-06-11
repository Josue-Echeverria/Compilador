;-------------------------------------------;
; RECIBE UNA CADENA DE DNA Y LUEGO SALE     ;
; POR LA SALIDA ESTANDAR                    ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; Este programa pide una cadena de DNA      ;
; (G, C, T, A) de un largo de maximo 1000   ; 
; bases por medio de la entrada             ;
; estandar y lo convierte a un boolean y    ;
; luego lo convierte a un string para       ;
; mostrarlo en la salida estandar.          ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l dna                        ;
;    tasm /zi /l lib                        ;
;    tlink /v dna lib                       ;
;                                           ;
; Fecha de creacion: Marzo 03, 2025.        ;
;-------------------------------------------;
extrn print:Far, stringtoint:Far
Assume CS:codigo, DS:datos


datos segment

	mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaString db 10,13,'Introduce un string : $'
	mensajeEntradaChar db 10,13,'Introduce un caracter: $'
	mensajeEntradaBooleano db 10,13,'Introduzca un valor booleano: $'
	mensajeEntradaArchivo db 10,13,'Introduce el nombre del archivo: $'
	mensajeSalida db 10,13,'El valor en DNA es: $'

	errorBooleano db 10,13,'Error: No se introdujo un booleano $'

	mensajeErrorNoDna db 10,13,'Error: No se introdujo una cadena de dna $'
	dna db 16, 16 dup ('0'), '$'
    readedDna db 16 dup (?), '$'

	entradaEntero db 6, 7 dup (?)
	integer dw ?
    readedEnteroDna db 16 dup (?), '$'

	boolValue db ?
    readedBoolDna db 16 dup (?), '$'

	char db ?
	readedCharDna db 16 dup (?), '$'

	nombreArchivo db 32, 32 dup (?)  
	readedArchivoDna db 255 dup (?), '$'
	contadorArchivo dw 0
	contadorDNA dw 0
	handle_pixels dw 0
	currentChar db ?

datos endS

codigo segment

stringtodna proc near
	xor bx, bx
	xor cx, cx
	mov bl, dna[1] ; longitud de la cadena
    inc bx
	loopStringtoDna:
		xor ax, ax
		mov al, dna[bx]
		cmp al, 'G'
		je esDna
		cmp al, 'C'
		je esDna
		cmp al, 'T'
		je esDna
		cmp al, 'a'
		je esDna
		cmp al, 'g'
		je esDna
		cmp al, 'c'
		je esDna
		cmp al, 't'
		je esDna
		cmp al, 'a'
		je esDna
		jmp noDnaError
	esDna:
		mov readedDna[bx], al
		dec bx
		cmp bx, 1
		jne loopStringtoDna
		jmp finstringtodna
	noDnaError:
		mov dx, offset mensajeErrorNoDna
		mov ah, 9
		int 21h
		mov ax, 4c00h 
		int 21h 	 	
	finstringtodna:
		ret 4
endP

enterotodna proc near
		mov ax, integer
		xor cx, cx        ; Clear CX (digit count)
		cmp ax, 0         ; Check if the number is 0
		jne countLoop
		mov cx, 1         ; If the number is 0, it has 1 digit
		jmp writedna
	countLoop:
		xor dx, dx        ; Clear DX for division
		mov bx, 10        ; Divisor is 10
		div bx            ; AX = AX / 10, DX = remainder
		inc cx            ; Increment digit count
		cmp ax, 0         ; Check if AX is 0
		jne countLoop     ; Repeat until AX is 0
	writedna:
		cmp cx, 1
		jne siguiente1
		mov readedEnteroDna[0], 'G'
		jmp finenterotodna
		siguiente1:
		cmp cx, 2
		jne siguiente2
		mov readedEnteroDna[0], 'C'
		jmp finenterotodna
		siguiente2:
		cmp cx, 3
		jne siguiente3
		mov readedEnteroDna[0], 'T'
		jmp finenterotodna
		siguiente3:
		cmp cx, 4
		jne siguiente4
		mov readedEnteroDna[0], 'A'
		jmp finenterotodna
		siguiente4:
		mov readedEnteroDna[0], 'G'
	finenterotodna:
	ret 
endP

booltodna proc near
	mov al, boolValue
	cmp al, 0
	jne esVerdadero
	mov readedBoolDna[0], 'G'
	ret
	esVerdadero:
	mov readedBoolDna[0], 'C'
	ret
endP

chartodna proc near

	cmp al, 'G'
	jne siguiente9
	mov readedCharDna[0], 'G'
	jmp finChartoDna
	siguiente9:
	cmp al, 'C'
	jne siguiente10
	mov readedCharDna[0], 'C'
	jmp finChartoDna
	siguiente10:
	cmp al, 'T'
	jne siguiente11
	mov readedCharDna[0], 'T'
	jmp finChartoDna
	siguiente11:
	cmp al, 'A'
	jne siguiente12
	mov readedCharDna[0], 'A'
	jmp finChartoDna
	siguiente12:
	cmp al, 'g'
	jne siguiente13
	mov readedCharDna[0], 'g'
	jmp finChartoDna
	siguiente13:
	cmp al, 'c'
	jne siguiente14
	mov readedCharDna[0], 'c'
	jmp finChartoDna
	siguiente14:
	cmp al, 't'
	jne siguiente15
	mov readedCharDna[0], 't'
	jmp finChartoDna
	siguiente15:
	cmp al, 'a'
	jne siguiente16
	mov readedCharDna[0], 'a'
	jmp finChartoDna
	siguiente16:
	xor ah, ah
	mov dl, 4
	div dl
	cmp ah, 0
	jne siguiente5
	mov readedCharDna[0], 'G'
	jmp finChartoDna
	siguiente5:
	cmp ah, 1
	jne siguiente6
	mov readedCharDna[0], 'C'
	jmp finChartoDna
	siguiente6:
	cmp ah, 2
	jne siguiente7
	mov readedCharDna[0], 'T'
	jmp finChartoDna
	siguiente7:
	cmp ah, 3
	jne siguiente8
	mov readedCharDna[0], 'A'
	jmp finChartoDna
	siguiente8:
	mov readedCharDna[0], 'G'
	finChartoDna:
	ret
endP

archivoToDna proc near
	mov bx, contadorDNA
	cmp al, 'G'
	jne siguiente17
	mov readedArchivoDna[bx], 'G'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente17:
	cmp al, 'C'
	jne siguiente18
	mov readedArchivoDna[bx], 'C'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente18:
	cmp al, 'T'
	jne siguiente19
	mov readedArchivoDna[bx], 'T'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente19:
	cmp al, 'A'
	jne siguiente20
	mov readedArchivoDna[bx], 'A'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente20:
	cmp al, 'g'
	jne siguiente21
	mov readedArchivoDna[bx], 'g'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente21:
	cmp al, 'c'
	jne siguiente22
	mov readedArchivoDna[bx], 'c'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente22:
	cmp al, 't'
	jne siguiente23
	mov readedArchivoDna[bx], 't'
	inc contadorDNA
	jmp finArchivotoDna
	siguiente23:
	cmp al, 'a'
	jne finArchivotoDna
	mov readedArchivoDna[bx], 'a'
	inc contadorDNA
	finArchivotoDna:
	ret
endP

inicio:
	
	; Se cargan los datos definidos en datos Segment
	mov ax, datos
	mov ds, ax		

;---------------------------------------
;- String -> DNA                       -
;---------------------------------------

	push offset mensajeEntradaString
	call print

	; se lee un string de la entrada estandar
	mov dx, offset dna
	mov ah, 0ah
	int 21h

	; se confirma que el string sea una cadena de dna
	push offset dna
	push offset readedDna
	call stringtodna
	
	; Se imprime el mensaje para mostrar la cadena introducida
	push offset mensajeSalida
	call print
	
    ; Se imprime la cadena introducida
	push offset readedDna
	call print

;---------------------------------------
;- ENTERO -> DNA                       -
;---------------------------------------

	; Se imprime el mensaje para pedir un entero
	push offset mensajeEntradaEntero
	call print

	; se lee un entero de la entrada estandar
	mov dx, offset entradaEntero
	mov ah, 0ah
	int 21h

	; se confirma que el string sea una cadena de dna
	push offset entradaEntero
	call stringtoint
	pop ax
	mov integer, ax

	call enterotodna

	; Se imprime el mensaje para mostrar la cadena introducida
	push offset mensajeSalida
	call print
	
	; Se imprime la cadena introducida
	push offset readedEnteroDna
	call print

; ---------------------------------------
;- BOOLEANO -> DNA                    -
;---------------------------------------

	; Se imprime el mensaje para pedir un booleano
	push offset mensajeEntradaBooleano
	call print

	; se lee un booleano de la entrada estandar
	mov ah, 01h
	int 21h
	sub al, 30h
	cmp al, 1
	jbe esBooleano
	push offset errorBooleano
	call print
	mov ax, 4c00h 
	int 21h 	 
esBooleano:
	mov boolValue, al

	call booltodna

	; Se imprime el mensaje para mostrar la cadena introducida
	push offset mensajeSalida
	call print
	
	; Se imprime la cadena introducida
	push offset readedBoolDna
	call print


; ---------------------------------------
; - CHAR -> DNA                   		-
;----------------------------------------

	; Se imprime el mensaje para pedir un caracter
	push offset mensajeEntradaChar
	call print

	; se lee un caracter de la entrada estandar
	xor ax, ax
	mov ah, 01h
	int 21h
	mov char, al

	call chartodna

	; Se imprime el mensaje para mostrar la cadena introducida
	push offset mensajeSalida
	call print
	
	; Se imprime la cadena introducida
	push offset readedCharDna
	call print

; ---------------------------------------
; - Archivo -> DNA                   	-
; ----------------------------------------

	push offset mensajeEntradaArchivo
	call print

	; se lee un string de la entrada estandar
	mov dx, offset nombreArchivo
	mov ah, 0ah
	int 21h

	mov bx, offset nombreArchivo  ; bx = dir de la string
	add bl, byte ptr [bx+1]  ; longitud de string
	add bx, 2
	mov [bx], byte ptr 0
; Abrir el archivo en modo lectura
	mov ah, 3Dh
	mov dx, offset nombreArchivo  ; Dirección real del archivo
	add dx, 2       ; Para saltar el tamaño del string 
	mov al, 0
	int 21h
	mov handle_pixels, ax ; Guardar el handle del archivo

	loopleerdna:	
	mov bx, handle_pixels   
	xor cx, cx				
	xor al, al				
	mov dx, contadorArchivo 	
	mov ah, 42h 
	int 21h				
	add contadorArchivo, 1   	

	xor ax, ax				; Limpia el ax
	mov ah, 03fh			;
	mov bx, handle_pixels	;
	mov cx, 01h 			;
	mov dx, offset currentchar		; offset lugar de memoria donde esta la variable char
	int 21h				
	cmp al, 0
	je finArchivo

	mov al, currentChar	; Se carga el caracter leido en al
	call archivoToDna	; Se llama a la funcion que convierte el caracter a DNA


	cmp contadorDNA, 255
	jne loopleerdna	; Si no se ha llegado al final del archivo, se sigue leyendo

	finArchivo:
	push offset mensajeSalida
	call print

	push offset readedArchivoDna
	call print
fin:
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	