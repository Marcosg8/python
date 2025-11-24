Proyecto: Cargar tickets (facturas) en MySQL

Descripción
Este directorio contiene un script SQL generado a partir de los archivos en `facturas/` y un runner en Python que ejecuta ese SQL contra un servidor MySQL local (por ejemplo el MySQL de XAMPP). Sirve para crear la base `tienda`, sus tablas y poblarlas con los datos extraídos de las facturas.

Archivos principales
- `InsertUnderlineTicket.sql` — Script SQL completo (incluye `DROP DATABASE IF EXISTS`, `CREATE DATABASE`, `CREATE TABLE` e `INSERT`).
- `build_insert_from_tickets.py` — Runner Python que ejecuta el `.sql` (intenta `mysql-connector-python` y si no está disponible hace fallback al cliente `mysql`).
- `facturas/` — Carpetas con las facturas de texto usadas para generar el SQL.

Requisitos
- Python 3.8+.
- `mysql-connector-python` (recomendado). Si no está instalado, el script intentará usar el cliente `mysql` del sistema.

Instalación
Desde la carpeta del proyecto (PowerShell):

```powershell
python -m pip install -r .\requirements.txt
```

Ejecución (PowerShell)

1) Ejecutar el runner Python (recomendado):

```powershell
Este en mi casa python .\build_insert_from_tickets.py --sql .\InsertUnderlineTicket.sql --verbose

Este en clase $env:PATH = 'C:\xampp\mysql\bin;' + $env:PATH
& ".\.venv\Scripts\python.exe" .\build_insert_from_tickets.py --sql .\InsertUnderlineTicket.sql --verbose
```

- `--verbose` muestra cada sentencia SQL mientras se ejecuta y los errores asociados.
- Si no pasas `--password`, el script asume contraseña vacía (no solicitará entrada interactiva).

2) Alternativa: usar el cliente `mysql` de XAMPP directamente:

```powershell
& 'C:\xampp\mysql\bin\mysql.exe' -u root < .\InsertUnderlineTicket.sql
```

Pasar contraseña (no recomendado en línea de comando):

```powershell
python .\build_insert_from_tickets.py --sql .\InsertUnderlineTicket.sql --user root --password "tu_password"
```

Guardar salida en un fichero (log)

```powershell
python .\build_insert_from_tickets.py --sql .\InsertUnderlineTicket.sql --verbose *> build_insert_from_tickets.log
```

Qué hace el runner
- Intenta conectar con `mysql-connector-python` y ejecutar las sentencias del `.sql` una a una.
- Si falta la librería hace fallback al cliente `mysql` (si está en `PATH`).
- Separa sentencias por `;`, omite líneas que empiezan con `--` y hace `COMMIT` al final.

Resolución de problemas comunes
- "Cliente 'mysql' no encontrado en PATH": añade `C:\xampp\mysql\bin` a la variable de entorno `PATH` o usa la ruta absoluta del cliente (ver ejemplo arriba).
- "mysql-connector-python no disponible": instala dependencias con `python -m pip install -r .\requirements.txt`.
- Inserciones que fallan por FK o sintaxis: ejecuta con `--verbose` y comparte la salida; el script imprimirá el statement y el error de MySQL.

Advertencias
- El archivo `InsertUnderlineTicket.sql` puede contener `DROP DATABASE IF EXISTS`. No lo ejecutes en una base de datos de producción sin revisar primero.

Siguientes mejoras opcionales
- Leer credenciales desde un archivo `.env` o variable de entorno.
- Añadir un modo que escriba automáticamente un log con nivel de detalle (statements, errores).
- Mejorar el parser para soportar `DELIMITER` y procedimientos almacenados si aparecen en el SQL.

Contacto
Si necesitas que adapte las instrucciones a un host/usuario concreto o que añada logging automático, dime cómo quieres que lo haga y lo implemento.
