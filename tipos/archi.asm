;-------------------------------------------;
; Lectura de arhivos                        ;
;-------------------------------------------;
;                                           ;
; Creado por: Quiros Harlen                 ;
;                                           ;
; Descripcion:                              ;
; Este programa pide el nombre de un archivo;
; y muestra su contenido en pantalla.       ;
;                                           ;
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
datos Segment
    mensaje1 db "Ingrese el nombre del archivo: $"
    mensaje2 db 10,13, "Contenido del archivo: $"
    mensajeError db "Ocurrio un error al procesar el archivo...$"
    archivo db 30 dup('$')   ; Primer byte: Tamaño máximo, segundo: Longitud actual
    archivoNombre db 30 dup(?)  ; Nombre real del archivo
    handle dw ?
    bufferLectura db 255 dup('$')  ; Buffer de lectura
datos EndS





codigo Segment
    assume cs:codigo, ds:datos

Inicio:
    xor ax, ax
    mov ax, datos
    mov ds, ax

    ; Solicitar nombre del archivo
    mov dx, offset mensaje1
    mov ah, 9
    int 21h

    ; Leer el nombre del archivo desde el usuario
    mov dx, offset archivo
    mov ah, 0Ah
    int 21h

    ; Ajustar el nombre del archivo con terminador nulo
    xor ax, ax
    xor cx, cx           ; Limpiar CX
    xor bx, bx           ; Limpiar BX
    mov cl, [archivo+1]  ; Obtener longitud ingresada (8 bits)
loopStrinptofile:
    mov al, archivo[bx+2]                ; Leer byte de nombre
    mov archivoNombre[bx], al  ; Copiar byte a archivoNombre
    inc bx
    loop loopStrinptofile
   

    ; Abrir el archivo en modo lectura
    mov ah, 3Dh
    lea dx, archivoNombre  ; Dirección real del nombre
    xor al, al  ; Modo lectura
    int 21h
    jc Error  ; Si falla, mostrar mensaje de error

    mov handle, ax  ; Guardar el manejador del archivo

    ; Leer contenido del archivo
    mov ah, 3Fh
    mov bx, handle
    lea dx, bufferLectura
    mov cx, 255  ; Leer hasta 255 caracteres
    int 21h
    jc Error

    ; Agregar terminador de cadena al buffer leído
    mov si, ax  ; Número de bytes leídos
    mov byte ptr [bufferLectura+si], '$'

    ; Mostrar mensaje de contenido del archivo
    mov dx, offset mensaje2
    mov ah, 9
    int 21h

    ; Imprimir el contenido del archivo
    mov dx, offset bufferLectura
    mov ah, 9
    int 21h

    ; Cerrar el archivo
    mov ah, 3Eh
    mov bx, handle
    int 21h
    jnc salida
    jmp short Error

Error:
    mov ah, 9
    lea dx, mensajeError
    int 21h

salida:
    mov ax, 4c00h
    int 21h

codigo EndS
End Inicio
