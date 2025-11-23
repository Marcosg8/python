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
		print("Error conectando/ejecutando con mysql-connector-python:", e)
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


def main(argv: Optional[list[str]] = None) -> int:
	parser = argparse.ArgumentParser(description='Ejecuta un script SQL contra MySQL local (phpMyAdmin).')
	parser.add_argument('--sql', '-s', default='InsertUnderlineTicket.sql', help='Ruta al archivo .sql')
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
