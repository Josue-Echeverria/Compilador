from scanner import Scanner
import sys

# Diccionario para convertir tipo numérico a clase CSS
CLASES_CSS = {
    1: 'identificador',
    2: 'numero',
    3: 'operador',
    4: 'delimitador',
    5: 'cadena',
    6: 'comentario',
    8: 'error'
}

# Inicializa estadísticas
estadisticas = {
    'identificador': 0,
    'numero': 0,
    'operador': 0,
    'delimitador': 0,
    'cadena': 0,
    'comentario_linea': 0,
    'comentario_bloque': 0,
    'error': 0,
    'lineas': 0,
    'caracteres': 0
}

def generar_muro(nombre_archivo):
    scanner = Scanner()
    if not scanner.inicializar_scanner(nombre_archivo):
        print("No se pudo abrir el archivo.")
        return

    ladrillos = []  # Guardará los divs de los ladrillos

    while True:
        token = scanner.deme_token()

        # Actualizar estadísticas
        if token['tipo'] != scanner.TIPOS_TOKEN['FIN_ARCHIVO']:
            estadisticas['caracteres'] += len(token['lexema'])
        if token['tipo'] == scanner.TIPOS_TOKEN['COMENTARIO']:
            if token['lexema'].startswith('//'):
                estadisticas['comentario_linea'] += 1
            elif token['lexema'].startswith('/*'):
                estadisticas['comentario_bloque'] += 1
        elif token['tipo'] == scanner.TIPOS_TOKEN['ERROR']:
            estadisticas['error'] += 1
        elif token['tipo'] in CLASES_CSS:
            clase = CLASES_CSS[token['tipo']]
            estadisticas[clase] += 1
        
        # Crear ladrillo
        if token['tipo'] != scanner.TIPOS_TOKEN['FIN_ARCHIVO']:
            clase = CLASES_CSS.get(token['tipo'], 'desconocido')
            ladrillo = f'<div class="token {clase}">{token["lexema"]}</div>'
            ladrillos.append(ladrillo)
        else:
            estadisticas['lineas'] = scanner.linea_actual
            break
        
        scanner.tome_token()

    scanner.finalizar_scanner()

    # Escribir el archivo HTML
    with open("muro.html", "w", encoding="utf-8") as f:
        f.write("<!DOCTYPE html>\n<html lang='es'>\n<head>\n")
        f.write("<meta charset='UTF-8'>\n<title>Muro de Ladrillos</title>\n")
        # Copia el estilo CSS (puedes pegarlo aquí o cargarlo de un archivo externo)
        f.write("<style>\n")
        f.write("body { font-family: Arial; background: #f4f4f4; padding: 20px; }\n")
        f.write(".muro { display: flex; flex-wrap: wrap; gap: 5px; }\n")
        f.write(".token { padding: 10px; border-radius: 4px; color: white; font-weight: bold; }\n")
        f.write(".identificador { background-color: #3498db; }\n")
        f.write(".numero { background-color: #2ecc71; }\n")
        f.write(".operador { background-color: #e74c3c; }\n")
        f.write(".delimitador { background-color: #95a5a6; }\n")
        f.write(".cadena { background-color: #e67e22; }\n")
        f.write(".comentario { background-color: #9b59b6; }\n")
        f.write(".error { background-color: #000000; color: white; }\n")
        f.write(".estadisticas { margin-top: 30px; background: white; padding: 15px; border-radius: 8px; }\n")
        f.write("</style>\n</head>\n<body>\n")
        f.write("<h1>Muro de Ladrillos</h1>\n")
        f.write('<div class="muro">\n')
        for ladrillo in ladrillos:
            f.write(ladrillo + '\n')
        f.write("</div>\n")
        
        # Estadísticas
        f.write('<div class="estadisticas">\n<h2>Estadísticas</h2>\n<ul>\n')
        for key, value in estadisticas.items():
            if value > 0:
                f.write(f"<li>{key.capitalize().replace('_', ' ')}: {value}</li>\n")
        f.write("</ul>\n</div>\n")
        
        f.write("</body>\n</html>\n")

    print("Archivo muro.html generado correctamente.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python generador_muro.py <archivo_fuente>")
    else:
        generar_muro(sys.argv[1])