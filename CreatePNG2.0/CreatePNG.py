# Nombre: David Gómez ; Repositorio: https://github.com/dav8014

from pathlib import Path # Permite manejar rutas de archivos multiplataforma
import sys # Permite acceder a argumentos de la terminal y funciones del sistema
import random # Genera valores aleatorios
import string # Colección de caracteres útiles

def generar_imagenes():
    if(len(sys.argv) < 3):
        print("Uso: python CreatePNG.py <ruta de la carpeta> <numero de imagenes>")
        sys.exit(1)
    ruta = Path(sys.argv[1])
    numero_imagenes = int(sys.argv[2])
    
    try:
        # Creamos una nueva carpeta, solo crea el ultimo directorio de la ruta y lanza excepcion si ya existe
        ruta.mkdir(parents=False, exist_ok=False)
        nombre_archivo_repetido = [] # Añadir archivos repetidos
        
        for numero in range(numero_imagenes): 
            # Creamos en nombre del archivo
            nombre_archivo = ''.join(random.choice(string.ascii_letters + string.digits) for letras in range(15)) # Se fija el número de caracteres
            # Creamos una ruta completa y válida al archivo
            imagen_creada = ruta / f"{nombre_archivo}.png"
            
            if imagen_creada.exists():
                nombre_archivo_repetido.append(f"{nombre_archivo}.png") # Pasamos el nombre del archivo repetido
            else:
                imagen_creada.touch() # Crea un archivo vacío con extensión .png con el nombre generado
                
    # Manejo de errores
    except FileExistsError:
        print(f"El archivo '{ruta}' ya existe, pruebe con otro nombre.")
    except PermissionError:
        print(f"No tienes permisos para leer '{ruta}'.")
    except UnicodeDecodeError:
        print(f"No se pudo codificar '{ruta}' como UTF-8")
    except Exception as e:
        print(f"Ocurrio un error: {e}")
generar_imagenes()