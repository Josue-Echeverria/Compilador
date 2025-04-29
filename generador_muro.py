from scanner import Scanner
import sys

# Diccionario para convertir tipo numérico a clase CSS
CLASES_CSS = {
    1: 'identificador',
    2: 'numero',
    3: 'operador_aritmetico',
    4: 'delimitador',
    5: 'separador',
    6: 'cadena',
    7: 'comentario',
    9: 'error',
    10: 'estructura_programa',
    11: 'control_flujo',
    12: 'control_ciclos',
    13: 'operaciones_avanzadas',
    14: 'tipo_dato',
    15: 'literal_booleano',
    16: 'literal_archivo',
    17: 'literal_caracter',
    18: 'operador_incremento',
    19: 'operador_logico',
    20: 'operador_caracter',
    21: 'operador_string',
    22: 'operador_archivo',
    23: 'comparador'
}

# Inicializa estadísticas
estadisticas = {clase: 0 for clase in CLASES_CSS.values()}
estadisticas.update({
    'comentario_linea': 0,
    'comentario_bloque': 0,
    'lineas': 0,
    'caracteres': 0
})

def generar_muro(nombre_archivo):
    scanner = Scanner('matriz_automata.csv')
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
            if token['lexema'].startswith('$$'):
                estadisticas['comentario_linea'] += 1
            elif token['lexema'].startswith('$*'):
                estadisticas['comentario_bloque'] += 1
            # NO se agrega ladrillo (se ignora el contenido visualmente)
        elif token['tipo'] in CLASES_CSS:
            clase = CLASES_CSS[token['tipo']]
            estadisticas[clase] += 1
            # Crear ladrillo solo si no es comentario
            ladrillo = f'<div class="token {clase}">{token["lexema"]}</div>'
            ladrillos.append(ladrillo)
        
        if token['tipo'] == scanner.TIPOS_TOKEN['FIN_ARCHIVO']:
            estadisticas['lineas'] = scanner.linea_actual
            break
        
        scanner.tome_token()

    scanner.finalizar_scanner()

    # Escribir el archivo HTML
    with open("muro.html", "w", encoding="utf-8") as f:
        f.write("<!DOCTYPE html>\n<html lang='es'>\n<head>\n")
        f.write("<meta charset='UTF-8'>\n<title>Muro de Ladrillos</title>\n")
        # Estilos CSS (igual que antes)
        f.write("<style>\n")
        f.write("body { font-family: Arial; background: #f4f4f4; padding: 20px; }\n")
        f.write(".muro { display: flex; flex-wrap: wrap; gap: 5px; }\n")
        f.write(".token { padding: 10px; border-radius: 4px; color: white; font-weight: bold; }\n")
        # Colores por clase
        f.write(".identificador { background-color: #3498db; }\n")
        f.write(".numero { background-color: #2ecc71; }\n")
        f.write(".operador_aritmetico { background-color: #e74c3c; }\n")
        f.write(".delimitador { background-color: #95a5a6; }\n")
        f.write(".separador { background-color: #7f8c8d; }\n")
        f.write(".cadena { background-color: #e67e22; }\n")
        f.write(".error { background-color: #000000; color: white; }\n")
        f.write(".estructura_programa { background-color: #1abc9c; }\n")
        f.write(".control_flujo { background-color: #f39c12; }\n")
        f.write(".control_ciclos { background-color: #8e44ad; }\n")
        f.write(".operaciones_avanzadas { background-color: #7f8c8d; }\n")
        f.write(".tipo_dato { background-color: #2c3e50; }\n")
        f.write(".literal_booleano { background-color: #27ae60; }\n")
        f.write(".literal_archivo { background-color: #c0392b; }\n")
        f.write(".literal_caracter { background-color: #d35400; }\n")
        f.write(".operador_incremento { background-color: #e84393; }\n")
        f.write(".operador_logico { background-color: #6c5ce7; }\n")
        f.write(".operador_caracter { background-color: #fd79a8; }\n")
        f.write(".operador_string { background-color: #00cec9; }\n")
        f.write(".operador_archivo { background-color: #636e72; }\n")
        f.write(".comparador { background-color: #ffeaa7; color: #2d3436; }\n")
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
