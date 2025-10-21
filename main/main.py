#Autor: Marcos Gómez Martín
# Importa el módulo 'sys', que provee acceso a parámetros y funciones específicas del sistema
import sys 
# Importa el módulo 'os', que permite interactuar con el sistema operativo
import os

# 1. Intentar obtener el nombre del archivo desde la consola
if len(sys.argv) > 1:
    name = sys.argv[1]


# 4. Abrir y leer el archivo
try:
    # Validar si la ruta existe antes de intentar abrir; si no, lanzar FileNotFoundError
    if not os.path.exists(name):
        raise FileNotFoundError(name)

    with open(name, 'r', encoding="utf-8") as file:
        content = file.read()
        
        # Verificar si el archivo está vacío
        if not content.strip():
            raise ValueError("El archivo está vacío o solo contiene espacios en blanco")
        
        print(f"\n--- Contenido de {name} ---\n")
        print(content)
        print(f"\n--- Fin del contenido ---\n")
        
except FileNotFoundError:
    # Archivo no encontrado: informar y salir con código 1
    print(f"\nError: No se pudo encontrar el archivo '{name}'.")
    sys.exit(1)
except PermissionError:
    print(f"\nError: No tienes permisos para leer el archivo '{name}'.")
except ValueError as ve:
    print(f"\nAdvertencia: {ve}")
except UnicodeDecodeError:
    print(f"\nError: No se pudo decodificar el archivo '{name}'. Puede tener una codificación diferente.")
except Exception as e:
    # Capturar cualquier otro error inesperado
    print(f"\nHa ocurrido un error inesperado al intentar leer el archivo: {e}")