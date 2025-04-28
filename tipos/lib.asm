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
;    tlink /v <nombre del archivo> lib      ;
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
	mensajeErrorNoBoolean db 10,13,'Error: No se introdujo un booleano $'

    true db '1 (vedadero)$'
    false db '0 (falso)$'
    integer dw 0
    bufferLectura db 255 dup('$')  ; Donde queda guardado el contenido del archivo
    archivoInteger dw 0
datos Ends

procedimientos Segment
    public stringtoint, inttostring, print, booltoint, archivotoint, stringtoboolean, printBool, inttobool, chartobool, archivotobool, addUpString, archivotochar,archivotostring
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
        div cx          ; Cada vez que se divide el entero por 10, se obtiene el residuo en dx
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

    stringtoboolean proc far 
    ; "" = false
    ; "0" = false
    ; "literally any other string" = true

        mov bp, sp     
        mov bx, [bp+4]          ; bx = dir de la string
        xor ax, ax
        mov al, byte ptr [bx+1]   ; al = length of string
        cmp al, 0               ; al ? 0
        ja noEmptyString
        mov bx, [bp+6]
        mov byte ptr [bx], 0
                                ; Y en la posicion 33 se guardara si es verdadero (1) o falso (0)
        jmp finStringtoBoolean
    noEmptyString:
        mov al, byte ptr [bx+2] ; al = first character of string
        cmp al, 30h             ; al ? '0'
        ja normalString
        mov bx, [bp+6]
        mov byte ptr [bx], 0
        jmp finStringtoBoolean
    normalString:
        mov bx, [bp+6]
        mov byte ptr [bx], 1
    finStringtoBoolean:
        retf 4
    endp

    inttobool proc far 
    ; 1 = true
    ; 65535 = true
    ; 0 = false
    ; (Cualquier numero diferente de 0 es true)
        mov bp, sp     
        mov bx, [bp+4]          ; bx = dir del valor booleano
        mov ax, [bx]   
        cmp ax, 1
        jae esVerdaderoInttoBool
        mov bx, [bp+6] 
        mov byte ptr [bx], 0
        jmp finInttoBool
    esVerdaderoInttoBool:
        mov bx, [bp+6] 
        mov byte ptr [bx], 1
    finInttoBool:
        retf 2
    endp

    printBool proc far  
        mov bp, sp     
        mov bx, [bp+4]          ; bx = dir del valor booleano
        mov al, byte ptr [bx]   ; al = 1 | 0 
        cmp al, 1
        je esVerdadero
        mov dx, offset false
        jmp imprimir
    esVerdadero:
        mov dx, offset true
    imprimir:
        push ds   
        mov ax, datos
        mov ds, ax
        mov ah, 9
        int 21h
        pop ds
        retf 2
    endp

	chartobool proc far
        mov bp, sp     
        xor ax, ax
        mov bx, [bp+4]          ; bx = dir del valor booleano
        mov al, byte ptr [bx]   ; al = length of string
        cmp ax, 30h
        ja esVerdaderoChartoBool
        mov bx, [bp+6] 
        mov byte ptr [bx], 0
        jmp finChartoBool
    esVerdaderoChartoBool:
        mov bx, [bp+6] 
        mov byte ptr [bx], 1
    finChartoBool:
        retf 4
	endp

    archivotobool proc far
        mov bp, sp     
        mov bx, [bp+4]  ; bx = dir de la string
        add bl, byte ptr [bx+1]  ; longitud de string
        add bx, 2
        mov [bx], byte ptr 0

        ; Abrir el archivo en modo lectura
        mov ah, 3Dh
        mov dx, [bp+4]  ; Dirección real del archivo
        add dx, 2       ; Para saltar el tamaño del string 
        mov bx, [bp+6]  ; modo de apertura
        mov al, byte ptr [bx]
        int 21h
        jnc trueArchivo         ; SI no falla el archivo se abrio y por lo tanto es verdadero
        mov bx, [bp+8]
        mov byte ptr [bx], 0
        jmp finArchivotoBool
    trueArchivo:
        mov bx, [bp+8]
        mov byte ptr [bx], 1
    finArchivotoBool:
        retf 6
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

    addUpString proc far
        ; Proc para sumar los primeros 5 valores de un string
        ; Este proc es para generar el nombre del archivo en caso de conversion string -> archivo 
        mov bp, sp
        mov bx, [bp+4]  
        mov cl, 5
        xor dx, dx
    addUpStringLoop:
        xor ax, ax
        mov al, byte ptr [bx+2] ; al = primer caracter del string
        add dx, ax
        inc bx
        loop addUpStringLoop
        mov bx, [bp+6] 
        mov [bx], dx 
        retf 4
    endp

    archivotochar proc far
        mov bp, sp     
        mov bx, [bp+4]  ; bx = dir de la string
        add bl, byte ptr [bx+1]  ; longitud de string
        add bx, 2
        mov [bx], byte ptr 0
; Abrir el archivo en modo lectura
        mov ah, 3Dh
        mov dx, [bp+4]  ; Dirección real del archivo
        add dx, 2       ; Para saltar el tamaño del string 
        mov al, 0
        int 21h
        jnc archivotocharNoError         
        mov bx, 4
        call handleError
        jmp finArchivotochar
    archivotocharNoError:
        mov bx, ax
        mov ah, 3Fh
        mov dx, [bp+6] ; dx = dir del caracter
        mov cx, 1
        int 21h
    finArchivotochar:
        retf 4
    endp

    archivotostring proc far
        mov bp, sp     
        mov bx, [bp+4]  ; bx = dir de la string
        add bl, byte ptr [bx+1]  ; longitud de string
        add bx, 2
        mov [bx], byte ptr 0
; Abrir el archivo en modo lectura
        mov ah, 3Dh
        mov dx, [bp+4]  ; Dirección real del archivo
        add dx, 2       ; Para saltar el tamaño del string 
        mov al, 0
        int 21h
        jnc archivotostringNoError         
        mov bx, 4
        call handleError
        jmp finArchivotostring
    archivotostringNoError:
        mov bx, ax
        mov ah, 3Fh
        mov dx, [bp+6] ; dx = dir del caracter
        mov cx, 255
        int 21h
    finArchivotostring:
        retf 4
    endp

procedimientos Ends
end