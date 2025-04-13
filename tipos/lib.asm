;-------------------------------------------;
; LIBRERIA DE PROCEDIMIENTOS                ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; En este programa se almacenan todos los   ;
; procedimientos que se usan en el programa ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l lib                        ;
;    tlink /v <nombre del archivo> lib                           ;
;                                           ;
; Fecha de creacion: Abril 05, 2025.        ;
;-------------------------------------------;
datos Segment
    mensajeError db "Número fuera de rango$"
	mensajeErrorOverflow db 10,13,'Error: Overflow en la conversion de string a entero $'
	mensajeErrorNoInt db 10,13,'Error: No se introdujo un numero entero $'
    mensajeErrorBoolean db 10,13,'Error: No se introdujo un valor booleano $'
    mensajeErrorArchivo db 10,13,'Error: No se introdujo un nombre de archivo existente en el directorio$'
    mensajeErrorArchivoNoInt db 10,13,'Error: No existe un valor numerico en el archivo$'
    mensajeErrorArchivoOrverflow db 10,13,'Error: Overflow en la conversion del archivo a entero$'
    integer dw 0
    bufferLectura db 255 dup('$')  ; Donde queda guardado el contenido del archivo
    archivoInteger dw 0
datos Ends

procedimientos Segment
    public stringtoint, inttostring, print, booltoint, archivotoint
    assume cs:procedimientos, ds:datos

    print proc far ; input : push offset string 
        push ax
        push dx
        push bp 
        mov bp, sp 
        mov ah, 09h
        mov dx, 0ah[bp]
        int 21h
        pop bp
        pop dx
        pop ax
        retf         ;Se usa para limpiar lo que quede fuera según el número de instrucciones
    print endp

    stringtoint proc far 
        mov bp, sp     
        mov bx, [bp+4]  ; bx = dir de la string
        mov cl, [bx+1]  ; longitud de string
        mov dx, 1       ; dx = 10^longitud de string
    loopStringtoInt:
        xor ax, ax
        add bx, cx      ; bx = dir de la string + longitud de string
        mov al, byte ptr [bx+1]
        sub al, 30h
        cmp al, 9
        ja noIntError
        push dx
        mul dx
        add [bp+6], ax  ; integer = integer + ax
        jc overflowError
        pop ax
        mov dx, 10
        mul dx
        mov dx, ax
        sub bx, cx
        loop loopStringtoInt
        jmp fin
    overflowError:
    	mov bx, 1
        call handleError
    noIntError:
        mov bx, 2
        call handleError
    fin:
        retf 2 
    endp

    inttostring proc far 
        mov cx, 10
    loopInttoString:
        xor dx, dx
        div cx
        add dx, 0030h
        mov [bx], dl
        dec bx
        cmp ax, 0
        jne loopInttoString
        retf
    endp

    booltoint proc far 
        mov bp, sp     
        xor ax, ax
        mov bx, [bp+4]  ; bx = dir de la string
        mov al, byte ptr [bx]
        sub al, 30h
        cmp al, 1
        jbe finbool
        
        mov bx, 3
        call handleError
    finbool:
        retf 2
    endp

    archivotoint proc far
        ; Pasar del formato de string a un nombre de archivo
        xor ax, ax
        xor cx, cx           
        xor bx, bx           
        mov bp, sp     
        mov bx, [bp+4]  ; bx = dir de la string
        add bl, byte ptr [bx+1]  ; longitud de string
        add bx, 2
        mov [bx], byte ptr 0

        ; Abrir el archivo en modo lectura
        mov ah, 3Dh
        mov dx, [bp+4]  ; Dirección real del archivo
        add dx, 2
        xor al, al      ; Modo lectura
        int 21h
        jnc noError     ; Si falla, mostrar mensaje de que no se pudo abrir el archivo
        mov bx, 4
        call handleError
        noError:
        mov bx, ax  ; Guardar el manejador del archivo
        
        push ds
        mov ax, datos
        mov ds, ax
        ; Leer contenido del archivo
        xor ax, ax
        mov ah, 3Fh
        lea dx, bufferLectura
        mov cx, 255  ; Leer hasta 255 caracteres
        int 21h

        mov cx, ax
        mov bx, offset bufferLectura
        mov dx, 1
    looparchivotoInt:
        xor ax, ax
        add bx, cx      ; bx = dir de la string + longitud de string
        mov al, byte ptr [bx-1]
        sub al, 30h
        cmp al, 9
        ja noIntinArchivoError
        
        
        push dx
        mul dx
        mov dx, ax  ;
        mov ax, integer
        add ax, dx      ; integer = integer + ax
        jc overflowinArchivoError ; TODO: ARREGLAR: NO SALTA ERROR DE OVERFLOW CUANDO EL NUMERO ES MAYOR A 65535
        mov integer, ax  
        pop ax
        mov dx, 10
        mul dx
        mov dx, ax
        sub bx, cx
        loop looparchivotoInt
        mov ax, integer
        pop ds
        retf 2
    noIntinArchivoError:
        mov bx, 5
        call handleError
    overflowinArchivoError:
        mov bx, 6
        call handleError
    
    endp




    handleError proc near
        mov ax, datos
    	mov ds, ax	

        cmp bx, 1
        jne printNoIntError
        printOverflowError: ; Error 1 
        mov dx, offset mensajeErrorOverflow 
        mov ah, 9
        int 21h
        jmp finError

        printNoIntError: ; Error 2
        cmp bx, 2
        jne printBooleanError
        mov dx, offset mensajeErrorNoInt
        mov ah, 9
        int 21h
        jmp finError
        
        printBooleanError: ; Error 3
        cmp bx, 3
        jne printArchivoError
        mov dx, offset mensajeErrorBoolean
        mov ah, 9
        int 21h
        jmp finError

        printArchivoError: ; Error 4
        cmp bx, 4
        jne printArchivoNoIntError
        mov dx, offset mensajeErrorArchivo
        mov ah, 9
        int 21h
        jmp finError

        printArchivoNoIntError: ; Error 5
        cmp bx, 5
        jne printArchivoOverflowError
        mov dx, offset mensajeErrorArchivoNoInt
        mov ah, 9
        int 21h
        jmp finError

        printArchivoOverflowError: ; Error 6
        cmp bx, 6
        jne finError
        mov dx, offset mensajeErrorArchivoOrverflow
        mov ah, 9
        int 21h

        finError:
        mov ax, 4c00h 
        int 21h
    endp


procedimientos Ends
end