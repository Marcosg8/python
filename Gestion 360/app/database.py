import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    """Crear conexión con la base de datos MySQL"""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME'),
            port=int(os.getenv('DB_PORT', 3306))
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error de conexión: {e}")
        return None

def get_empleados():
    """Obtener todos los empleados"""
    connection = get_connection()
    if not connection:
        return []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM empleado")
        empleados = cursor.fetchall()
        return empleados
    except Error as e:
        print(f"Error al obtener empleados: {e}")
        return []
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def agregar_empleado(nombre, primer_apellido, segundo_apellido, departamento, tipo_jornada, horas, hora_fichar, sueldo):
    """Agregar un nuevo empleado"""
    connection = get_connection()
    if not connection:
        return False
    
    try:
        cursor = connection.cursor()
        query = """INSERT INTO empleado (Nombre, PrimerApellido, SegundoApellido, Departamento, Tipo_de_Jornada, Horas, Hora_de_fichar, Sueldo)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
        cursor.execute(query, (nombre, primer_apellido, segundo_apellido, departamento, tipo_jornada, horas, hora_fichar, sueldo))
        connection.commit()
        return True
    except Error as e:
        print(f"Error al agregar empleado: {e}")
        return False
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def eliminar_empleado(nombre):
    """Eliminar un empleado por nombre"""
    connection = get_connection()
    if not connection:
        return False
    
    try:
        cursor = connection.cursor()
        query = "DELETE FROM empleado WHERE Nombre = %s"
        cursor.execute(query, (nombre,))
        connection.commit()
        return cursor.rowcount > 0
    except Error as e:
        print(f"Error al eliminar empleado: {e}")
        return False
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def actualizar_empleado(nombre, primer_apellido, segundo_apellido, departamento, tipo_jornada, horas, hora_fichar, sueldo):
    """Actualizar datos de un empleado"""
    connection = get_connection()
    if not connection:
        return False
    
    try:
        cursor = connection.cursor()
        query = """UPDATE empleado SET PrimerApellido=%s, SegundoApellido=%s, Departamento=%s, 
                   Tipo_de_Jornada=%s, Horas=%s, Hora_de_fichar=%s, Sueldo=%s WHERE Nombre=%s"""
        cursor.execute(query, (primer_apellido, segundo_apellido, departamento, tipo_jornada, horas, hora_fichar, sueldo, nombre))
        connection.commit()
        return cursor.rowcount > 0
    except Error as e:
        print(f"Error al actualizar empleado: {e}")
        return False
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
