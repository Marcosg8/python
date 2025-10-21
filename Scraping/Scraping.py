# Script para hacer scraping de una página local y extraer el texto de un elemento por id

import requests  # Librería para hacer peticiones HTTP
from bs4 import BeautifulSoup  # Librería para analizar HTML
from bs4.element import Tag  # Tipo para elementos HTML
from typing import cast  # Para indicar el tipo de una variable

url = "http://127.0.0.1:5500/index.html"  # URL de la página a analizar

try:
    # Intentar obtener la respuesta HTTP
    response = requests.get(url)  # Realiza la petición GET
    response.raise_for_status()  # Lanza excepción si el status no es 200
except requests.exceptions.RequestException as e:
    # Si ocurre cualquier error de red, lo mostramos y salimos
    print(f"Error al hacer la petición: {e}")
    exit(1)

try:
    # Analizar el contenido HTML recibido
    soup = BeautifulSoup(response.content, "html.parser")  # Parsea el HTML
    # Buscar el elemento con id 'Sostenible'
    dat0 = cast(Tag, soup.find(id="Sostenible"))
    # Si no se encuentra el elemento, lanzamos un error
    if dat0 is None:
        raise ValueError("No se encontró el elemento con id 'Sostenible'")
    # Imprimir el texto del elemento encontrado
    print(f"El dato es: {dat0.get_text(strip=True)}")
except Exception as e:
    # Si ocurre cualquier error al procesar el HTML, lo mostramos y salimos
    print(f"Error procesando el HTML: {e}")
    exit(1)