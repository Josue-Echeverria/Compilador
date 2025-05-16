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
    mensajeErrorStringIndexError db 10,13,'Error: El indice del string no existe$'
    mensajeErrorCharNoEncontrado db 10,13,'Error: El caracter no fue encontrado en la cadena$'

    true db '1 (vedadero)$'
    false db '0 (falso)$'
    integer dw 0
    bufferLectura db 255 dup('$')  ; Donde queda guardado el contenido del archivo
    archivoInteger dw 0
datos Ends

procedimientos Segment
    public stringtoint, inttostring, print, booltoint, archivotoint, stringtoboolean, printBool, inttobool, chartobool, archivotobool, addUpString, archivotochar,archivotostring, checkStringIndex, input, getStringLength, concatString, findChar, underCutString, orOperand, andOperand, xorOperand, notOperand, esDigito, esAlpha, toMayuscula, toMinuscula
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
        xor ax, ax
        mov [bp+6], ax  ; integer = 0
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
        jne printStringIndexError
        mov dx, offset mensajeErrorArchivoOrverflow
        mov ah, 9
        int 21h
        jmp finError

        printStringIndexError: ; Error 7
        cmp bx, 7
        jne printNoCharFoundError
        mov dx, offset mensajeErrorStringIndexError
        mov ah, 9
        int 21h
        jmp finError

        printNoCharFoundError: ; Error 8
        cmp bx, 8
        jne finError
        mov dx, offset mensajeErrorCharNoEncontrado
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

    ; Verifica que la posicion existe en el string
    checkStringIndex proc far
        mov bp, sp
        mov bx, [bp+4]  ; bx = dir de la string 
        mov cx, [bx]
        cmp cx, 32  ; 32 es el tamaño maxion del string|
        jg noIndexError
        mov bx, [bp+6]
        add bx, cx
        mov al, byte ptr [bx+2]
        cmp al, 0
        jne finCheckStringIndex

    noIndexError:
        mov bx, 7
        call handleError
    finCheckStringIndex:
        retf 4
    endp

    getStringLength proc far
        mov bp, sp
        mov bx, [bp+4]  ; bx = dir de la string 
        lea si, [bx]
        xor cx, cx
    lengthLoop:
        lodsb
        cmp al, 0
        je lengthDone
        cmp cx, 32
        jae lengthDone
        inc cx
        jmp lengthLoop
    lengthDone:
        mov bx, [bp+6]  
        mov [bx], cx
        retf 4
    endp

    concatString proc far
        mov bp, sp
        mov bx, [bp+8]  
        mov di, [bp+4] 
        mov cx, 32
    concatLoop1:
        mov al, byte ptr [bx]
        cmp al, 0
        je concatDone1
        cmp al, 0dh
        je concatDone1
        stosb
        inc bx
        jmp concatLoop1
    concatDone1:
        mov bx, [bp+6]  
    concatLoop2:
        mov al, byte ptr [bx]
        cmp al, 0
        je concatDone2
        cmp al, 0dh
        je concatDone2
        stosb
        inc bx
        jmp concatLoop2
    concatDone2:
        mov al, '$'
        stosb    
        ret 6
    endp

    findChar proc far
        mov bp, sp
        mov bx, [bp+8]  ; bx = dir de la string 
        mov ah, byte ptr [bp+6]  ; ah = char a buscar
    findloop:
        mov al, byte ptr [bx]
        cmp al, 0
        je notFound
        cmp al, ah
        je found
        inc cx
        inc bx
        jmp findLoop
    found:
        mov bx, [bp+4]
        mov [bx], cx
        ret 6
    notFound:
        mov bx, 8
        call handleError
    endp

    underCutString proc far
        mov bp, sp
        mov si, [bp+10] 
        mov di, [bp+4]  
        mov cx, [bp+8]
    goToStartLoop:
        cmp cx, 0
        je startCut
        lodsb
        stosb
        dec cx
        jmp goToStartLoop
    startCut:
        mov ax, [bp+6]
        add si, ax
    underCuttingLoop:
        lodsb
        cmp al, 0
        je endUnderCutString
        cmp al, 0dh
        je endUnderCutString
        stosb
        jmp underCuttingLoop
    endUnderCutString:
        mov al, '$'
        stosb
        ret 8
    endp

    orOperand proc far
        mov bp, sp
        mov bx, [bp+8]  ; bx = dir de la string
        mov ax, [bp+6]  ; ax = primer operando
        or ax, bx
        add al, '0'
        mov bx, [bp+4]  
        mov byte ptr [bx], al
        ret 6
    endp

    andOperand proc far
        mov bp, sp
        mov bx, [bp+8]  ; bx = dir de la string
        mov ax, [bp+6]  ; ax = primer operando
        and ax, bx
        add al, '0'
        mov bx, [bp+4]  
        mov byte ptr [bx], al
        ret 6
    endp

    xorOperand proc far
        mov bp, sp
        mov bx, [bp+8]  ; bx = dir de la string
        mov ax, [bp+6]  ; ax = primer operando
        xor ax, bx
        add al, '0'
        mov bx, [bp+4]  
        mov byte ptr [bx], al
        ret 6
    endp

    notOperand proc far
        mov bp, sp
        mov bx, [bp+8]  ; bx = dir de la string
        mov ax, [bp+6]  ; ax = primer operando
        xor al, 1   ; Invierte el bit (0 se vuelve 1, 1 se vuelve 0)
        add al, '0'
        mov bx, [bp+4]  
        mov byte ptr [bx], al
        ret 6
    endp

    esDigito proc far
        mov bp, sp
        mov al, byte ptr[bp+4]  
        cmp al, '0'
        jb noEsDigito_Print
        cmp al, '9'
        ja noEsDigito_Print
        ; Es un dígito
        mov bx, [bp+6]
        mov byte ptr [bx], 1
        jmp finEsDigito
    noEsDigito_Print:
        ; No es un dígito
        mov bx, [bp+6]
        mov byte ptr [bx], 0
    finEsDigito:
        ret 2
    endp

    esAlpha proc far
        mov bp, sp
        mov al, byte ptr[bp+4]  
        cmp al, 'a'
        jb checkMayusculaAlpha
        cmp al, 'z'
        ja checkMayusculaAlpha
        mov bx, [bp+6]
        mov byte ptr [bx], 1
        jmp finEsAlpha
    
    checkMayusculaAlpha:
        ; Chequear si es mayúscula
        cmp al, 'A'
        jb noEsAlpha_Print
        cmp al, 'Z'
        ja noEsAlpha_Print
        mov bx, [bp+6]
        mov byte ptr [bx], 1
        jmp finEsAlpha
    noEsAlpha_Print:
        ; No es un dígito
        mov bx, [bp+6]
        mov byte ptr [bx], 0
    finEsAlpha:
        ret 2
    endp

    toMayuscula proc far
        mov bp, sp
        mov al, byte ptr[bp+4]  
        cmp al, 'a'
        jb printMayusculaDirectly ; If less than 'a', it's not a lowercase letter
        cmp al, 'z'
        ja printMayusculaDirectly
        sub al, 20h
    printMayusculaDirectly:
        mov bx, [bp+6]
        mov byte ptr [bx], al
        ret 2
    endp

    toMinuscula proc far
        mov bp, sp
        mov al, byte ptr[bp+4]  
        cmp al, 'A'
        jb printMinusculaDirectly ; If less than 'A', it's not an uppercase letter
        cmp al, 'Z'
        ja printMinusculaDirectly
        add al, 20h
    printMinusculaDirectly:
        mov bx, [bp+6]
        mov byte ptr [bx], al
        ret 2
    endp

    input proc far
        mov bp, sp
        mov dx, [bp+4]  ; bx = dir de la string
        mov ah, 0Ah
        int 21h
        ret 2
    endp
procedimientos Ends
end