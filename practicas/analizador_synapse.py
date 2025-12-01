import os
import sys

def pedirArchivo():
    if len(sys.argv) > 1:
        return sys.argv[1]
    nombre = input("Nombre del archivo:").strip()
    return nombre

def verPartidas(ruta):
    partidas = []
    errores = 0
    if not os.path.isfile(ruta):
        raise FileNotFoundError(f"El archivo '{ruta}' no esta")
    with open(ruta, encoding="utf-8") as f:
        for n_linea, linea in enumerate(f, start=1):
            linea = linea.strip()
            if not linea or linea.startswith('#'):
                continue
            partes = linea.split(';')
            if len(partes) != 4:
                errores += 1
                continue
            nombre, nivel, puntaje, minutos = [p.strip() for p in partes]
            try:
                puntaje = int(puntaje)
                minutos = int(minutos)
            except ValueError:
                errores += 1
                continue
            partidas.append({
                "nombre": nombre,
                "nivel": nivel,
                "puntaje": puntaje,
                "minutos": minutos
            })
    return partidas, errores

def comprobarDatos(partidas):
    total_partidas = len(partidas)
    jugadores_unicos = set()
    suma_puntajes = 0
    mejor_por_jugador = {}
    for p in partidas:
        nombre = p["nombre"]
        jugadores_unicos.add(nombre)
        suma_puntajes += p["puntaje"]
        if nombre not in mejor_por_jugador or p["puntaje"] > mejor_por_jugador[nombre]:
            mejor_por_jugador[nombre] = p["puntaje"]
    cantidad_jugadores = len(jugadores_unicos)
    puntuacion_media = round((suma_puntajes / total_partidas), 2) if total_partidas > 0 else 0.0
    return {
        "total_partidas": total_partidas,
        "cantidad_jugadores": cantidad_jugadores,
        "puntuacion_media": puntuacion_media,
        "mejor_por_jugador": mejor_por_jugador
    }

def crearResumen(ruta_salida, resumen, errores):
    with open(ruta_salida, "w", encoding="utf-8") as f:
        f.write("RESUMEN de las partidas\n\n")
        f.write(f"Todas las partidas: {resumen['total_partidas']}\n")
        f.write(f"Jugadores distintos: {resumen['cantidad_jugadores']}\n")
        f.write(f"Media de puntos: {resumen['puntuacion_media']}\n")
        f.write(f"Lineas saltadas: {errores}\n")

def crearRanking(ruta_salida, mejor_por_jugador):
    orden = sorted(mejor_por_jugador.items(), key=lambda x: x[1], reverse=True)
    with open(ruta_salida, "w", encoding="utf-8") as f:
        f.write("Mejores jugadores\n\n")
        for i, (nick, punt) in enumerate(orden, start=1):
            f.write(f"{nick} - {punt}\n")

def main():
    try:
        nombre = pedirArchivo()
        ruta = nombre if os.path.isabs(nombre) else os.path.join(os.getcwd(), nombre)
        partidas, errores = verPartidas(ruta)
    except FileNotFoundError as e:
        print(e)
        return
    resumen = comprobarDatos(partidas)
    carpeta = os.path.dirname(ruta) or os.getcwd()
    crearResumen(os.path.join(carpeta, "resumen_general.txt"), resumen, errores)
    crearRanking(os.path.join(carpeta, "ranking_jugadores.txt"), resumen["mejor_por_jugador"])
    print("Sin problema de lectura")
    print(f"Partidas válidas: {resumen['total_partidas']}, jugadores distintos: {resumen['cantidad_jugadores']}")
    print(f"Se crearon estos dos archivos .txt: {os.path.join(carpeta,'resumen_general.txt')}, {os.path.join(carpeta,'ranking_jugadores.txt')}")

if __name__ == "__main__":
    main()
