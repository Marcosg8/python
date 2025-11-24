#!/usr/bin/env python3
"""
Ejecuta un script SQL (por ejemplo `InsertUnderlineTicket.sql`) contra un servidor MySQL local
que habitualmente administra phpMyAdmin. El script se ejecuta tal cual (multi-statements).

Uso recomendado:
  python build_insert_from_tickets.py --sql "InsertUnderlineTicket.sql"

El script pedirá credenciales (usuario/host/puerto/contraseña). Por seguridad, la contraseña
se solicita interactivamente y no se almacena.

Si no está instalado `mysql-connector-python`, el script intentará usar el cliente `mysql` vía
subprocess (requiere que `mysql` esté en PATH).
"""
from __future__ import annotations

import argparse
import getpass
import os
import shutil
import subprocess
import sys
from typing import Optional
import glob
import re
import hashlib
from datetime import datetime


def run_with_mysql_connector(host: str, port: int, user: str, password: str, sql_path: str, verbose: bool = False) -> int:
	try:
		import mysql.connector
	except Exception:
		print("mysql-connector-python no disponible.")
		return 2

	with open(sql_path, 'r', encoding='utf-8') as f:
		sql = f.read()

	try:
		conn = mysql.connector.connect(host=host, port=port, user=user, password=password)
		cursor = conn.cursor()
		# Ejecutar statements uno a uno para compatibilidad con distintas versiones
		# Nota: esto asume que no hay delimitadores complejos en el SQL (procedimientos almacenados, etc.)
		# También soporta comentarios -- y líneas en blanco.
		raw_statements = sql.split(';')
		statements = []
		for s in raw_statements:
			# eliminar líneas de comentario al inicio de cada fragmento
			lines = [L for L in (l.rstrip() for l in s.splitlines()) if not L.strip().startswith('--')]
			stmt = '\n'.join(lines).strip()
			if stmt:
				statements.append(stmt)

		success = 0
		failures = 0
		for idx, stmt in enumerate(statements, start=1):
			try:
				if verbose:
					head = stmt.replace('\n', ' ')[:200]
					print(f"[{idx}/{len(statements)}] Ejecutando: {head}...")
				cursor.execute(stmt)
				success += 1
			except Exception as e_stmt:
				failures += 1
				print(f"Error ejecutando statement #{idx}: {e_stmt}\nStatement: {stmt[:400]}\n---")
				# continuar con el siguiente statement (no abortar automáticamente)

		try:
			conn.commit()
		except Exception as e_commit:
			print("Error al hacer commit:", e_commit)
			cursor.close()
			conn.close()
			return 3

		cursor.close()
		conn.close()
		print(f"Ejecución finalizada. Statements ejecutados: {success}, fallos: {failures}.")
		return 0 if failures == 0 else 6
	except Exception as e:
		import traceback
		print("Error conectando/ejecutando con mysql-connector-python:")
		traceback.print_exc()
		return 3


def run_with_mysql_cli(host: str, port: int, user: str, password: str, sql_path: str, verbose: bool = False) -> int:
	mysql_cmd = shutil.which('mysql')
	if not mysql_cmd:
		print("Cliente 'mysql' no encontrado en PATH.")
		return 4

	cmd = [
		mysql_cmd,
		'-h', host,
		'-P', str(port),
		'-u', user,
	]
	if password:
		cmd.append(f'-p{password}')
	if verbose:
		print('Ejecutando mysql CLI con comando:', ' '.join(cmd))
	try:
		with open(sql_path, 'rb') as f:
			p = subprocess.run(cmd, stdin=f)
	except FileNotFoundError:
		print("Cliente 'mysql' no encontrado en PATH. Instalalo o usa el conector Python.")
		return 4

	if p.returncode == 0:
		print("Ejecución completada con cliente mysql.")
	else:
		print(f"El cliente mysql devolvió código {p.returncode}.")
	return p.returncode


def _sql_escape(s: str) -> str:
	if s is None:
		return 'NULL'
	return "'" + s.replace("'", "\\'") + "'"


def build_sql_from_facturas(facturas_dir: str, sql_path: str) -> None:
	"""Lee todos los *.txt en `facturas_dir` y genera bloques INSERT SQL
	que se anexan al archivo `sql_path`.
	"""
	files = sorted(glob.glob(os.path.join(facturas_dir, '*.txt')))
	if not files:
		raise FileNotFoundError('No se encontraron archivos .txt en ' + facturas_dir)

	# Leer contenido base (schema) y preparar append
	with open(sql_path, 'r', encoding='utf-8') as f:
		base_sql = f.read()

	out_lines = [base_sql.rstrip(), '\n-- INSERTS GENERADOS DESDE facturas/\n']

	for fpath in files:
		text = open(fpath, 'r', encoding='utf-8').read()
		# Normalizar saltos y trabajar línea a línea
		lines = [L.rstrip() for L in text.splitlines()]

		# Nombre de la sucursal: primera línea no vacía
		nombre = next((L.strip() for L in lines if L.strip()), '')
		direccion = ''
		cif = ''
		telefono = ''
		# intentar extraer dirección/cif/tel desde primeras 6 líneas
		head = '\n'.join(lines[:6])
		m = re.search(r'CIF[:\s]+([A-Za-z0-9-]+)', head)
		if m:
			cif = m.group(1).strip()
		m = re.search(r'Tel[:eño]*[:\s]+([0-9 \-()+]+)', head)
		if m:
			telefono = m.group(1).strip()
		# dirección como segunda línea si existe
		nonempty = [L for L in lines if L.strip()]
		if len(nonempty) >= 2:
			direccion = nonempty[1].strip()

		# Fecha/Hora
		fecha = None
		hora = None
		m = re.search(r'Fecha[:\s]+(\d{1,2}/\d{1,2}/\d{4})\s+Hora[:\s]+(\d{1,2}:\d{2})', text)
		if m:
			try:
				dt = datetime.strptime(m.group(1) + ' ' + m.group(2), '%d/%m/%Y %H:%M')
				fecha = dt.strftime('%Y-%m-%d')
				hora = dt.strftime('%H:%M:%S')
			except Exception:
				fecha = None
				hora = None

		# Cajero
		cajero_codigo = ''
		cajero_nombre = ''
		m = re.search(r'Cajero[:\s]+([^\n\r]+)', text)
		if m:
			caj_text = m.group(1).strip()
			if ' - ' in caj_text:
				parts = [p.strip() for p in caj_text.split(' - ', 1)]
				cajero_codigo = parts[0]
				cajero_nombre = parts[1] if len(parts) > 1 else ''
			else:
				cajero_nombre = caj_text

		# Ticket
		ticket_num = ''
		m = re.search(r'Ticket[:\s]+(\S+)', text)
		if m:
			ticket_num = m.group(1).strip()

		# Forma de pago y autorización
		forma_pago = ''
		m = re.search(r'FORMA DE PAGO[:\s]+([^\n\r]+)', text)
		if m:
			forma_pago = m.group(1).strip()
		autorizacion = ''
		m = re.search(r'Autorizaci[oó]n[:\s]+(\S+)', text)
		if m:
			autorizacion = m.group(1).strip()

		# Totales
		subtotal = ''
		iva = ''
		total = ''
		m = re.search(r'SUBTOTAL\s+([0-9,.]+)\s*€', text)
		if m:
			subtotal = m.group(1).replace(',', '.')
		m = re.search(r'IVA.*?([0-9,.]+)\s*€', text)
		if m:
			iva = m.group(1).replace(',', '.')
		m = re.search(r'TOTAL A PAGAR\s+([0-9,.]+)\s*€', text)
		if m:
			total = m.group(1).replace(',', '.')

		# Líneas de items: buscar bloque entre encabezado 'CANT' y 'SUBTOTAL' o la línea de ----
		items = []
		start = None
		for idx, L in enumerate(lines):
			if 'CANT' in L and 'DESCRIPCI' in L:
				start = idx + 1
				break
		end = None
		for idx in range(start or 0, len(lines)):
			L = lines[idx]
			if L.strip().upper().startswith('SUBTOTAL') or L.strip().startswith('---'):
				end = idx
				break
		if start is not None:
			block = lines[start:(end or len(lines))]
			for L in block:
				# Buscar patrón: cantidad [espacios] descripcion [espacios] importe €
				m = re.match(r"^\s*([0-9]+(?:[.,][0-9]+)?)\s+(.+?)\s+([0-9]+(?:[.,][0-9]+)?)\s*€", L)
				if not m:
					continue
				q = m.group(1).replace(',', '.')
				desc = m.group(2).strip()
				imp = m.group(3).replace(',', '.')
				try:
					cantidad = float(q)
					importe = float(imp)
				except Exception:
					continue
				unidad = None
				# intentar obtener unidad desde paréntesis en la descripción
				um = re.search(r"\(([^)]+)\)", desc)
				if um:
					unidad = um.group(1).strip()
				precio_unitario = None
				if cantidad != 0:
					precio_unitario = round(importe / cantidad, 4)
				items.append({'descripcion': desc, 'cantidad': cantidad, 'unidad': unidad or '', 'precio_unitario': precio_unitario, 'importe': importe})

		# Generar bloque SQL para esta factura
		out_lines.append('\n-- Factura: %s (%s)\n' % (os.path.basename(fpath), ticket_num))

		# Sucursal
		out_lines.append("INSERT INTO `sucursal` (`nombre`,`direccion`,`cif`,`telefono`) SELECT %s,%s,%s,%s FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sucursal` WHERE `nombre`=%s AND `cif`=%s);" % (
			_sql_escape(nombre), _sql_escape(direccion), _sql_escape(cif), _sql_escape(telefono), _sql_escape(nombre), _sql_escape(cif)
		))
		out_lines.append("SET @sucursal_id = (SELECT id FROM `sucursal` WHERE `nombre`=%s AND `cif`=%s LIMIT 1);" % (_sql_escape(nombre), _sql_escape(cif)))

		# Empleado
		out_lines.append("INSERT INTO `empleado` (`codigo`,`nombre`,`sucursal_id`) SELECT %s,%s,@sucursal_id FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `empleado` WHERE `codigo`=%s AND `nombre`=%s AND `sucursal_id`=@sucursal_id);" % (
			_sql_escape(cajero_codigo), _sql_escape(cajero_nombre), _sql_escape(cajero_codigo), _sql_escape(cajero_nombre)
		))
		out_lines.append("SET @empleado_id = (SELECT id FROM `empleado` WHERE `codigo`=%s AND `sucursal_id`=@sucursal_id LIMIT 1);" % (_sql_escape(cajero_codigo)))

		# Ticket
		out_lines.append("INSERT IGNORE INTO `ticket` (`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (%s,%s,%s,@sucursal_id,@empleado_id,%s,%s,%s,%s,%s);" % (
			_sql_escape(ticket_num), _sql_escape(fecha), _sql_escape(hora), _sql_escape(subtotal or None), _sql_escape(iva or None), _sql_escape(total or None), _sql_escape(forma_pago), _sql_escape(autorizacion)
		))
		out_lines.append("SET @ticket_id = (SELECT id FROM `ticket` WHERE `ticket_num`=%s LIMIT 1);" % (_sql_escape(ticket_num)))

		# Líneas y productos
		for idx, it in enumerate(items, start=1):
			desc = it['descripcion']
			sku = 'auto_' + hashlib.sha1(desc.encode('utf-8')).hexdigest()[:10]
			unidad = it['unidad'] or ''
			pu = it['precio_unitario'] if it['precio_unitario'] is not None else None
			imp = it['importe']
			# Insert product (si no existe)
			out_lines.append("INSERT IGNORE INTO `producto` (`sku`,`nombre`,`unidad`,`precio_unitario`) VALUES (%s,%s,%s,%s);" % (
				_sql_escape(sku), _sql_escape(desc[:255]), _sql_escape(unidad), _sql_escape(str(pu) if pu is not None else None)
			))
			out_lines.append("SET @producto_id = (SELECT id FROM `producto` WHERE `sku`=%s LIMIT 1);" % (_sql_escape(sku)))
			out_lines.append("INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES (@ticket_id,@producto_id,%s,%s,%s,%s,%s,%d);" % (
				_sql_escape(desc[:255]), _sql_escape(str(it['cantidad'])), _sql_escape(unidad), _sql_escape(str(pu) if pu is not None else None), _sql_escape(str(imp)), idx
			))

		# Pago
		if forma_pago or autorizacion or total:
			out_lines.append("INSERT INTO `pago` (`ticket_id`,`forma_pago`,`importe`,`autorizacion`) VALUES (@ticket_id,%s,%s,%s);" % (
				_sql_escape(forma_pago), _sql_escape(total or None), _sql_escape(autorizacion)
			))

	# Escribir todo de vuelta al archivo SQL (sobrescribiendo)
	with open(sql_path, 'w', encoding='utf-8') as f:
		f.write('\n'.join(out_lines))


def main(argv: Optional[list[str]] = None) -> int:
	parser = argparse.ArgumentParser(description='Ejecuta un script SQL contra MySQL local (phpMyAdmin).')
	parser.add_argument('--sql', '-s', default='InsertUnderlineTicket.sql', help='Ruta al archivo .sql')
	parser.add_argument('--build-from-facturas', '-b', action='store_true', help='Generar INSERTs a partir de los archivos en la carpeta `facturas/` y añadirlos al .sql')
	parser.add_argument('--host', default='localhost', help='Host de MySQL (por defecto localhost)')
	parser.add_argument('--port', default=3306, type=int, help='Puerto de MySQL (por defecto 3306)')
	parser.add_argument('--user', '-u', default='root', help='Usuario MySQL (por defecto root)')
	parser.add_argument('--password', '-p', help='Contraseña MySQL (si no se provee, se asumirá vacía y NO se pedirá)')
	parser.add_argument('--verbose', '-v', action='store_true', help='Mostrar cada statement mientras se ejecuta')
	args = parser.parse_args(argv)

	sql_path = os.path.abspath(args.sql)
	if not os.path.exists(sql_path):
		print(f"Archivo SQL no encontrado: {sql_path}")
		return 1

	# Si se solicita generar SQL desde las facturas, hacerlo y salir
	if args.build_from_facturas:
		facturas_dir = os.path.join(os.path.dirname(sql_path), 'facturas')
		if not os.path.isdir(facturas_dir):
			facturas_dir = os.path.join(os.getcwd(), 'facturas')
		if not os.path.isdir(facturas_dir):
			print(f"No se encontró la carpeta 'facturas' en '{facturas_dir}'")
			return 1
		try:
			build_sql_from_facturas(facturas_dir, sql_path)
			print(f"Generado SQL con INSERTs a partir de facturas en: {sql_path}")
			return 0
		except Exception as e:
			print("Error generando SQL desde facturas:", e)
			return 2

	# Si no se proporciona --password asumimos contraseña vacía (no pedir)
	password = args.password or ''

	# Intentar con mysql-connector-python primero
	rc = run_with_mysql_connector(args.host, args.port, args.user, password, sql_path, verbose=args.verbose)
	if rc == 0:
		return 0

	print("Intentando fallback con cliente 'mysql' del sistema...")
	rc = run_with_mysql_cli(args.host, args.port, args.user, password, sql_path, verbose=args.verbose)
	return rc


if __name__ == '__main__':
	raise SystemExit(main())
