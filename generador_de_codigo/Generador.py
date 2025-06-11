import os

class Generador:
    def __init__(self):
        self.data_lines = []  # Para lineas en el segmento 'datos' (ej: "VG_varName dw 0")
        self.code_lines = []  # Para lineas en el segmento 'codigo' (ej: "    mov ax, VG_varName")
        self.variables = set() # Para rastrear nombres de variables declaradas (sin el prefijo VG_)
        self._label_counter = 0
        self.variable_prefix = "VG_" # Prefijo para variables globales

    def _reset(self):
        """Limpia cualquier codigo y variables generados previamente."""
        self.data_lines = []
        self.code_lines = []
        self.variables = set()
        self._label_counter = 0

    def _get_next_label(self, base_name="Et"):
        """Genera una etiqueta unica."""
        label = f"{base_name}{self._label_counter:03d}" # Ej: Et000, Et001
        self._label_counter += 1
        return label

    def emit_data_line(self, line):
        """Anade una linea al segmento 'datos'. Se espera algo como 'VG_varName dw 0'."""
        self.data_lines.append(f"    {line}") # Anadir indentacion

    def emit_code_line(self, line):
        """Anade una linea de instruccion ensamblador al segmento 'codigo'."""
        self.code_lines.append(f"    {line}") # Anadir indentacion

    def declare_variable(self, name, var_type="dw", initial_value="0"):
        """
        Declara una variable en el segmento 'datos' si no ha sido declarada.
        Usa el prefijo VG_ para el nombre en ensamblador.
        'name' es el nombre original de la variable.
        """
        if name not in self.variables:
            asm_var_name = f"{self.variable_prefix}{name}"
            # Para literales de cadena grandes, se almacenarian en un pool de literales
            # y aqui se declararia una referencia o la propia cadena.
            self.emit_data_line(f"{asm_var_name} {var_type} {initial_value}")
            self.variables.add(name) # Guardar el nombre original

    def generate_literal_to_register(self, value, register="ax"):
        """Genera codigo para mover un valor literal a un registro."""
        # En el futuro, manejar aqui la pila paralela de tipos:
        # self.pila_paralela_tipos.push(TEntero) o similar
        self.emit_code_line(f"mov {register}, {value}")
        return register

    def generate_variable_to_register(self, var_name, register="ax"):
        """
        Genera codigo para mover el valor de una variable a un registro.
        'var_name' es el nombre original de la variable.
        """
        self.declare_variable(var_name) # Asegurar que la variable este declarada (con prefijo VG_)
        asm_var_name = f"{self.variable_prefix}{var_name}"
        
        # Aqui se necesitaria informacion del tipo de var_name para la pila paralela de tipos
        # y para decidir si mover el valor directamente o un puntero.
        self.emit_code_line(f"mov {register}, {asm_var_name}") 
        return register

    def generate_expression(self, node):
        """
        Genera codigo ensamblador para una expresion.
        El resultado de la expresion estara en el registro AX.
        Deberia interactuar con una pila paralela de tipos.
        """
        if isinstance(node, int):
            # PilaParalelaTipos.push(TEntero)
            return self.generate_literal_to_register(node, "ax")
        elif isinstance(node, str):  # Nombre de variable
            # TipoActual = TablaSimbolos.get_tipo(node)
            # PilaParalelaTipos.push(TipoActual)
            # if TipoActual es grande (string, set):
            #   generar codigo para cargar direccion en AX (ej. lea ax, VG_node)
            # else:
            return self.generate_variable_to_register(node, "ax")
        elif isinstance(node, dict):  # Operacion binaria
            op = node["op"]
            left_node = node["left"]
            right_node = node["right"]

            # Generar codigo para operando izquierdo
            self.generate_expression(left_node) # Resultado en AX
            # tipo_izq = PilaParalelaTipos.pop()
            self.emit_code_line("push ax")

            # Generar codigo para operando derecho
            self.generate_expression(right_node) # Resultado en AX
            # tipo_der = PilaParalelaTipos.pop()
            self.emit_code_line("pop bx") # AX = operando_derecho, BX = operando_izquierdo

            # Aqui se realizarian chequeos de tipo usando tipo_izq y tipo_der
            # y se podrian llamar a rutinas de conversion si es necesario (ej. str2int)
            # if tipo_izq != TEntero or tipo_der != TEntero: error o conversion

            if op == "+":
                self.emit_code_line("add bx, ax")
                self.emit_code_line("mov ax, bx")
            elif op == "-":
                self.emit_code_line("sub bx, ax")
                self.emit_code_line("mov ax, bx")
            elif op == "*":
                self.emit_code_line("imul bx") # AX = AX * BX
            elif op == "/":
                # Chequeo de division por cero:
                # self.emit_code_line("cmp ax, 0") ; AX tiene el divisor (operando_derecho)
                # et_error_div_cero = self._get_next_label("ErrDivCero")
                # self.emit_code_line(f"je {et_error_div_cero}")
                self.emit_code_line("mov cx, ax") # CX = divisor (derecho)
                self.emit_code_line("mov ax, bx") # AX = dividendo (izquierdo)
                self.emit_code_line("cwd")      # Extender signo de AX a DX:AX
                self.emit_code_line("idiv cx")  # AX = cociente, DX = resto
                # self.emit_code_line(f"{et_error_div_cero}: ; Manejo del error aqui")
            else:
                raise ValueError(f"Operador binario no soportado: {op}")
            # PilaParalelaTipos.push(TEnteroResultado) o el tipo resultante
            return "ax"
        else:
            raise TypeError(f"Tipo de nodo no soportado en expresion: {type(node)}")

    def generate_assignment(self, target_var_name, value_node):
        """
        Genera codigo para una sentencia de asignacion: VG_destino = valor.
        'target_var_name' es el nombre original de la variable.
        """
        self.declare_variable(target_var_name) 
        asm_target_name = f"{self.variable_prefix}{target_var_name}"
        
        result_register = self.generate_expression(value_node) # Resultado en AX
        # tipo_valor = PilaParalelaTipos.pop()
        # tipo_target = TablaSimbolos.get_tipo(target_var_name)
        # Chequear compatibilidad de tipos y realizar conversiones si es necesario
        
        self.emit_code_line(f"mov {asm_target_name}, {result_register}")

    def process_ast_body(self, ast_body):
        """Procesa la lista de sentencias en el cuerpo del AST."""
        for statement in ast_body:
            if statement["type"] == "asignacion":
                self.generate_assignment(statement["target"], statement["value"])
                self.emit_code_line("") # Linea en blanco para legibilidad
            # Aqui se manejarian otros tipos de sentencias como if, while, etc.
            # llamando a metodos como generate_if_start, generate_while_condition, etc.

    def get_assembled_code(self, ast):
        """
        Genera la cadena completa de codigo ensamblador a partir del AST.
        """
        self._reset() 

        if "body" in ast:
            self.process_ast_body(ast["body"])
        else:
            print("Advertencia: El AST no tiene 'body'. Generando segmento de codigo vacio.")

        # Obtener la fecha actual para la portada
        from datetime import datetime
        fecha_actual = datetime.now().strftime("%d de %B de %Y, %H:%M:%S")

        full_asm_code = []
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append(f"; Archivo ensamblador generado automaticamente por el compilador")
        full_asm_code.append(f"; Fecha de generacion: {fecha_actual}")
        full_asm_code.append("; Autor del Compilador: Quiros Harlen y Josue Echeverria")
        full_asm_code.append("; Lenguaje Fuente: Notch Engine")
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append("")

        # Definicion del segmento de pila segun 12. Generacion de Codigo.txt
        full_asm_code.append("pila segment stack 'stack'")
        full_asm_code.append("    dw 1024 dup(?) ; Tamano de la pila (ej: 1024 palabras = 2KB)")
        full_asm_code.append("pila ends")
        full_asm_code.append("")
        
        full_asm_code.append("Assume CS:codigo, DS:datos, SS:pila") # SS apunta al segmento de pila
        full_asm_code.append("")

        full_asm_code.append("datos segment public 'data'") # 'public' y 'data' son convenciones comunes
        # Segun 12. Generacion de Codigo.txt, aqui podria ir un include para el pool de literales
        # full_asm_code.append("    ; include pool_de_literales.plt")
        if not self.data_lines:
            full_asm_code.append("    ; No hay variables de datos declaradas")
        else:
            full_asm_code.extend(self.data_lines)
        full_asm_code.append("datos endS")
        full_asm_code.append("")

        full_asm_code.append("codigo segment public 'code'") # 'public' y 'code' son convenciones comunes
        # Segun 12. Generacion de Codigo.txt, aqui podria ir un include para el runtime
        # full_asm_code.append("    ; include runtime.asm")
        # full_asm_code.append("")
        # full_asm_code.append("    ; --- INICIO DE RUTINAS (si las hubiera) ---")
        # ... aqui se generaria el codigo de las rutinas ...
        # full_asm_code.append("    ; --- FIN DE RUTINAS ---")
        # full_asm_code.append("")

        main_program_label = "inicio_principal" # Etiqueta para el programa principal
        full_asm_code.append(f"{main_program_label}:")
        full_asm_code.append("    ; Inicializar Registros de Segmento")
        full_asm_code.append("    mov ax, datos")
        full_asm_code.append("    mov ds, ax")
        full_asm_code.append("    mov ax, pila") # Asegurar que ES (si se usa para algo) o SS esten bien
        full_asm_code.append("    mov ss, ax   ") # SS ya deberia estar bien por la carga del .EXE, pero explicito no dana

        full_asm_code.append("")

        full_asm_code.extend(self.code_lines) 

        full_asm_code.append("")
        full_asm_code.append("fin_programa:") # Etiqueta para el final del codigo principal
        full_asm_code.append("    mov ah, 4Ch")
        full_asm_code.append("    xor al, al")
        full_asm_code.append("    int 21h")
        full_asm_code.append("codigo endS")
        full_asm_code.append("")
        full_asm_code.append(f"end {main_program_label}")
        full_asm_code.append("; --- FIN DEL PROGRAMA GENERADO ---")

        return "\n".join(full_asm_code)

    def save_to_file(self, asm_code_string, filename="output.asm"):
        """Guarda la cadena de codigo ensamblador proporcionada a un archivo."""
        try:
            os.makedirs(os.path.dirname(filename), exist_ok=True)
            with open(filename, "w") as f:
                f.write(asm_code_string)
            print(f"Codigo ensamblador guardado exitosamente en {filename}")
        except IOError as e:
            print(f"Error guardando archivo {filename}: {e}")

# Ejemplo de Uso y Prueba:
if __name__ == "__main__":
    ast = {
        "body": [
            {"type": "asignacion", "target": "a", "value": 5},
            {"type": "asignacion", "target": "b", "value": 7},
            {"type": "asignacion", "target": "c", "value": {
                "op": "+", "left": "a", "right": "b" # c = VG_a + VG_b
            }},
            {"type": "asignacion", "target": "d", "value": {
                "op": "-", "left": "c", "right": "a" # d = VG_c - VG_a
            }},
            {"type": "asignacion", "target": "e", "value": {
                "op": "*", "left": "a", "right": "b" # e = VG_a * VG_b
            }},
            {"type": "asignacion", "target": "f", "value": { # f = VG_e / VG_a
                "op": "/", "left": "e", "right": "a" 
            }},
        ]
    }

    generator = Generador()
    generated_asm = generator.get_assembled_code(ast)

    print("--- Codigo Ensamblador Generado ---")
    print(generated_asm)
    print("----------------------------------")

    generator.save_to_file(generated_asm, r"C:\Users\Asus\Cursos\AC\TASM\BIN\generated_program.asm")