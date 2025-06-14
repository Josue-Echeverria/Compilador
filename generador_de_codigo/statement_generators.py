def handle_asignacion(generator, statement):
    """Maneja la generación de código para sentencias de asignación."""
    # El método generate_assignment ya existe en la clase Generador.
    # Aquí determinamos el tipo de variable para la asignación (dw o db).
    # Esta lógica de tipo es simplificada para el ejemplo.
    target_var_name = statement["target"]
    var_type = "dw" 
    if target_var_name in ["miBooleanoVar", "miCaracterVar"]: 
        var_type = "db"
    
    generator.declare_variable(target_var_name, var_type) 
    asm_target_name = f"{generator.variable_prefix}{target_var_name}"
    
    # generate_expression devuelve el resultado en AX (o AL si es byte implícitamente)
    result_register_or_value = generator.generate_expression(statement["value"])
    
    if var_type == "db":
        # Asumimos que si es db, la parte relevante de la expresión está en AL
        generator.emit_code_line(f"mov byte ptr [{asm_target_name}], al")
    else:
        # Asumimos que el resultado de la expresión está en AX
        generator.emit_code_line(f"mov [{asm_target_name}], ax")

def handle_imprimir_constante_string(generator, statement):
    """Maneja la impresión de una constante de string predefinida."""
    const_name = statement["const_name"]
    if const_name in generator.constant_labels:
        label = generator.constant_labels[const_name]
        generator.emit_code_line(f"push offset {label}")
        generator.emit_code_line("call print")
    else:
        print(f"Error: Constante string '{const_name}' no definida.")

def handle_imprimir_newline(generator, statement):
    """Maneja la impresión de una nueva línea."""
    generator.emit_code_line(f"push offset {generator.newline_label_val}")
    generator.emit_code_line("call print")

def handle_imprimir_int(generator, statement):
    """Maneja la impresión de un entero (literal o variable).
    La llamada a preparaSsalidaEntero se alinea con la llamada a inttostring en string.asm:
    BX = puntero a una posición en el buffer de string (ej. para el último dígito o terminador).
    push offset <variable_entera>
    call preparaSsalidaEntero
    """
    source_location = ""
    if statement["source_type"] == "literal":
        generator.emit_code_line(f"mov ax, {statement['value']}")
        generator.emit_code_line(f"mov [{generator.temp_int_holder_name}], ax")
        source_location = generator.temp_int_holder_name
    elif statement["source_type"] == "variable":
        asm_var_name = f"{generator.variable_prefix}{statement['name']}"
        generator.declare_variable(statement['name'], "dw") 
        source_location = asm_var_name
    
    generator.emit_code_line(f"mov bx, offset {generator.temp_int_buffer_name}")
    generator.emit_code_line(f"add bx, 5") 

    generator.emit_code_line(f"push offset {source_location}")
    generator.emit_code_line("call inttostring") 
    
    generator.emit_code_line(f"push offset {generator.temp_int_buffer_name}")
    generator.emit_code_line("call print")

def handle_imprimir_bool(generator, statement):
    """Maneja la impresion de un booleano (literal o variable)."""
    if statement["source_type"] == "literal":
        generator.emit_code_line(f"mov al, {statement['value']}") # 0 o 1
    elif statement["source_type"] == "variable":
        asm_var_name = f"{generator.variable_prefix}{statement['name']}"
        generator.declare_variable(statement['name'], "db") 
        generator.emit_code_line(f"mov al, [{asm_var_name}]")

    # Convertir 0/1 a '0'/'1'
    generator.emit_code_line("add al, 30h") 
    # Guardar en el buffer temporal para bool
    generator.emit_code_line(f"mov byte ptr [{generator.temp_bool_buffer_name}], al")
    generator.emit_code_line(f"mov byte ptr [{generator.temp_bool_buffer_name}+1], '$'")

    generator.emit_code_line(f"push offset {generator.temp_bool_buffer_name}")
    generator.emit_code_line("call print")

def handle_imprimir_char(generator, statement):
    """Maneja la impresion de un caracter (literal o variable)."""
    if statement["source_type"] == "literal":
        char_val = statement['value']
        char_val_str = ""
        if isinstance(char_val, str) and len(char_val) == 3 and char_val.startswith("'"):
            char_val_str = char_val 
        else: 
            char_val_str = str(char_val) 
        generator.emit_code_line(f"mov al, byte ptr {char_val_str}")
    elif statement["source_type"] == "variable":
        asm_var_name = f"{generator.variable_prefix}{statement['name']}"
        generator.declare_variable(statement['name'], "db") 
        generator.emit_code_line(f"mov al, byte ptr [{asm_var_name}]")
    
    # Guardar el caracter en el buffer temporal para char
    generator.emit_code_line(f"mov byte ptr [{generator.temp_char_buffer_name}], al")
    generator.emit_code_line(f"mov byte ptr [{generator.temp_char_buffer_name}+1], '$'")

    generator.emit_code_line(f"push offset {generator.temp_char_buffer_name}")
    generator.emit_code_line("call print")

def handle_if(generator, statement):
    """Maneja la generacion de codigo para sentencias if-then-else."""
    
    condition_node = statement["condition"]
    then_statements = statement["then_statements"]
    else_statements = statement.get("else_statements") # Puede no existir

    # Generar codigo para la condicion
    # Se asume que generate_expression deja el resultado en AX
    # y que 0 es falso, no-cero es verdadero.
    generator.generate_expression(condition_node)
    generator.emit_code_line("cmp ax, 0") # Compara el resultado de la expresion con 0

    else_label = generator._get_next_label("Else")
    endif_label = generator._get_next_label("EndIf")

    if else_statements:
        generator.emit_code_line(f"je {else_label}") # Si es falso (0), salta a la seccion else
    else:
        generator.emit_code_line(f"je {endif_label}") # Si es falso (0) y no hay else, salta al final del if

    # Generar codigo para la seccion 'then'
    generator.process_ast_body(then_statements)

    if else_statements:
        generator.emit_code_line(f"jmp {endif_label}") # Salta al final del if despues de ejecutar el 'then'
        generator.emit_code_line(f"{else_label}:")
        # Generar codigo para la seccion 'else'
        generator.process_ast_body(else_statements)
    
    generator.emit_code_line(f"{endif_label}:")

def handle_while(generator, statement):
    """Maneja la generacion de codigo para sentencias while."""
    condition_node = statement["condition"]
    body_statements = statement["body_statements"]

    loop_start_label = generator._get_next_label("LoopStart")
    loop_body_label = generator._get_next_label("LoopBody") 
    loop_end_label = generator._get_next_label("LoopEnd")

    generator.loop_label_stack.append((loop_start_label, loop_end_label))

    generator.emit_code_line(f"{loop_start_label}:")
    
    generator.generate_expression(condition_node)
    generator.emit_code_line("cmp ax, 0")      
    generator.emit_code_line(f"jne {loop_body_label}") 
    generator.emit_code_line(f"jmp {loop_end_label}")  

    generator.emit_code_line(f"{loop_body_label}:")
    generator.process_ast_body(body_statements)
    
    generator.emit_code_line(f"jmp {loop_start_label}") 
    
    generator.emit_code_line(f"{loop_end_label}:")

    generator.loop_label_stack.pop()

def handle_break(generator, statement):
    """Maneja la generacion de codigo para la sentencia break."""
    if not generator.loop_label_stack:
        print("Error de compilacion: 'break' fuera de un bucle.")
        return
    
    current_loop_break_label = generator.loop_label_stack[-1][1]
    generator.emit_code_line(f"jmp {current_loop_break_label}")

def handle_continue(generator, statement):
    """Maneja la generacion de codigo para la sentencia continue."""
    if not generator.loop_label_stack:
        print("Error de compilacion: 'continue' fuera de un bucle.")
        return

    current_loop_continue_label = generator.loop_label_stack[-1]
    generator.emit_code_line(f"jmp {current_loop_continue_label}")

def handle_halt(generator, statement):
    """Maneja la generacion de codigo para la sentencia halt."""
    # La etiqueta fin_programa se define en el metodo get_assembled_code del generador.
    # Asumimos que siempre se llama asi.
    generator.emit_code_line("jmp fin_programa")

def handle_switch(generator, statement):

    """Maneja la generacion de codigo para sentencias switch."""
    expression_node = statement["expression"]
    case_list = statement.get("cases", [])
    default_statements_node = statement.get("default_statements")

    end_switch_label = generator._get_next_label("EndSwitch")
    default_block_label = generator._get_next_label("DefaultCase")
    
    generator.loop_label_stack.append({'type': 'switch', 'break': end_switch_label})

    case_block_labels = {} # Mapea valor del case a su etiqueta de bloque de codigo
    max_case_val = -1

    # Primera pasada: generar etiquetas para cada bloque case y encontrar el valor maximo
    for case_entry in case_list:
        case_val = case_entry["value"]
        if not isinstance(case_val, int) or case_val < 0:
            print(f"Error de compilacion: valor de case '{case_val}' debe ser un entero no negativo.")
            # Podria abortar la generacion para este switch o tratarlo como un error
            generator.loop_label_stack.pop() # Limpiar la pila
            return 
        max_case_val = max(max_case_val, case_val)
        case_block_labels[case_val] = generator._get_next_label(f"Case_{case_val}")

    jump_table_label = None
    if max_case_val >= 0: # Solo crear tabla si hay cases validos
        jump_table_label = generator._get_next_label("SwitchTable")
        table_entries = []
        for i in range(max_case_val + 1):
            if i in case_block_labels:
                table_entries.append(f"offset {case_block_labels[i]}")
            else:
                table_entries.append(f"offset {default_block_label}")
        generator.emit_data_line(f"{jump_table_label} dw {', '.join(table_entries)}")

    # Generar codigo para evaluar la expresion del switch
    generator.generate_expression(expression_node) # Resultado en AX

    if jump_table_label: # Si se creo una tabla de saltos
        generator.emit_code_line("cmp ax, 0")
        generator.emit_code_line(f"jl {default_block_label}") # Indice < 0, ir a default
        generator.emit_code_line(f"cmp ax, {max_case_val}")
        generator.emit_code_line(f"jg {default_block_label}") # Indice > max_case_val, ir a default
        
        generator.emit_code_line("shl ax, 1") # Multiplicar indice por 2 (tamaño de palabra)
        generator.emit_code_line(f"mov bx, offset {jump_table_label}")
        generator.emit_code_line("add bx, ax") # BX ahora apunta a la entrada de la tabla
        generator.emit_code_line("mov si, [bx]") # Cargar la direccion de destino en SI
        generator.emit_code_line("jmp si")      # Saltar a la direccion en SI
    elif default_statements_node: # No hay cases, pero hay default
        generator.emit_code_line(f"jmp {default_block_label}")
    else: # No hay cases ni default, el switch no hace nada
        generator.emit_code_line(f"jmp {end_switch_label}")

    # Generar bloques de codigo para cada case
    # El orden en case_list es importante para el fall-through
    for case_entry in case_list:
        case_val = case_entry["value"]
        # Solo procesar si el valor es valido (ya chequeado, pero por si acaso)
        if isinstance(case_val, int) and case_val >=0 and case_val in case_block_labels:
            generator.emit_code_line(f"{case_block_labels[case_val]}:")
            generator.process_ast_body(case_entry["statements"])
               # El fall-through es implicito si no hay break

    # Generar bloque de codigo para default
    generator.emit_code_line(f"{default_block_label}:")
    if default_statements_node:
        generator.process_ast_body(default_statements_node)
        # Si hay un break en el default, saltara a end_switch_label
        # Si no, caera a end_switch_label

    # Etiqueta de fin del switch
    generator.emit_code_line(f"{end_switch_label}:")
    generator.loop_label_stack.pop() # Limpiar la pila de contexto del switch
    
def handle_for(generator, statement):
    """Maneja la generacion de codigo para sentencias for."""
    initializer_node = statement.get("initializer") 
    condition_node = statement["condition"] 
    incrementer_node = statement.get("incrementer") 
    body_statements = statement["body_statements"]

    condition_label = generator._get_next_label("ForCond")
    increment_label = generator._get_next_label("ForInc")
    # body_label no es estrictamente necesario si la condicion verdadera cae directamente al cuerpo
    end_for_label = generator._get_next_label("EndFor")

    # 1. Inicializador
    if initializer_node:
        generator.process_single_statement(initializer_node)

    # 2. Etiqueta de inicio de la condicion
    generator.emit_code_line(f"{condition_label}:")
    
    # 3. Condicion
    generator.generate_expression(condition_node) # Resultado en AX
    generator.emit_code_line("cmp ax, 0")          # 0 es falso, no-cero es verdadero
    generator.emit_code_line(f"je {end_for_label}") # Si es falso, salir del bucle
# Si la condicion es verdadera, la ejecucion continua hacia el cuerpo

    # 4. Empujar contexto del bucle para break/continue
    # 'continue' para un 'for' salta a la seccion del incrementador
    generator.loop_label_stack.append({
        'type': 'for',
        'continue': increment_label, 
        'break': end_for_label
    })

    # 5. Cuerpo del bucle
    generator.process_ast_body(body_statements)

    # 6. Etiqueta del incrementador (destino para 'continue')
    generator.emit_code_line(f"{increment_label}:")
    if incrementer_node:
        generator.process_single_statement(incrementer_node)

    # 7. Saltar de nuevo a la evaluacion de la condicion
    generator.emit_code_line(f"jmp {condition_label}")

    # 8. Etiqueta de fin del bucle (destino para 'break' y salida normal por condicion falsa)
    generator.emit_code_line(f"{end_for_label}:")

    # 9. Sacar contexto del bucle de la pila
    generator.loop_label_stack.pop()
    


def handle_repeat_until(generator, statement):
    """Maneja la generacion de codigo para sentencias repeat-until."""
    body_statements = statement["body_statements"]
    condition_node = statement["condition"]

    loop_body_label = generator._get_next_label("RepeatBody")
    # Para repeat-until, 'continue' salta a la evaluacion de la condicion
    condition_eval_label = generator._get_next_label("RepeatCondEval") 
    end_loop_label = generator._get_next_label("EndRepeat")

    # Empujar contexto del bucle para break/continue
    generator.loop_label_stack.append({
        'type': 'repeat_until',
        'continue': condition_eval_label, 
        'break': end_loop_label
    })

    # 1. Etiqueta de inicio del cuerpo del bucle
    generator.emit_code_line(f"{loop_body_label}:")

    # 2. Cuerpo del bucle
    generator.process_ast_body(body_statements)

    # 3. Etiqueta para la evaluacion de la condicion (destino de 'continue')
    generator.emit_code_line(f"{condition_eval_label}:")
    
    # 4. Condicion
    generator.generate_expression(condition_node) # Resultado en AX (0 es falso, no-cero es verdadero)
    generator.emit_code_line("cmp ax, 0")          
    # El bucle se repite si la condicion es FALSA (resultado es 0)
    generator.emit_code_line(f"je {loop_body_label}") # Si es falso, repetir

    # Si la condicion es verdadera (no-cero), la ejecucion continua (sale del bucle)

    # 5. Etiqueta de fin del bucle (destino para 'break')
    generator.emit_code_line(f"{end_loop_label}:")

    # 6. Sacar contexto del bucle de la pila
    generator.loop_label_stack.pop()