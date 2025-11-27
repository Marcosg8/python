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

# Programa: Parseo de tickets (facturas) y persistencia

Este repositorio contiene utilidades para extraer los datos de tickets (facturas) en
texto plano desde la carpeta `facturas/` y guardarlos en una base de datos.

Se incluyen dos modos de trabajo principales:
- Parser local que crea una base de datos SQLite (`facturas.db`) con las tablas `invoices` e `items`.
- (Opcional) Runner/SQL para ejecutar un script `.sql` contra un servidor MySQL (si dispone de dicho script).

Contenido
- `build_insert_from_tickets.py`: script Python que actualmente parsea las facturas en `facturas/` y puede crear/llenar una base SQLite. Soporta `--dry-run` y `--verbose`.
- `facturas/`: ejemplos de tickets en texto (`factura_001.txt`, ...).
- `InsertUnderlineTicket.sql`: (opcional) script SQL si desea ejecutar sentencias contra MySQL. Puede estar vacío o contener el SQL que ya tenga preparado.

Requisitos
- Python 3.8+ (probado con 3.11).
- (Opcional) Para MySQL: `mysql-connector-python` o el cliente `mysql` disponible en `PATH`.

Instalación rápida
1. Crear un entorno virtual (recomendado) y activar (PowerShell):

```powershell
python -m venv .venv
& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r .\requirements.txt  # si existe
```

Uso — Parser SQLite (recomendado para pruebas locales)

```powershell
# Parsear todas las facturas y crear/actualizar facturas.db
python .\build_insert_from_tickets.py --db-file facturas.db --facturas-dir facturas --verbose

# Solo parsear y mostrar resumen (sin insertar)
python .\build_insert_from_tickets.py --facturas-dir facturas --dry-run --verbose
```

Qué crea el parser
- `facturas.db` (SQLite) con dos tablas:
	- `invoices` (id, tienda, direccion, cif, fecha, hora, cajero, ticket, subtotal, iva, total, forma_pago, autorizacion, raw_text)
	- `items` (id, invoice_id, cantidad, descripcion, importe)

Mapping de campos extraídos (ejemplo)
- `ticket` → `invoices.ticket`
- `fecha`/`hora` → `invoices.fecha`, `invoices.hora`
- `subtotal`, `iva`, `total` → columnas numéricas en `invoices`
- Cada línea de producto se inserta en `items` vinculada por `invoice_id`.

Formato esperado de los tickets
El parser está diseñado para tickets tipo supermercado con bloques similares a los ejemplos
en `facturas/`. Busca líneas con `CANT` / `DESCRIPCIÓN` y extrae cantidad, descripción e importe
por item, y las secciones `SUBTOTAL`, `IVA` y `TOTAL A PAGAR` para los totales.

Adaptación a otros formatos
- Si tus facturas cambian de estructura (por ejemplo columnas alineadas distinto, símbolos diferentes o moneda sin `€`), puedo:
	- Ajustar las expresiones regulares en `parse_invoice()` en `build_insert_from_tickets.py`.
	- Añadir detectores por plantilla (ej. plantilla A, plantilla B) y seleccionar parser automáticamente.

Uso — Ejecutar SQL contra MySQL (opcional)

Si tiene un archivo `.sql` que crea tablas e inserta datos, puede ejecutarlo con el cliente MySQL o con un runner Python (si se implementa):

```powershell
# Usando cliente mysql de XAMPP (ejemplo):
& 'C:\xampp\mysql\bin\mysql.exe' -u root < .\InsertUnderlineTicket.sql

# Si prefiere usar un runner Python que use mysql-connector, indíqueme
# las credenciales y lo preparo para usted.
```

Consejos y buenas prácticas
- Haga siempre un `--dry-run` primero para validar que el parseo detecta correctamente los items.
- Mantenga backups de su base de datos antes de ejecutar inserts masivos.

Problemas comunes
- Si no se detectan items, abra un ejemplo en `facturas/` y verifique la alineación de columnas; puedo adaptar el regex.
- Si obtienes errores de codificación al leer los `.txt`, confirma que los archivos están en `utf-8`.

Próximos pasos (puedo implementarlos si lo desea)
- Soporte directo para MySQL: adaptar `build_insert_from_tickets.py` para insertar en MySQL con `mysql-connector-python`.
- Exportar CSV de items y facturas para análisis externo.
- Agregar tests unitarios para el parser con varios ejemplos de tickets.

Contacto / ayuda
Si quieres que adapte el README (por ejemplo, añadir instrucciones específicas de tu servidor MySQL, user/password, o que haga el script compatible con tu esquema de base de datos existente), dime las columnas y tablas exactas y lo adapto.
