#!/usr/bin/env python3
"""
Autor: Marcos Gómez Martín.
Parsea los archivos de `facturas/` y crea una base de datos SQLite con las tablas
`invoices` e `items` (si no existen). Se puede ejecutar en modo `--dry-run` para
ver el parseo sin insertar en la base de datos.

Uso básico:
    python .\build_insert_from_tickets.py --db-file facturas.db --facturas-dir facturas --verbose
"""

from __future__ import annotations

import argparse
import glob
import os
import re
import sqlite3
from typing import Dict, List, Any
from datetime import datetime


# Normaliza cadenas numéricas (ej. "1.234,56" -> 1234.56). Devuelve float.
def norm_number(s: str) -> float:
    s = s.strip()
    s = s.replace('.', '') if s.count('.') > 1 and ',' not in s else s
    s = s.replace(',', '.')
    try:
        return float(s)
    except Exception:
        return 0.0


# Parsea el texto completo de una factura y devuelve un dict con campos:
# tienda, direccion, cif, fecha, hora, cajero, ticket, items (lista), subtotal, iva, total, forma_pago, autorizacion, raw_text
def parse_invoice(text: str) -> Dict[str, Any]:
    lines = [l.rstrip() for l in text.splitlines()]
    data: Dict[str, Any] = {}

    # Nombre tienda / direccion (primeras líneas)
    data['tienda'] = lines[0].strip() if lines else ''
    data['direccion'] = ''
    for i in range(1, min(5, len(lines))):
        if lines[i].strip():
            data['direccion'] += (lines[i].strip() + ' ')
    data['direccion'] = data['direccion'].strip()

    joined = '\n'.join(lines)

    # Extraer CIF si existe
    m = re.search(r'CIF:\s*(\S+)', joined)
    data['cif'] = m.group(1) if m else ''

    # Fecha y hora en el mismo patrón
    m = re.search(r'Fecha:\s*([0-9]{1,2}/[0-9]{1,2}/[0-9]{4})\s*Hora:\s*([0-9]{1,2}:[0-9]{2})', joined)
    if m:
        data['fecha'] = m.group(1)
        data['hora'] = m.group(2)
    else:
        data['fecha'] = ''
        data['hora'] = ''

    # Cajero, ticket y otros campos simples
    m = re.search(r'Cajero:\s*([^\n]+)', joined)
    data['cajero'] = m.group(1).strip() if m else ''

    m = re.search(r'Ticket:\s*(\S+)', joined)
    data['ticket'] = m.group(1) if m else ''

    # Buscar bloque de líneas de items: entre encabezado CANT/DESCRIP y SUBTOTAL/TOTAL
    items: List[Dict[str, Any]] = []
    start_idx = None
    for idx, line in enumerate(lines):
        if 'CANT' in line and 'DESCRIP' in line.upper() or 'DESCRIPCIÓN' in line:
            start_idx = idx + 1
            break

    end_idx = None
    for idx, line in enumerate(lines):
        if 'SUBTOTAL' in line.upper() or 'TOTAL A PAGAR' in line.upper():
            end_idx = idx
            break

    item_lines = lines[start_idx:end_idx] if start_idx is not None and end_idx is not None else []

    # Expresión regular para extraer cantidad, descripción e importe (en €)
    item_re = re.compile(r'^\s*([0-9]+(?:[.,][0-9]+)?)\s+(.+?)\s+([0-9]+(?:[.,][0-9]{2}))\s*€')
    for l in item_lines:
        lm = item_re.match(l)
        if lm:
            cantidad = norm_number(lm.group(1))
            descripcion = lm.group(2).strip()
            importe = norm_number(lm.group(3))
            items.append({'cantidad': cantidad, 'descripcion': descripcion, 'importe': importe})

    data['items'] = items

    # Subtotal, IVA, Total y forma de pago (si aparecen)
    m = re.search(r'SUBTOTAL\s+([0-9]+[.,][0-9]{2})\s*€', joined, re.IGNORECASE)
    data['subtotal'] = norm_number(m.group(1)) if m else 0.0

    m = re.search(r'IVA[^\n]*?([0-9]+[.,][0-9]{2})\s*€', joined, re.IGNORECASE)
    data['iva'] = norm_number(m.group(1)) if m else 0.0

    m = re.search(r'TOTAL A PAGAR\s+([0-9]+[.,][0-9]{2})\s*€', joined, re.IGNORECASE)
    data['total'] = norm_number(m.group(1)) if m else 0.0

    m = re.search(r'FORMA DE PAGO:\s*(.+)', joined, re.IGNORECASE)
    data['forma_pago'] = m.group(1).strip() if m else ''

    m = re.search(r'Autorizaci[oó]n:\s*(\S+)', joined)
    data['autorizacion'] = m.group(1) if m else ''

    data['raw_text'] = joined
    return data


# Asegura que las tablas SQLite básicas existen (invoices, items). Crea las tablas si faltan.
def ensure_schema(conn: sqlite3.Connection) -> None:
    cur = conn.cursor()
    cur.execute(
        '''
        CREATE TABLE IF NOT EXISTS invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tienda TEXT,
            direccion TEXT,
            cif TEXT,
            fecha TEXT,
            hora TEXT,
            cajero TEXT,
            ticket TEXT,
            subtotal REAL,
            iva REAL,
            total REAL,
            forma_pago TEXT,
            autorizacion TEXT,
            raw_text TEXT
        )
        '''
    )
    cur.execute(
        '''
        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_id INTEGER,
            cantidad REAL,
            descripcion TEXT,
            importe REAL,
            FOREIGN KEY(invoice_id) REFERENCES invoices(id)
        )
        '''
    )
    conn.commit()


# Inserta un invoice (y sus items) en la BD SQLite. Devuelve el id insertado.
def insert_invoice(conn: sqlite3.Connection, invoice: Dict[str, Any]) -> int:
    cur = conn.cursor()
    cur.execute(
        '''INSERT INTO invoices (tienda,direccion,cif,fecha,hora,cajero,ticket,subtotal,iva,total,forma_pago,autorizacion,raw_text)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)''',
        (
            invoice.get('tienda'),
            invoice.get('direccion'),
            invoice.get('cif'),
            invoice.get('fecha'),
            invoice.get('hora'),
            invoice.get('cajero'),
            invoice.get('ticket'),
            invoice.get('subtotal'),
            invoice.get('iva'),
            invoice.get('total'),
            invoice.get('forma_pago'),
            invoice.get('autorizacion'),
            invoice.get('raw_text'),
        ),
    )
    invoice_id = cur.lastrowid
    for it in invoice.get('items', []):
        cur.execute(
            'INSERT INTO items (invoice_id,cantidad,descripcion,importe) VALUES (?,?,?,?)',
            (invoice_id, it['cantidad'], it['descripcion'], it['importe']),
        )
    conn.commit()
    return invoice_id


# Punto de entrada: parsea argumentos, recorre archivos, parsea facturas y opcionalmente
# escribe un script SQL normalizado o inserta en SQLite dependiendo de flags.
def main() -> None:
    p = argparse.ArgumentParser(description='Parsear facturas y crear una base de datos SQLite')
    # Argumentos: archivo sqlite, directorio facturas, dry-run, sql-file, verbose
    p.add_argument('--db-file', default='facturas.db', help='Archivo SQLite destino')
    p.add_argument('--facturas-dir', default='facturas', help='Directorio con archivos de facturas')
    p.add_argument('--dry-run', action='store_true', help='Solo parsear y mostrar, sin insertar')
    p.add_argument('--sql-file', default=None, help='Escribir un script SQL con CREATE TABLE e INSERT (ej. InsertUnderlineTicket.sql)')
    p.add_argument('--verbose', action='store_true', help='Mostrar detalles')
    args = p.parse_args()

    # Buscar archivos que coincidan con el patrón factura_*.txt
    pattern = os.path.join(args.facturas_dir, 'factura_*.txt')
    files = sorted(glob.glob(pattern))
    if not files:
        print('No se encontraron facturas en', args.facturas_dir)
        return

    # Parsear cada archivo y acumular facturas
    invoices = []
    for f in files:
        with open(f, 'r', encoding='utf-8') as fh:
            txt = fh.read()
        inv = parse_invoice(txt)
        inv['source_file'] = os.path.basename(f)
        invoices.append(inv)
        if args.verbose:
            print('Parseado:', f, '->', len(inv.get('items', [])), 'items')

    # Si solo queremos ver un resumen, mostrar y salir
    if args.dry_run:
        print('\nResumen (dry-run):')
        for inv in invoices:
            print(f"{inv.get('source_file')}: ticket={inv.get('ticket')} fecha={inv.get('fecha')} total={inv.get('total')} items={len(inv.get('items'))}")
        return

    # Si se pide generar un script SQL (normalizado para MySQL), construir y escribirlo
    if args.sql_file:
        def sql_escape(val: Any) -> str:
            if val is None:
                return 'NULL'
            if isinstance(val, (int, float)):
                return str(val)
            s = str(val)
            s = s.replace("'", "''")
            return f"'{s}'"

        def fmt_num(n: Any) -> str:
            try:
                return f"{float(n):.2f}"
            except Exception:
                return '0.00'

        sql_path = args.sql_file
        # Abrir en modo append para insertar el script dentro del archivo destino
        # Si el archivo no existe, se creará. Añadimos un encabezado con timestamp
        with open(sql_path, 'a', encoding='utf-8') as out:
            out.write('-- ------------------------------------------------------------\n')
            out.write('-- SQL generado por build_insert_from_tickets.py (append)\n')
            out.write('-- Generado: ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '\n')
            try:
                sources = ','.join([inv.get('source_file', '') for inv in invoices])
            except Exception:
                sources = ''
            out.write('-- Facturas: ' + sources + '\n')
            out.write('-- ------------------------------------------------------------\n')
            out.write('\n')
            out.write('SET NAMES utf8mb4;\n')
            out.write('SET FOREIGN_KEY_CHECKS = 0;\n')
            out.write('\n-- Drop & recreate database `tienda` as requested\n')
            out.write('DROP DATABASE IF EXISTS `tienda`;\n')
            out.write('CREATE DATABASE `tienda` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\n')
            out.write('USE `tienda`;\n\n')
            out.write('DROP TABLE IF EXISTS `items`;\n')
            out.write('DROP TABLE IF EXISTS `invoices`;\n\n')
            # Create normalized tables requested by the user
            out.write('CREATE TABLE `sucursal` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `nombre` VARCHAR(255),\n')
            out.write('  `direccion` TEXT,\n')
            out.write('  `cif` VARCHAR(64)\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            out.write('CREATE TABLE `empleado` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `codigo` VARCHAR(64),\n')
            out.write('  `nombre` VARCHAR(255)\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            out.write('CREATE TABLE `producto` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `descripcion` TEXT\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            out.write('CREATE TABLE `ticket` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `sucursal_id` INT,\n')
            out.write('  `empleado_id` INT,\n')
            out.write('  `fecha` VARCHAR(32),\n')
            out.write('  `hora` VARCHAR(16),\n')
            out.write('  `numero` VARCHAR(128),\n')
            out.write('  `subtotal` DECIMAL(12,2),\n')
            out.write('  `iva` DECIMAL(12,2),\n')
            out.write('  `total` DECIMAL(12,2),\n')
            out.write('  `forma_pago` VARCHAR(64),\n')
            out.write('  `autorizacion` VARCHAR(64),\n')
            out.write('  FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal`(`id`),\n')
            out.write('  FOREIGN KEY (`empleado_id`) REFERENCES `empleado`(`id`)\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            out.write('CREATE TABLE `ticket_linea` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `ticket_id` INT,\n')
            out.write('  `producto_id` INT,\n')
            out.write('  `cantidad` DECIMAL(12,3),\n')
            out.write('  `precio_unitario` DECIMAL(12,4),\n')
            out.write('  `importe` DECIMAL(12,2),\n')
            out.write('  FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`),\n')
            out.write('  FOREIGN KEY (`producto_id`) REFERENCES `producto`(`id`)\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            out.write('CREATE TABLE `pago` (\n')
            out.write('  `id` INT AUTO_INCREMENT PRIMARY KEY,\n')
            out.write('  `ticket_id` INT,\n')
            out.write('  `metodo` VARCHAR(64),\n')
            out.write('  `autorizacion` VARCHAR(64),\n')
            out.write('  `importe` DECIMAL(12,2),\n')
            out.write('  FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`)\n')
            out.write(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n')

            # Build lookup tables and insert data
            sucursal_map = {}
            empleado_map = {}
            producto_map = {}
            next_sucursal_id = 1
            next_empleado_id = 1
            next_producto_id = 1
            next_ticket_id = 1

            for inv in invoices:
                # Sucursal: key by (nombre,direccion,cif)
                s_key = (inv.get('tienda') or '', inv.get('direccion') or '', inv.get('cif') or '')
                if s_key not in sucursal_map:
                    sid = next_sucursal_id
                    next_sucursal_id += 1
                    sucursal_map[s_key] = sid
                    out.write('INSERT INTO `sucursal` (`id`,`nombre`,`direccion`,`cif`) VALUES (' + ','.join([str(sid), sql_escape(s_key[0]), sql_escape(s_key[1]), sql_escape(s_key[2])]) + ');\n')

                # Empleado: try split code - name if possible
                cajero = inv.get('cajero') or ''
                emp_code = ''
                emp_name = cajero
                if '-' in cajero:
                    parts = [p.strip() for p in cajero.split('-', 1)]
                    if len(parts) == 2:
                        emp_code, emp_name = parts[0], parts[1]
                e_key = (emp_code, emp_name)
                if e_key not in empleado_map:
                    eid = next_empleado_id
                    next_empleado_id += 1
                    empleado_map[e_key] = eid
                    out.write('INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (' + ','.join([str(eid), sql_escape(emp_code), sql_escape(emp_name)]) + ');\n')

                # Ticket
                tid = next_ticket_id
                next_ticket_id += 1
                sid = sucursal_map[s_key]
                eid = empleado_map[e_key]
                ticket_vals = [
                    str(tid),
                    str(sid),
                    str(eid),
                    sql_escape(inv.get('fecha')),
                    sql_escape(inv.get('hora')),
                    sql_escape(inv.get('ticket')),
                    fmt_num(inv.get('subtotal')),
                    fmt_num(inv.get('iva')),
                    fmt_num(inv.get('total')),
                    sql_escape(inv.get('forma_pago')),
                    sql_escape(inv.get('autorizacion')),
                ]
                out.write('INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (' + ','.join(ticket_vals) + ');\n')

                # Lineas e insertar productos si no existen
                for it in inv.get('items', []):
                    desc = (it.get('descripcion') or '').strip()
                    if desc not in producto_map:
                        pid = next_producto_id
                        next_producto_id += 1
                        producto_map[desc] = pid
                        out.write('INSERT INTO `producto` (`id`,`descripcion`) VALUES (' + str(pid) + ',' + sql_escape(desc) + ');\n')
                    else:
                        pid = producto_map[desc]

                    cantidad = float(it.get('cantidad') or 0)
                    importe = float(it.get('importe') or 0)
                    precio_unit = importe / cantidad if cantidad and cantidad != 0 else importe
                    linea_vals = [
                        str(tid),
                        str(pid),
                        fmt_num(cantidad),
                        f"{precio_unit:.4f}",
                        fmt_num(importe),
                    ]
                    out.write('INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (' + ','.join(linea_vals) + ');\n')

                # Pago
                out.write('INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (' + ','.join([str(tid), sql_escape(inv.get('forma_pago')), sql_escape(inv.get('autorizacion')), fmt_num(inv.get('total'))]) + ');\n')
                out.write('\n')

            out.write('SET FOREIGN_KEY_CHECKS = 1;\n')

        print('Script SQL escrito en', sql_path)
        return

    # Conectar a SQLite, asegurar esquema e insertar facturas parseadas
    conn = sqlite3.connect(args.db_file)
    ensure_schema(conn)
    for inv in invoices:
        iid = insert_invoice(conn, inv)
        if args.verbose:
            print('Insertado invoice id=', iid, 'from', inv.get('source_file'))

    print('Insertadas', len(invoices), 'facturas en', args.db_file)


if __name__ == '__main__':
    main()

