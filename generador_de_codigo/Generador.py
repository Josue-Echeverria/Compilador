import os
import statement_generators

class Generador:
    def __init__(self):
        self.data_lines = []
        self.code_lines = []
        self.variables = set() # Nombres de variables declaradas
        self.variables_types = {} # Mapea nombre de variable a su tipo ASM ('db', 'dw')
        self._label_counter = 0
        self.variable_prefix = "VG_"
        self._literal_label_counter = 0
        self.literals_pool = {}
        self.literal_data_lines = []
        self.constant_labels = {}

        self.temp_int_buffer_name = "VG_tempIntStr"
        self.temp_char_buffer_name = "VG_tempCharStr"
        self.temp_bool_buffer_name = "VG_tempBoolStr"
        self.newline_label_name = "VG_CRLF"
        self.temp_int_holder_name = "VG_tempIntHolder"
        
        # For character operations
        self.char_op_bool_result_var = "VG_charOpBoolRes"  # For esDigito, esAlpha
        self.char_op_char_result_var = "VG_charOpCharRes"  # For toMayuscula, toMinuscula
        
        self.newline_label_val = None
        self._common_data_initialized = False
        self.loop_label_stack = [] 
        self._initialize_handler_map()

    def _initialize_handler_map(self):
        self.handler_map = {
            "asignacion": statement_generators.handle_asignacion,
            "imprimir_constante_string": statement_generators.handle_imprimir_constante_string,
            "imprimir_newline": statement_generators.handle_imprimir_newline,
            "imprimir_int": statement_generators.handle_imprimir_int,
            "imprimir_bool": statement_generators.handle_imprimir_bool,
            "imprimir_char": statement_generators.handle_imprimir_char,
            "if": statement_generators.handle_if,
            "while": statement_generators.handle_while, 
            "break": statement_generators.handle_break, 
            "continue": statement_generators.handle_continue,
            "halt": statement_generators.handle_halt,
            "switch": statement_generators.handle_switch,
            "for": statement_generators.handle_for,
            "repeat_until": statement_generators.handle_repeat_until,
        }

    def _reset(self):
        self.data_lines = []
        self.code_lines = []
        self.variables = set()
        self.variables_types = {} 
        self._label_counter = 0
        self._literal_label_counter = 0
        self.literals_pool = {}
        self.literal_data_lines = []
        self.constant_labels = {}
        self.newline_label_val = None
        self._common_data_initialized = False
        self.loop_label_stack = []

    def _ensure_common_data_declared(self):
        if not self._common_data_initialized:
            self.emit_data_line(f"{self.temp_int_buffer_name} db 7 dup(?), '$'")
            self.emit_data_line(f"{self.temp_char_buffer_name} db 2 dup(?), '$'") # For single char + $
            self.emit_data_line(f"{self.temp_bool_buffer_name} db 6 dup(?), '$'") # "false$"
            self.emit_data_line(f"{self.temp_int_holder_name} dw ?")
            
            # Variables para resultados de operaciones de caracteres
            self.emit_data_line(f"{self.char_op_bool_result_var} db ?")      # Para esDigito, esAlpha (0 o 1)
            self.emit_data_line(f"{self.char_op_char_result_var} db ?, '$'") # Para toMayuscula, toMinuscula

            self.emit_data_line(f"{self.newline_label_name} db 13, 10, '$'")
            self.newline_label_val = self.newline_label_name
            self._common_data_initialized = True

    def _get_next_label(self, base_name="Et"):
        label = f"{base_name}{self._label_counter:03d}"
        self._label_counter += 1
        return label

    def _get_next_literal_label(self, base_name="LitStr"):
        label = f"{base_name}{self._literal_label_counter:03d}"
        self._literal_label_counter += 1
        return label

    def emit_data_line(self, line):
        self.data_lines.append(f"    {line}")

    def emit_code_line(self, line):
        self.code_lines.append(f"    {line}")

    def declare_string_literal(self, string_value):
        if string_value in self.literals_pool:
            return self.literals_pool[string_value]
        label = self._get_next_literal_label()
        self.literal_data_lines.append(f"    {label} db \"{string_value}\", '$'")
        self.literals_pool[string_value] = label
        return label

    def declare_variable(self, name, var_type="dw", initial_value="0"):
        if name not in self.variables:
            asm_var_name = f"{self.variable_prefix}{name}"
            actual_initial_value = initial_value
            
            # Ajustar valor inicial para literales de caracter
            if var_type == "db" and isinstance(initial_value, str) and \
               initial_value.startswith("'") and initial_value.endswith("'") and len(initial_value) == 3:
                # El valor ya esta como 'X', que es valido para TASM db
                pass 
            elif isinstance(initial_value, int):
                 actual_initial_value = str(initial_value) # Convertir int a string para la linea de datos
            else: # Default para otros casos o si el valor inicial no coincide con el tipo
                 actual_initial_value = "0" # Default para db y dw si no es especifico

            self.emit_data_line(f"{asm_var_name} {var_type} {actual_initial_value}")
            self.variables.add(name)
            self.variables_types[name] = var_type
        elif self.variables_types.get(name) != var_type:
            # Opcional: Advertir o error si se intenta redeclarar con tipo diferente
            # print(f"Advertencia: Variable '{name}' ya declarada como {self.variables_types.get(name)}, intentando redeclarar como {var_type}.")
            pass


    def generate_expression(self, node):
        self._ensure_common_data_declared() # Asegurar que los helpers esten declarados
        if isinstance(node, int): # Integer literal
            self.emit_code_line(f"mov ax, {node}")
            return "ax"
        elif isinstance(node, str): # Could be char literal or variable name
            if node.startswith("'") and node.endswith("'") and len(node) == 3: 
                # Es un literal de caracter, ej: 'A'
                self.emit_code_line(f"mov al, {node}") # {node} se expandira a 'A'
                self.emit_code_line("mov ah, 0")       # Limpiar AH para tener el char en AX
                return "ax" 
            # Variable name
            # Excluir operadores conocidos y palabras clave de sentencias
            elif node not in ["+", "-", "*", "/", "==", "!=", ">", "<", ">=", "<="] and \
                 node not in self.handler_map and \
                 node not in ["esDigito", "esAlpha", "toMayuscula", "toMinuscula"]: # Evitar confundir nombres de op con vars
                
                asm_var_name = f"{self.variable_prefix}{node}"
                if node not in self.variables:
                    # Idealmente, esto seria un error de "variable no declarada" detectado por el analizador semantico.
                    # Por ahora, si no esta declarada, asumimos 'dw' y la declaramos, lo cual es arriesgado.
                    # Es mejor que las variables se declaren via 'asignacion' primero.
                    print(f"Advertencia: Variable '{node}' usada en expresion sin declaracion previa explicita. Asumiendo dw.")
                    self.declare_variable(node, "dw") # Declaracion implicita riesgosa
                
                var_declared_type = self.variables_types.get(node, "dw") # Default a dw si no se encuentra
                if var_declared_type == "db":
                    self.emit_code_line(f"mov al, [{asm_var_name}]")
                    self.emit_code_line("mov ah, 0") # Poner el char en AL, limpiar AH
                else: # dw
                    self.emit_code_line(f"mov ax, [{asm_var_name}]")
                return "ax"
            else: # Nodo string no reconocido como literal o variable valida
                raise TypeError(f"Nodo de expresion string no reconocido o mal formado: {node}")

        elif isinstance(node, dict): # Complex expression
            # Unary character operations
            if node.get("type") == "unary_char_op":
                op_name = node["op"]    # e.g., "esDigito", "toMayuscula"
                operand_node = node["operand"]

                self.generate_expression(operand_node) 
                # El operando (caracter) esta ahora en AX (principalmente AL)

                if op_name in ["esDigito", "esAlpha"]:
                    self.emit_code_line(f"push offset {self.char_op_bool_result_var}")
                    self.emit_code_line("push ax") # Pasa el caracter en AL
                    self.emit_code_line(f"call {op_name}")
                    self.emit_code_line(f"mov al, [{self.char_op_bool_result_var}]")
                    self.emit_code_line("mov ah, 0") # Resultado (0 o 1) en AX
                elif op_name in ["toMayuscula", "toMinuscula"]:
                    self.emit_code_line(f"push offset {self.char_op_char_result_var}")
                    self.emit_code_line("push ax") # Pasa el caracter en AL
                    self.emit_code_line(f"call {op_name}")
                    self.emit_code_line(f"mov al, [{self.char_op_char_result_var}]")
                    self.emit_code_line("mov ah, 0") # Caracter resultado en AL, AH=0
                else:
                    raise ValueError(f"Operador de caracter unario no soportado: {op_name}")
                return "ax" # El resultado de la operacion de caracter esta en AX

            # Binary operations (arithmetic, comparison)
            elif "op" in node and "left" in node and "right" in node:
                op = node["op"]
                left_node = node["left"]
                right_node = node["right"]

                self.generate_expression(left_node)
                self.emit_code_line("push ax")
                self.generate_expression(right_node) # El resultado del lado derecho queda en AX
                self.emit_code_line("pop bx") # El resultado del lado izquierdo esta en BX

                # Ahora BX tiene el operando izquierdo, AX tiene el operando derecho

                if op == "+":
                    self.emit_code_line("add bx, ax")
                    self.emit_code_line("mov ax, bx")
                elif op == "-":
                    self.emit_code_line("sub bx, ax")
                    self.emit_code_line("mov ax, bx")
                elif op == "*":
                    self.emit_code_line("mov cx, ax") # Guardar el derecho temporalmente
                    self.emit_code_line("mov ax, bx") # Mover el izquierdo a AX
                    self.emit_code_line("mul cx")   # AX = AX * CX
                elif op == "/":
                    self.emit_code_line("mov cx, ax") # Divisor (derecho) a CX
                    self.emit_code_line("mov ax, bx") # Dividendo (izquierdo) a AX
                    self.emit_code_line("cwd")        # Extender signo de AX a DX:AX
                    self.emit_code_line("div cx")    # Cociente en AX, Resto en DX
                elif op in ["==", "!=", ">", "<", ">=", "<="]:
                    self.emit_code_line("cmp bx, ax") # Compara izquierdo (BX) con derecho (AX)
                    
                    true_label = self._get_next_label("TrueCond")
                    end_cond_label = self._get_next_label("EndCond")
                    
                    jump_instruction = ""
                    if op == "==": jump_instruction = "je"
                    elif op == "!=": jump_instruction = "jne"
                    elif op == ">": jump_instruction = "jg" 
                    elif op == "<": jump_instruction = "jl"  
                    elif op == ">=": jump_instruction = "jge" 
                    elif op == "<=": jump_instruction = "jle" 
                    
                    self.emit_code_line(f"{jump_instruction} {true_label}")
                    
                    self.emit_code_line("mov ax, 0") # Falso
                    self.emit_code_line(f"jmp {end_cond_label}")
                    
                    self.emit_code_line(f"{true_label}:")
                    self.emit_code_line("mov ax, 1") # Verdadero
                    
                    self.emit_code_line(f"{end_cond_label}:")
                else:
                    raise ValueError(f"Operador binario no soportado: {op}")
                return "ax" 
            else:
                raise TypeError(f"Tipo de nodo no soportado en expresion: {type(node)}")

    def process_ast_body(self, ast_body):
        self._ensure_common_data_declared()

        for statement in ast_body:
            stype = statement["type"]
            # Usar el handler_map de la instancia
            handler = self.handler_map.get(stype) 
            if handler:
                handler(self, statement) 
            else:
                print(f"Advertencia: Tipo de sentencia no reconocido '{stype}'")
            
            self.emit_code_line("")

    def process_single_statement(self, statement_node):
        """Procesa un unico nodo de sentencia del AST."""
        if not statement_node:
            return
        stype = statement_node["type"]
        handler = self.handler_map.get(stype)
        if handler:
            handler(self, statement_node)
        else:
            print(f"Advertencia: Tipo de sentencia no reconocido en process_single_statement '{stype}'")

    def get_assembled_code(self, ast):
        self._reset() 

        if "constants" in ast:
           for const_def in ast["constants"]:
               if const_def["type"] == "string":
                   label = self.declare_string_literal(const_def["value"])
                   self.constant_labels[const_def["name"]] = label
        
        if "body" in ast:
            self.process_ast_body(ast["body"])
        else:
            print("Advertencia: El AST no tiene 'body'.")

        from datetime import datetime
        fecha_actual = datetime.now().strftime("%d de %B de %Y, %H:%M:%S")

        full_asm_code = []
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append(f"; Archivo ensamblador generado: {fecha_actual}")
        full_asm_code.append("; Autor Compilador: Quiros Harlen y Josue Echeverria")
        full_asm_code.append("; Lenguaje Fuente: Notch Engine")
        full_asm_code.append(";---------------------------------------------------------------------")
        full_asm_code.append("")
        # Se eliminan preparaSsalidaBooleano y preparaSsalidaCaracter de extrn
        full_asm_code.append("extrn print:Far, inttostring:Far, esDigito:Far, esAlpha:Far, toMayuscula:Far, toMinuscula:Far") 
        full_asm_code.append("Assume CS:codigo, DS:datos") 
        full_asm_code.append("")

        full_asm_code.append("datos segment")
        
        common_data_lines_emitted = [line for line in self.data_lines if any(fixed_name in line for fixed_name in [
            self.temp_int_buffer_name, self.temp_char_buffer_name, self.newline_label_name,
            self.temp_bool_buffer_name, self.temp_int_holder_name
            # temp_bool_holder_name y temp_char_holder_name eliminados de esta lista
        ])]
        user_variables_data = [line for line in self.data_lines if line not in common_data_lines_emitted]
        
        if self.literal_data_lines:
            full_asm_code.extend(self.literal_data_lines)

        full_asm_code.extend(common_data_lines_emitted)
        if user_variables_data:
            full_asm_code.extend(user_variables_data)

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
        try:
            output_dir = os.path.dirname(filename)
            if output_dir and not os.path.exists(output_dir):
                 os.makedirs(output_dir)
            with open(filename, "w") as f:
                f.write(asm_code_string)
            print(f"Codigo ensamblador guardado en {filename}")
        except IOError as e:
            print(f"Error guardando archivo {filename}: {e}")

if __name__ == "__main__":
    generator = Generador()
    
    ast = {
       "constants": [ 
          {"name": "MENSAJE_INICIO", "type": "string", "value": "Inicio de Pruebas"},
          {"name": "MSG_THEN", "type": "string", "value": "Bloque THEN ejecutado"},
          {"name": "MSG_ELSE", "type": "string", "value": "Bloque ELSE ejecutado"},
          {"name": "MSG_FIN_WHILE", "type": "string", "value": "Fin del while"},
          {"name": "MSG_SWITCH_CASE0", "type": "string", "value": "Switch: Caso 0"},
          {"name": "MSG_SWITCH_CASE1", "type": "string", "value": "Switch: Caso 1"},
          {"name": "MSG_SWITCH_DEFAULT", "type": "string", "value": "Switch: Default"},
          {"name": "MSG_DENTRO_FOR", "type": "string", "value": "Dentro del FOR, i = "},
          {"name": "MSG_FIN_FOR", "type": "string", "value": "Fin del FOR"},
          {"name": "MSG_DENTRO_REPEAT", "type": "string", "value": "Dentro del REPEAT, c = "},
          {"name": "MSG_FIN_REPEAT", "type": "string", "value": "Fin del REPEAT"}
       ],
       "body": [
            {"type": "imprimir_constante_string", "const_name": "MENSAJE_INICIO"},
            {"type": "imprimir_newline"},
            
            {"type": "asignacion", "target": "miBooleanoVar", "value": 0}, 
            {"type": "asignacion", "target": "limiteFor", "value": 2}, # For mas corto
            {"type": "asignacion", "target": "valorUno", "value": 1}, 

            # Ejemplo IF-THEN-ELSE
            # if miBooleanoVar (que es 0, o sea false) then ... else ...
            {"type": "if",
             "condition": "miBooleanoVar", # generate_expression se encarga de esto
             "then_statements": [
                 {"type": "imprimir_constante_string", "const_name": "MSG_THEN"},
                 {"type": "imprimir_newline"}
             ],
             "else_statements": [
                 {"type": "imprimir_constante_string", "const_name": "MSG_ELSE"},
                 {"type": "imprimir_newline"}
             ]
            },

            # Ejemplo REPEAT-UNTIL
            {"type": "asignacion", "target": "contador_repeat", "value": 0},
            {"type": "asignacion", "target": "limite_repeat", "value": 3},
            {"type": "repeat_until",
             "body_statements": [

                 {"type": "imprimir_char", "source_type": "literal", "value": "'R'"}, # Indica Procesado (no saltado)
                 {"type": "imprimir_newline"},
                 {"type": "asignacion", "target": "contador_repeat", "value": {"op": "+", "left": "contador_repeat", "right": 1}}
             ],
             "condition": {"op": ">=", "left": "contador_repeat", "right": "limite_repeat"} # Repetir hasta que contador_repeat >= 3
            },
            {"type": "if", 
            "condition": {"op": "==", "left": "contador_repeat", "right": 1}, # if contador_repeat == 1
            "then_statements": [
                {"type": "imprimir_char", "source_type": "literal", "value": "'K'"}, # Indica Skip (Continue)
                {"type": "imprimir_newline"},
                {"type": "asignacion", "target": "contador_repeat", "value": {"op": "+", "left": "contador_repeat", "right": 1}}, # Importante para evitar bucle infinito con continue
                {"type": "continue"} # Saltara a la evaluacion de la condicion del repeat
            ]
            },
            {"type": "imprimir_constante_string", "const_name": "MSG_FIN_REPEAT"},
            {"type": "imprimir_newline"},

# Ejemplo WHILE con nueva condicion
            {"type": "while",
             "condition": { "op": "<", "left": "contador", "right": "limiteWhile" }, # contador < 3
             "body_statements": [
                 {"type": "imprimir_constante_string", "const_name": "MSG_DENTRO_WHILE"},
                 {"type": "imprimir_int", "source_type": "variable", "name": "contador"},
                 {"type": "imprimir_newline"},
                 

                 {"type": "asignacion", "target": "contador", "value": {"op": "+", "left": "contador", "right": 1}}
             ]
            },
            
            # Ejemplo WHILE con nueva condicion
            {"type": "while",
             "condition": { "op": "<", "left": "contador", "right": "limiteWhile" }, # contador < 3
             "body_statements": [
                 {"type": "imprimir_constante_string", "const_name": "MSG_DENTRO_WHILE"},
                 {"type": "imprimir_int", "source_type": "variable", "name": "contador"},
                 {"type": "imprimir_newline"},
                 
            
                 {"type": "asignacion", "target": "contador", "value": {"op": "+", "left": "contador", "right": 1}}
             ]
            },

            #  toMayuscula con variable char_c_minus ('c') -> 'C'
            {"type": "asignacion", "target": "resultadoChar", 
             "value": {"type": "unary_char_op", "op": "toMayuscula", "operand": "char_c_minus"}},
            {"type": "imprimir_constante_string", "const_name": "MSG_TO_MAYUS"},
            {"type": "imprimir_char", "source_type": "variable", "name": "resultadoChar"},
            {"type": "imprimir_newline"},

            #  toMayuscula con variable char_7_dig ('7') -> '7' (sin cambios)
            {"type": "asignacion", "target": "resultadoChar", 
             "value": {"type": "unary_char_op", "op": "toMayuscula", "operand": "char_7_dig"}},
            {"type": "imprimir_constante_string", "const_name": "MSG_TO_MAYUS"},
            {"type": "imprimir_newline"},
        ]
    }

    generated_asm = generator.get_assembled_code(ast)

    print("--- Codigo Ensamblador Generado ---")
    print(generated_asm)
    print("----------------------------------")

    generator.save_to_file(generated_asm, r"C:\Users\Asus\Cursos\AC\TASM\BIN\neasm.asm")