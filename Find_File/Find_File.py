# Autor: Marcos Gómez Martín

# Importa el módulo 'sys', que provee acceso a parámetros y funciones específicas del sistema
import sys
# Importa el módulo 'os', que permite interactuar con el sistema operativo
import os


# Mensaje de error por stderr
def eprint(msg):
    print(msg, file=sys.stderr)

# si no hay 2 argumentos, lanzar error
if len(sys.argv) != 3:
    eprint('Error: falta ruta o término.')
    sys.exit(1)

ruta = sys.argv[1]
termino = sys.argv[2]

# si termino está vacío, lanzar error
if termino == '':
    eprint('Error: no se indicó el carácter o cadena a buscar')
    sys.exit(1)
# si no existe la ruta, lanzar error
if not os.path.exists(ruta):
    eprint(f"Error: no existe el archivo '{ruta}'")
    sys.exit(1)

try:# abrir el archivo y empieza a leerlo
    f = open(ruta, 'r', encoding='utf-8')
    texto = f.read()
    f.close()

    # contar veces que aparece la subcadena
    veces = texto.count(termino)

    # imprimir solo el número
    print(veces)
    
# si no existe la ruta, lanzar error
except PermissionError:
    eprint('Error: permiso denegado')
    sys.exit(1)
    # si no se puede leer con UTF-8, lanzar error
except UnicodeDecodeError:
    eprint('Error: no se puede leer el archivo con UTF-8')
    sys.exit(1)
    # Capturar cualquier otro error inesperado
except Exception as e:
    eprint('Error inesperado: ' + str(e))
    sys.exit(1)