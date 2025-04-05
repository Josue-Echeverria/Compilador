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
;    tasm /zi /l int                        ;
;    tlink /v int                           ;
;                                           ;
; Fecha de creacion: Abril 05, 2025.        ;
;-------------------------------------------;
datos Segment
    mensajeError db "Número fuera de rango$"
	mensajeErrorOverflow db 10,13,'Error: Overflow en la conversion de string a entero $'
	mensajeErrorNoInt db 10,13,'Error: No se introdujo un numero entero $'
    integer dw 0
datos Ends

procedimientos Segment
    public stringtoint, inttostring, print
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
        retf          ;Se usa para limpiar lo que quede fuera según el número de instrucciones
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

    handleError proc near
        mov ax, datos
    	mov ds, ax	
        cmp bx, 1
        jne printNoIntError
        printOverflowError:
        mov dx, offset mensajeErrorOverflow 
        mov ah, 9
        int 21h
        jmp finError

        printNoIntError:
        mov dx, offset mensajeErrorNoInt
        mov ah, 9
        int 21h
        
        finError:
        mov ax, 4c00h 
        int 21h
    endp


procedimientos Ends
end