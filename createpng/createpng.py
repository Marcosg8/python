# Autor: Marcos Gómez Martín
# Programa sencillo para crear archivos PNG vacíos con nombres aleatorios
# Los archivos se guardan en la carpeta 'imagenes', que se crea si no existe


import os  # Módulo para trabajar con carpetas y rutas de archivos
import sys  # Módulo para acceder a argumentos y controlar la salida del programa
import random  # Módulo para generar números aleatorios
import string  # Módulo para trabajar con cadenas de texto

# Intentamos importar la librería Pillow para crear imágenes
try:
    from PIL import Image  # Clase para crear y guardar imágenes
except ImportError:
    # Si no está instalada, mostramos un error y salimos
    print('Error: Pillow no está instalado. Ejecuta: pip install pillow', file=sys.stderr)
    sys.exit(1)

# Función para generar un nombre aleatorio para el archivo PNG
# Recibe la longitud deseada y devuelve una cadena de letras y números
# Ejemplo: 'a8f3k2b1c9d0.png'
def nombre_aleatorio(longitud=10):
    letras = string.ascii_lowercase + string.digits  # Letras minúsculas y dígitos
    return ''.join(random.choice(letras) for _ in range(longitud))  # Une caracteres aleatorios

# Función que crea un PNG vacío (blanco) de 100x100 píxeles y lo guarda en la ruta indicada
def crear_png_vacio(ruta):
    img = Image.new('RGB', (100, 100), color='white')  # Imagen blanca de 100x100
    img.save(ruta, 'PNG')  # Guarda la imagen en formato PNG

def main():
    # Comprobamos que el usuario haya pasado el argumento de cantidad
    if len(sys.argv) != 2:
        print('Uso: python createpng.py <cantidad>', file=sys.stderr)  # Mensaje de ayuda
        sys.exit(1)  # Salimos si no hay argumento
    # Intentamos convertir el argumento a entero
    try:
        cantidad = int(sys.argv[1])  # Número de imágenes a crear
    except ValueError:
        print('Error: la cantidad debe ser un número entero', file=sys.stderr)  # Error si no es entero
        sys.exit(1)
    # Validamos que la cantidad sea mayor que cero
    if cantidad <= 0:
        print('Error: la cantidad debe ser mayor que 0', file=sys.stderr)
        sys.exit(1)
    carpeta = 'imagenes'  # Nombre de la carpeta donde se guardarán los PNG
    try:
        os.makedirs(carpeta, exist_ok=True)  # Crea la carpeta si no existe
    except OSError as e:
        print(f'Error creando la carpeta {carpeta}: {e}', file=sys.stderr)  # Error si no se puede crear
        sys.exit(1)
    # Bucle para crear la cantidad de imágenes solicitadas
    for i in range(cantidad):
        nombre = nombre_aleatorio(12) + '.png'  # Genera nombre aleatorio para el archivo
        ruta = os.path.join(carpeta, nombre)  # Ruta completa del archivo
        try:
            crear_png_vacio(ruta)  # Crea y guarda el PNG vacío
        except Exception as e:
            print(f'Error guardando {ruta}: {e}', file=sys.stderr)  # Error si no se puede guardar
    # Mensaje final indicando cuántos archivos se crearon y dónde
    print(f'Se crearon {cantidad} PNG vacíos en la carpeta "{carpeta}"')

if __name__ == '__main__':
    main()
