class Scanner:
    def __init__(self):
        self.archivo = None
        self.buffer = ""
        self.posicion = 0
        self.linea_actual = 1
        self.columna_actual = 0
        self.token_actual = None
        self.fin_archivo = False
        
        # Definición de tipos de tokens
        self.TIPOS_TOKEN = {
            'IDENTIFICADOR': 1,
            'NUMERO': 2,
            'OPERADOR': 3,
            'DELIMITADOR': 4,
            'CADENA': 5,
            'COMENTARIO': 6,
            'FIN_ARCHIVO': 7,
            'ERROR': 8
        }
        
        # Caracteres especiales
        self.OPERADORES = "+-*/=<>!&|%^"
        self.DELIMITADORES = "(){};,[]."
        self.ESPACIOS = " \t\n\r"
        
    def inicializar_scanner(self, nombre_archivo):
        """Inicializa el scanner abriendo el archivo de entrada."""
        try:
            self.archivo = open(nombre_archivo, 'r')
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
        """Cierra el archivo y libera recursos."""
        if self.archivo:
            self.archivo.close()
            self.archivo = None
    
    def deme_caracter(self):
        """Lee un carácter del archivo de entrada."""
        if self.posicion >= len(self.buffer):
            # Si hemos leído todos los caracteres en el buffer, leemos más
            linea = self.archivo.readline()
            if not linea:
                self.fin_archivo = True
                return ''
            self.buffer = linea
            self.posicion = 0
        
        caracter = self.buffer[self.posicion]
        self.posicion += 1
        self.columna_actual += 1
        
        # Actualizar línea y columna si es un salto de línea
        if caracter == '\n':
            self.linea_actual += 1
            self.columna_actual = 0
        
        return caracter
    
    def tome_caracter(self):
        """Retrocede un carácter en el buffer de entrada."""
        if self.posicion > 0:
            self.posicion -= 1
            self.columna_actual -= 1
            # Si el carácter anterior era un salto de línea, ajustamos línea y columna
            if self.buffer[self.posicion] == '\n':
                self.linea_actual -= 1
                # Para calcular la columna correctamente, necesitaríamos conocer el ancho de la línea anterior
                # Por simplicidad, lo dejamos en 0
                self.columna_actual = 0
    
    def es_letra(self, caracter):
        """Verifica si un carácter es una letra."""
        return caracter.isalpha() or caracter == '_'
    
    def es_digito(self, caracter):
        """Verifica si un carácter es un dígito."""
        return caracter.isdigit()
    
    def es_espacio(self, caracter):
        """Verifica si un carácter es un espacio en blanco."""
        return caracter in self.ESPACIOS
    
    def es_operador(self, caracter):
        """Verifica si un carácter es un operador."""
        return caracter in self.OPERADORES
    
    def es_delimitador(self, caracter):
        """Verifica si un carácter es un delimitador."""
        return caracter in self.DELIMITADORES
    
    def deme_token(self):
        """
        Analiza el siguiente token del archivo de entrada.
        Retorna un diccionario con información del token.
        """
        # Ignorar espacios en blanco
        caracter = self.deme_caracter()
        while caracter and self.es_espacio(caracter):
            caracter = self.deme_caracter()
        
        # Si llegamos al final del archivo
        if not caracter:
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['FIN_ARCHIVO'],
                'lexema': '',
                'linea': self.linea_actual,
                'columna': self.columna_actual
            }
            return self.token_actual
        
        # Posición de inicio del token
        linea_inicio = self.linea_actual
        columna_inicio = self.columna_actual - 1  # Restamos 1 porque ya incrementamos al leer el carácter
        
        # Identificadores: comienzan con una letra o guion bajo
        if self.es_letra(caracter):
            lexema = caracter
            caracter = self.deme_caracter()
            while caracter and (self.es_letra(caracter) or self.es_digito(caracter)):
                lexema += caracter
                caracter = self.deme_caracter()
            
            # Retroceder un carácter ya que no es parte del identificador
            if caracter:
                self.tome_caracter()
            
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['IDENTIFICADOR'],
                'lexema': lexema,
                'linea': linea_inicio,
                'columna': columna_inicio
            }
            return self.token_actual
        
        # Números
        elif self.es_digito(caracter):
            lexema = caracter
            caracter = self.deme_caracter()
            while caracter and self.es_digito(caracter):
                lexema += caracter
                caracter = self.deme_caracter()
            
            # Manejar números con punto decimal
            if caracter == '.':
                lexema += caracter
                caracter = self.deme_caracter()
                while caracter and self.es_digito(caracter):
                    lexema += caracter
                    caracter = self.deme_caracter()
            
            # Retroceder un carácter
            if caracter:
                self.tome_caracter()
            
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['NUMERO'],
                'lexema': lexema,
                'linea': linea_inicio,
                'columna': columna_inicio
            }
            return self.token_actual
        
        # Operadores
        elif self.es_operador(caracter):
            lexema = caracter
            
            # Manejar operadores de dos caracteres (==, !=, <=, >=, &&, ||)
            siguiente = self.deme_caracter()
            if siguiente:
                if (caracter == '=' and siguiente == '=') or \
                   (caracter == '!' and siguiente == '=') or \
                   (caracter == '<' and siguiente == '=') or \
                   (caracter == '>' and siguiente == '=') or \
                   (caracter == '&' and siguiente == '&') or \
                   (caracter == '|' and siguiente == '|'):
                    lexema += siguiente
                else:
                    self.tome_caracter()
            
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['OPERADOR'],
                'lexema': lexema,
                'linea': linea_inicio,
                'columna': columna_inicio
            }
            return self.token_actual
        
        # Delimitadores
        elif self.es_delimitador(caracter):
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['DELIMITADOR'],
                'lexema': caracter,
                'linea': linea_inicio,
                'columna': columna_inicio
            }
            return self.token_actual
        
        # Cadenas de texto
        elif caracter == '"' or caracter == "'":
            delimitador = caracter
            lexema = caracter
            caracter = self.deme_caracter()
            while caracter and caracter != delimitador:
                lexema += caracter
                caracter = self.deme_caracter()
            
            if caracter == delimitador:
                lexema += caracter
                self.token_actual = {
                    'tipo': self.TIPOS_TOKEN['CADENA'],
                    'lexema': lexema,
                    'linea': linea_inicio,
                    'columna': columna_inicio
                }
            else:
                self.token_actual = {
                    'tipo': self.TIPOS_TOKEN['ERROR'],
                    'lexema': lexema,
                    'linea': linea_inicio,
                    'columna': columna_inicio,
                    'mensaje': 'Cadena no cerrada'
                }
            return self.token_actual
        
        # Comentarios
        elif caracter == '/':
            siguiente = self.deme_caracter()
            if siguiente == '/':  # Comentario de una línea
                lexema = '//'
                caracter = self.deme_caracter()
                while caracter and caracter != '\n':
                    lexema += caracter
                    caracter = self.deme_caracter()
                
                self.token_actual = {
                    'tipo': self.TIPOS_TOKEN['COMENTARIO'],
                    'lexema': lexema,
                    'linea': linea_inicio,
                    'columna': columna_inicio
                }
                return self.token_actual
            elif siguiente == '*':  # Comentario multilínea
                lexema = '/*'
                caracter = self.deme_caracter()
                cerrado = False
                while caracter and not cerrado:
                    if caracter == '*':
                        sig = self.deme_caracter()
                        if sig == '/':
                            lexema += '*/'
                            cerrado = True
                        else:
                            lexema += '*'
                            if sig:
                                self.tome_caracter()
                    else:
                        lexema += caracter
                    
                    if not cerrado:
                        caracter = self.deme_caracter()
                
                if cerrado:
                    self.token_actual = {
                        'tipo': self.TIPOS_TOKEN['COMENTARIO'],
                        'lexema': lexema,
                        'linea': linea_inicio,
                        'columna': columna_inicio
                    }
                else:
                    self.token_actual = {
                        'tipo': self.TIPOS_TOKEN['ERROR'],
                        'lexema': lexema,
                        'linea': linea_inicio,
                        'columna': columna_inicio,
                        'mensaje': 'Comentario multilínea no cerrado'
                    }
                return self.token_actual
            else:
                # Solo es un operador de división
                if siguiente:
                    self.tome_caracter()
                
                self.token_actual = {
                    'tipo': self.TIPOS_TOKEN['OPERADOR'],
                    'lexema': '/',
                    'linea': linea_inicio,
                    'columna': columna_inicio
                }
                return self.token_actual
        
        # Carácter no reconocido
        else:
            self.token_actual = {
                'tipo': self.TIPOS_TOKEN['ERROR'],
                'lexema': caracter,
                'linea': linea_inicio,
                'columna': columna_inicio,
                'mensaje': 'Carácter no reconocido'
            }
            return self.token_actual
    
    def tome_token(self):
        """
        Consume el token actual.
        Retorna True si hay más tokens disponibles, False en caso contrario.
        """
        if not self.token_actual:
            self.deme_token()
        
        # Guardar una copia del token actual antes de consumirlo
        token_consumido = self.token_actual
        self.token_actual = None
        
        # Devolver True si no hemos llegado al final del archivo
        return token_consumido['tipo'] != self.TIPOS_TOKEN['FIN_ARCHIVO']


# Ejemplo de uso
def ejemplo_uso():
    scanner = Scanner()
    
    if scanner.inicializar_scanner("codigo_fuente.txt"):
        print("Scanner inicializado correctamente.")
        
        # Procesamos todos los tokens
        while True:
            token = scanner.deme_token()
            
            print(f"Token encontrado - Tipo: {token['tipo']}, Lexema: '{token['lexema']}', Línea: {token['linea']}, Columna: {token['columna']}")
            
            if token['tipo'] == scanner.TIPOS_TOKEN['FIN_ARCHIVO']:
                print("Fin del archivo alcanzado.")
                break
            
            # Consumimos el token
            scanner.tome_token()
        
        scanner.finalizar_scanner()
        print("Scanner finalizado.")
    else:
        print("No se pudo inicializar el scanner.")


if __name__ == "__main__":
    ejemplo_uso()