import pandas as pd

# Cargar la matriz desde el CSV
df = pd.read_csv('matriz_automata.csv', encoding='utf-8-sig', index_col=0)

while True:
    print("\n--- Configurar transición ---")
    estado_actual = input("Estado actual (ej: q0): ")
    if estado_actual not in df.columns:
        print("Estado no válido.")
        continue

    caracteres = input("Caracteres (ej: abc123+-): ")
    estado_destino = input("Estado destino (ej: q1): ")

    # Llenar la matriz para cada caracter
    for caracter in caracteres:
        if caracter in df.index:
            df.at[caracter, estado_actual] = estado_destino
        else:
            print(f"Caracter '{caracter}' no está en el alfabeto, ignorado.")

    # Mostrar resumen
    print("\nTransiciones agregadas:")
    print(df[estado_actual][df[estado_actual] == estado_destino])

    # Preguntar si desea seguir
    seguir = input("\n¿Agregar otra transición? (s/n): ").lower()
    if seguir != 's':
        break

# Guardar la matriz actualizada en el CSV
df.to_csv('matriz_automata.csv', encoding='utf-8-sig')
print("\n¡Matriz actualizada y guardada en 'matriz_automata.csv'!")