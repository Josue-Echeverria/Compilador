import pandas as pd

class Scanner:
    def __init__(self, matriz_csv):
        self.archivo = None
        self.buffer = ""
        self.posicion = 0
        self.linea_actual = 1
        self.columna_actual = 0
        self.token_actual = None
        self.fin_archivo = False
        
        self.matriz = pd.read_csv(matriz_csv, index_col=0, dtype=str).fillna('')
        
        self.TIPOS_TOKEN = {
            'IDENTIFICADOR': 1,
            'LITERAL_NUMERO': 2,
            'OPERADOR_ARITMETICO': 3,
            'DELIMITADOR': 4,
            'SEPARADOR': 5,
            'LITERAL_CADENA': 6,
            'COMENTARIO': 7,
            'FIN_ARCHIVO': 8,
            'ERROR': 9,
            'ESTRUCTURA_PROGRAMA': 10,
            'CONTROL_FLUJO': 11,
            'CONTROL_CICLOS': 12,
            'OPERACIONES_AVANZADAS': 13,
            'TIPO_DATO': 14,
            'LITERAL_BOOLEANO': 15,
            'LITERAL_ARCHIVO': 16,
            'LITERAL_CARACTER': 17,
            'OPERADOR_INCREMENTO': 18,
            'OPERADOR_LOGICO': 19,
            'OPERADOR_CARACTER': 20,
            'OPERADOR_STRING': 21,
            'OPERADOR_ARCHIVO': 22,
            'COMPARADOR': 23,
            'ENTRADA_ESTANDAR': 24,
            'SALIDA_ESTANDAR': 25
        }
        
        #Lista de delimitadores incluyendo el símbolo #
        self.delimitadores = ['(', ')', '{', '}', ':', ';', ',', '.', '[', ']', '#']

    def inicializar_scanner(self, nombre_archivo):
        try:
            self.archivo = open(nombre_archivo, 'r', encoding='utf-8')
            self.buffer = ""
            self.posicion = 0
            self.linea_actual = 1
            self.columna_actual = 0
            self.token_actual = None
            self.fin_archivo = False
            return True
        except FileNotFoundError:
            print(f"Error: No se pudo abrir el archivo '{nombre_archivo}'")
            return False

    def finalizar_scanner(self):
        if self.archivo:
            self.archivo.close()
            self.archivo = None

    def deme_caracter(self):
        if self.posicion >= len(self.buffer):
            linea = self.archivo.readline()
            if not linea:
                self.fin_archivo = True
                return ''
            self.buffer = linea
            self.posicion = 0
        caracter = self.buffer[self.posicion]
        self.posicion += 1
        self.columna_actual += 1
        if caracter == '\n':
            self.linea_actual += 1
            self.columna_actual = 0
        return caracter

    def tome_caracter(self):
        if self.posicion > 0:
            self.posicion -= 1
            self.columna_actual -= 1
            if self.buffer[self.posicion] == '\n':
                self.linea_actual -= 1
                self.columna_actual = 0

    def deme_token(self):
        #Ignorar espacios en blanco
        while True:
            caracter = self.deme_caracter()
            if not caracter or caracter not in [' ', '\t', '\n', '\r']:
                break
        if not caracter:
            self.token_actual = {'tipo': self.TIPOS_TOKEN['FIN_ARCHIVO'], 'lexema': '', 'linea': self.linea_actual, 'columna': self.columna_actual}
            return self.token_actual

        lexema = ''
        estado_actual = 'q0'
        linea_inicio = self.linea_actual
        columna_inicio = self.columna_actual - 1

        #Manejo de comentarios con $$ y $* *$
        if caracter == '$':
            lexema += caracter
            siguiente = self.deme_caracter()
            if siguiente == '$':  # Comentario de línea $$
                lexema += siguiente
                # Consumir hasta fin de línea
                while True:
                    caracter = self.deme_caracter()
                    if not caracter or caracter == '\n':
                        break
                    lexema += caracter
                self.token_actual = {'tipo': self.TIPOS_TOKEN['COMENTARIO'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio}
                return self.token_actual
            elif siguiente == '*':  # Comentario multilinea $* *$
                lexema += siguiente
                #Consumir hasta encontrar *$
                comentario_cerrado = False
                while not comentario_cerrado and not self.fin_archivo:
                    caracter = self.deme_caracter()
                    if not caracter:
                        break
                    lexema += caracter
                    if caracter == '*':
                        siguiente = self.deme_caracter()
                        if siguiente == '$':
                            lexema += siguiente
                            comentario_cerrado = True
                        else:
                            #Si no es $ después de *, agregamos el * al lexema y continuamos
                            lexema += siguiente
                if comentario_cerrado:
                    self.token_actual = {'tipo': self.TIPOS_TOKEN['COMENTARIO'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio}
                else:
                    self.token_actual = {'tipo': self.TIPOS_TOKEN['ERROR'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio, 'mensaje': 'Comentario multilinea no cerrado'}
                return self.token_actual
            else:
                #No es un comentario, podría ser otro token que inicia con $
                self.tome_caracter()
                #Continuamos con el procesamiento normal
        
        #Manejo de cadenas
        if caracter == '"':
            lexema += caracter
            #Consumir hasta encontrar otra comilla doble
            cadena_cerrada = False
            while not cadena_cerrada and not self.fin_archivo:
                caracter = self.deme_caracter()
                if not caracter:
                    break
                lexema += caracter
                if caracter == '"':
                    cadena_cerrada = True
            if cadena_cerrada:
                self.token_actual = {'tipo': self.TIPOS_TOKEN['LITERAL_CADENA'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio}
            else:
                self.token_actual = {'tipo': self.TIPOS_TOKEN['ERROR'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio, 'mensaje': 'Cadena no cerrada'}
            return self.token_actual

        #Procesar token normal usando matriz
        if caracter not in self.matriz.index or 'q0' not in self.matriz.columns:
            self.token_actual = {'tipo': self.TIPOS_TOKEN['ERROR'], 'lexema': caracter, 'linea': linea_inicio, 'columna': columna_inicio, 'mensaje': 'Carácter no reconocido en q0'}
            return self.token_actual

        estado_actual = self.matriz.at[caracter, 'q0']
        if not estado_actual:
            self.token_actual = {'tipo': self.TIPOS_TOKEN['ERROR'], 'lexema': caracter, 'linea': linea_inicio, 'columna': columna_inicio, 'mensaje': 'Sin transición desde q0'}
            return self.token_actual

        lexema += caracter

        while True:
            caracter = self.deme_caracter()
            if not caracter:
                break
            if caracter in [' ', '\t', '\n', '\r']:
                break
            
            #Si encontramos un delimitador o comillas, retrocedemos y cortamos el lexema
            if caracter in self.delimitadores or caracter == '"' or caracter == '$':
                self.tome_caracter()
                break

            if estado_actual != 'q9999':
                if caracter not in self.matriz.index:
                    estado_actual = 'q9999'
                else:
                    estado_destino = self.matriz.at[caracter, estado_actual]
                    if not estado_destino:
                        # Si no hay transición, retrocedemos y cortamos el lexema
                        self.tome_caracter()
                        break
                    else:
                        lexema += caracter
                        estado_actual = estado_destino
                        continue
            
            #Si llegamos a un estado de error, seguimos consumiendo caracteres
            #hasta encontrar un delimitador o espacio
            if estado_actual == 'q9999':
                lexema += caracter

        #Validar final
        if estado_actual == 'q9999':
            self.token_actual = {'tipo': self.TIPOS_TOKEN['IDENTIFICADOR'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio}
        else:
            tipo_token_codigo = self.matriz.at['FINAL', estado_actual]
            if tipo_token_codigo:
                tipo_token = int(tipo_token_codigo)
                self.token_actual = {'tipo': tipo_token, 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio}
            else:
                self.token_actual = {'tipo': self.TIPOS_TOKEN['ERROR'], 'lexema': lexema, 'linea': linea_inicio, 'columna': columna_inicio, 'mensaje': 'Estado no final'}
        return self.token_actual

    def tome_token(self):
        if not self.token_actual:
            self.deme_token()
        token_consumido = self.token_actual
        self.token_actual = None
        return token_consumido