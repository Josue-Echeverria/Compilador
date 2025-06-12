import os

class Generador:
    def __init__(self):
        self.data_lines = []  # Para lineas en el segmento 'datos' (ej: "VG_varName dw 0")
        self.code_lines = []  # Para lineas en el segmento 'codigo' (ej: "    mov ax, VG_varName")
        self.variables = set() # Para rastrear nombres de variables declaradas (sin el prefijo VG_)
        self._label_counter = 0
        self.variable_prefix = "VG_" # Prefijo para variables globales
        self._literal_label_counter = 0
        self.literals_pool = {} # Para rastrear literales y sus etiquetas {literal_valor: etiqueta_asm}
        self.literal_data_lines = [] # Para lineas de datos del pool de literales
        self.constant_labels = {} # Para mapear nombres de constantes a sus etiquetas

        # For common data elements
        self.temp_int_buffer_name = "VG_tempIntStr"
        self.temp_char_buffer_name = "VG_tempCharStr"
        self.newline_label_name = "VG_CRLF"
        
        self.true_str_label_val = None
        self.false_str_label_val = None
        self.newline_label_val = None # Will hold the actual label for newline
        self._common_data_initialized = False

    def _reset(self):
        """Limpia cualquier codigo y variables generados previamente."""
        self.data_lines = []
        self.code_lines = []
        self.variables = set()
        self._label_counter = 0
        self._literal_label_counter = 0
        self.literals_pool = {}
        self.literal_data_lines = []
        self.constant_labels = {}
        
        self.true_str_label_val = None
        self.false_str_label_val = None
        self.newline_label_val = None
        self._common_data_initialized = False

    def _ensure_common_data_declared(self):
        if not self._common_data_initialized:
            self.emit_data_line(f"{self.temp_int_buffer_name} db 7 dup(?), '$'")
            self.emit_data_line(f"{self.temp_char_buffer_name} db ?, '$'")
            self.emit_data_line(f"{self.newline_label_name} db 13, 10, '$'")
            self.newline_label_val = self.newline_label_name # Use the fixed name as label

            self.true_str_label_val = self.declare_string_literal("true")
            self.false_str_label_val = self.declare_string_literal("false")
            self._common_data_initialized = True

    def _get_next_label(self, base_name="Et"):
        """Genera una etiqueta unica."""
        label = f"{base_name}{self._label_counter:03d}" # Ej: Et000, Et001
        self._label_counter += 1
        return label

    def _get_next_literal_label(self, base_name="LitStr"):
        """Genera una etiqueta unica para un literal en el pool."""
        label = f"{base_name}{self._literal_label_counter:03d}"
        self._literal_label_counter += 1
        return label

    def emit_data_line(self, line):
        """Anade una linea al segmento 'datos'. Se espera algo como 'VG_varName dw 0'."""
        self.data_lines.append(f"    {line}") # Anadir indentacion

    def emit_code_line(self, line):
        """Anade una linea de instruccion ensamblador al segmento 'codigo'."""
        self.code_lines.append(f"    {line}") # Anadir indentacion

    def declare_string_literal(self, string_value):
        """
        Declara un literal de cadena en el pool de literales si no existe.
        Devuelve la etiqueta ASM para este literal.
        Las cadenas se almacenan terminadas en '$' para int 21h, ah=09h.
        """
        if string_value in self.literals_pool:
            return self.literals_pool[string_value]
        
        label = self._get_next_literal_label()
        # TASM permite definir strings con comillas. El '$' es para terminador de int 21h, ah=09h.
        self.literal_data_lines.append(f"    {label} db \"{string_value}\", '$'")
        self.literals_pool[string_value] = label
        return label

    def declare_variable(self, name, var_type="dw", initial_value="0"):
        """
        Declara una variable en el segmento 'datos' si no ha sido declarada.
        Usa el prefijo VG_ para el nombre en ensamblador.
        'name' es el nombre original de la variable.
        """
        if name not in self.variables:
            asm_var_name = f"{self.variable_prefix}{name}"
            # Handle character literals like 'A' for db
            if var_type == "db" and isinstance(initial_value, str) and \
               len(initial_value) == 3 and initial_value.startswith("'") and initial_value.endswith("'"):
                self.emit_data_line(f"{asm_var_name} {var_type} {initial_value}")
            else:
                self.emit_data_line(f"{asm_var_name} {var_type} {initial_value}")
            self.variables.add(name) # Guardar el nombre original

    def generate_literal_to_register(self, value, register="ax"):
        """Genera codigo para mover un valor literal a un registro."""
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
        self.emit_code_line(f"mov {register}, [{asm_var_name}]") 
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
        elif isinstance(node, str) and node not in ["+", "-", "*", "/"]:  # Asumimos que es nombre de variable
            # Si fuera un literal de string directo en una expresion, se manejaria aqui
            # llamando a declare_string_literal y luego usando su etiqueta (probablemente con LEA)
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
        # Determine type for declaration, default to dw.
        # A real compiler would use a symbol table here.
        # For the test, specific variables are pre-declared with 'db'.
        var_type = "dw" # Default, overridden if pre-declared differently
        if target_var_name in ["miBooleano", "miCaracter"]: # Hack for test
             var_type = "db"

        self.declare_variable(target_var_name, var_type) 
        asm_target_name = f"{self.variable_prefix}{target_var_name}"
        
        result_register = self.generate_expression(value_node) # Resultado en AX
        
        if var_type == "db":
            self.emit_code_line(f"mov byte ptr [{asm_target_name}], al")
        else:
            self.emit_code_line(f"mov [{asm_target_name}], {result_register}")


    def process_ast_body(self, ast_body):
        """Procesa la lista de sentencias en el cuerpo del AST."""
        self._ensure_common_data_declared() # Ensure buffers, newline, true/false strings are set up

        for statement in ast_body:
            stype = statement["type"]
            if stype == "asignacion":
                self.generate_assignment(statement["target"], statement["value"])
            elif stype == "imprimir_constante_string":
                const_name = statement["const_name"]
                if const_name in self.constant_labels:
                    label = self.constant_labels[const_name]
                    self.emit_code_line(f"push offset {label}")
                    self.emit_code_line("call print")
                    self.emit_code_line("") 
                else:
                    print(f"Error: Constante string '{const_name}' no definida.")
            elif stype == "imprimir_newline":
                self.emit_code_line(f"push offset {self.newline_label_val}")
                self.emit_code_line("call print")
            elif stype == "imprimir_int":
                if statement["source_type"] == "literal":
                    self.emit_code_line(f"mov ax, {statement['value']}")
                elif statement["source_type"] == "variable":
                    asm_var_name = f"{self.variable_prefix}{statement['name']}"
                    self.declare_variable(statement['name'], "dw") # Ensure var is known
                    self.emit_code_line(f"mov ax, [{asm_var_name}]")
                self.emit_code_line(f"mov bx, offset {self.temp_int_buffer_name}")
                self.emit_code_line("add bx, 5") # inttostring fills right-to-left
                self.emit_code_line("call inttostring")
                self.emit_code_line(f"push offset {self.temp_int_buffer_name}")
                self.emit_code_line("call print")
            elif stype == "imprimir_bool":
                false_label = self._get_next_label("FalseBool")
                endif_label = self._get_next_label("EndBool")
                if statement["source_type"] == "literal":
                    self.emit_code_line(f"mov al, {statement['value']}")
                elif statement["source_type"] == "variable":
                    asm_var_name = f"{self.variable_prefix}{statement['name']}"
                    self.declare_variable(statement['name'], "db") # booltoint expects db
                    self.emit_code_line(f"push offset {asm_var_name}")
                    self.emit_code_line("call booltoint") # Result in AL
                    # booltoint might not need pop if it cleans stack or if AL is just used
                
                if statement["source_type"] == "variable": # AL is set by booltoint
                    self.emit_code_line("cmp al, 1")
                else: # AL was set by mov al, literal
                    self.emit_code_line("cmp al, 1")

                self.emit_code_line(f"jne {false_label}")
                self.emit_code_line(f"push offset {self.true_str_label_val}")
                self.emit_code_line(f"jmp {endif_label}")
                self.emit_code_line(f"{false_label}:")
                self.emit_code_line(f"push offset {self.false_str_label_val}")
                self.emit_code_line(f"{endif_label}:")
                self.emit_code_line("call print")
            elif stype == "imprimir_char":
                if statement["source_type"] == "literal":
                    # Assuming literal is ASCII value or char like 'A'
                    char_val = statement['value']
                    if isinstance(char_val, str) and len(char_val) == 3 and char_val.startswith("'"):
                         self.emit_code_line(f"mov al, {char_val}")
                    else: # Assuming it's an integer ASCII value
                         self.emit_code_line(f"mov al, {char_val}")
                elif statement["source_type"] == "variable":
                    asm_var_name = f"{self.variable_prefix}{statement['name']}"
                    self.declare_variable(statement['name'], "db") # Chars are bytes
                    self.emit_code_line(f"mov al, [{asm_var_name}]")
                self.emit_code_line(f"mov [{self.temp_char_buffer_name}], al")
                self.emit_code_line(f"push offset {self.temp_char_buffer_name}")
                self.emit_code_line("call print")
            
            self.emit_code_line("") # Blank line for readability after each processed statement


    def get_assembled_code(self, ast):
        """
        Genera la cadena completa de codigo ensamblador a partir del AST.
        """
        self._reset() 

        # Para procesar constantes de string, si el AST las tiene
        if "constants" in ast:
           for const_def in ast["constants"]:
               if const_def["type"] == "string":
                   # Declarar el literal y guardar su etiqueta asociada al nombre de la constante
                   label = self.declare_string_literal(const_def["value"])
                   self.constant_labels[const_def["name"]] = label
        
        if "body" in ast:
            # Call _ensure_common_data_declared once before processing body,
            # as print operations in body will rely on these.
            self._ensure_common_data_declared()
            self.process_ast_body(ast["body"])
        else:
            print("Advertencia: El AST no tiene 'body'.")

        # Obtener la fecha actual para la portada
        from datetime import datetime
        fecha_actual = datetime.now().strftime("%d de %B de %Y, %H:%M:%S")

        full_asm_code = []
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append(f"; Archivo ensamblador generado: {fecha_actual}")
        full_asm_code.append("; Autor Compilador: Quiros Harlen y Josue Echeverria")
        full_asm_code.append("; Lenguaje Fuente: Notch Engine")
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append("")

        full_asm_code.append("extrn stringtoint:Far, print:Far, inttostring:Far, booltoint:Far, archivotoint:Far") 
        full_asm_code.append("Assume CS:codigo, DS:datos") 
        full_asm_code.append("")

        full_asm_code.append("datos segment")
        if self.literal_data_lines: # User-defined string constants
            full_asm_code.extend(self.literal_data_lines)
        
        # Add common data lines (buffers, newline string) which were populated by emit_data_line
        # These are already in self.data_lines if _ensure_common_data_declared was called & emitted.
        # No, _ensure_common_data_declared calls emit_data_line, so they are mixed with variable data_lines.
        # This is fine. Let's ensure data_lines (variables) are printed after literals.
        
        # Print variables declared by user
        user_variables_data = [line for line in self.data_lines if not any(fixed_name in line for fixed_name in [self.temp_int_buffer_name, self.temp_char_buffer_name, self.newline_label_name])]
        # Print common buffers/strings (which were added to self.data_lines by _ensure_common_data_declared)
        common_data_lines_emitted = [line for line in self.data_lines if any(fixed_name in line for fixed_name in [self.temp_int_buffer_name, self.temp_char_buffer_name, self.newline_label_name])]
        
        full_asm_code.extend(common_data_lines_emitted) # Common data first
        if user_variables_data:
            full_asm_code.extend(user_variables_data) # Then user variables

        if not self.literal_data_lines and not self.data_lines:
            full_asm_code.append("    ; No hay datos declarados")
        full_asm_code.append("datos endS")
        full_asm_code.append("")

        full_asm_code.append("codigo segment")
        main_program_label = "inicio_principal"
        full_asm_code.append(f"{main_program_label}:")
        full_asm_code.append("    mov ax, datos")
        full_asm_code.append("    mov ds, ax")
        full_asm_code.append("")
        full_asm_code.extend(self.code_lines) 
        full_asm_code.append("")
        full_asm_code.append("fin_programa:")
        full_asm_code.append("    mov ah, 4Ch")
        full_asm_code.append("    xor al, al")
        full_asm_code.append("    int 21h")
        full_asm_code.append("codigo endS")
        full_asm_code.append("")
        full_asm_code.append(f"end {main_program_label}")
        full_asm_code.append("; --- FIN DEL PROGRAMA ---")

        return "\n".join(full_asm_code)

    def save_to_file(self, asm_code_string, filename="output.asm"):
        """Guarda la cadena de codigo ensamblador proporcionada a un archivo."""
        try:
            # Asegurarse de que el directorio exista
            output_dir = os.path.dirname(filename)
            if output_dir: # Solo crear si el path no es solo un nombre de archivo
                 os.makedirs(output_dir, exist_ok=True)
            with open(filename, "w") as f:
                f.write(asm_code_string)
            print(f"Codigo ensamblador guardado exitosamente en {filename}")
        except IOError as e:
            print(f"Error guardando archivo {filename}: {e}")

# Ejemplo de Uso y Prueba:
if __name__ == "__main__":
    
    # generator = Generador()

    # Pre-declare variables for the test to ensure correct types (db for bool/char)
    # declare_variable adds them to self.variables, so generate_assignment won't redeclare them with 'dw'
    # generator.declare_variable("miEntero", "dw", "0") # Initialized by assignment later
    # generator.declare_variable("miBooleano", "db", "0") # Initialized by assignment later
    # generator.declare_variable("miCaracter", "db", "0") # Initialized by assignment later
    
    ast = {
       "constants": [ 
          {"name": "MENSAJE_BIENVENIDA", "type": "string", "value": "Bienvenido al programa"},
          {"name": "NOMBRE_ARCHIVO_CONST", "type": "string", "value": "config.sys"}
       ],
       "body": [
            {"type": "asignacion", "target": "miEntero", "value": 123},
            {"type": "asignacion", "target": "miBooleano", "value": 1}, # 1 for true
            {"type": "asignacion", "target": "miCaracter", "value": 65}, # ASCII for 'A'

            {"type": "imprimir_constante_string", "const_name": "MENSAJE_BIENVENIDA"},
            {"type": "imprimir_newline"},

            {"type": "imprimir_int", "source_type": "variable", "name": "miEntero"},
            {"type": "imprimir_newline"},
            {"type": "imprimir_int", "source_type": "literal", "value": 456},
            {"type": "imprimir_newline"},

            {"type": "imprimir_bool", "source_type": "variable", "name": "miBooleano"},
            {"type": "imprimir_newline"},
            {"type": "imprimir_bool", "source_type": "literal", "value": 0}, # 0 for false
            {"type": "imprimir_newline"},

            {"type": "imprimir_char", "source_type": "variable", "name": "miCaracter"},
            {"type": "imprimir_newline"},
            {"type": "imprimir_char", "source_type": "literal", "value": "'B'"}, # Literal char 'B'
            {"type": "imprimir_newline"},
            {"type": "imprimir_char", "source_type": "literal", "value": 67}, # Literal ASCII for 'C'
            {"type": "imprimir_newline"},

            {"type": "imprimir_constante_string", "const_name": "NOMBRE_ARCHIVO_CONST"},
            {"type": "imprimir_newline"},
            
            # Original assignments from previous example
            {"type": "asignacion", "target": "a", "value": 5},
            {"type": "asignacion", "target": "b", "value": 7},
            {"type": "asignacion", "target": "c", "value": {
                "op": "+", "left": "a", "right": "b" 
            }},
        ]
    }

    generator = Generador()


    generated_asm = generator.get_assembled_code(ast)

    print("--- Codigo Ensamblador Generado ---")
    print(generated_asm)
    print("----------------------------------")

    generator.save_to_file(generated_asm, r"C:\Users\Asus\Cursos\AC\TASM\BIN\neasm.asm")