import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

load_dotenv()

print("=" * 60)
print("PASO 1: Intentando conectar sin especificar BD")
print("=" * 60)

try:
    connection = mysql.connector.connect(
        host=os.getenv('DB_HOST'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        port=int(os.getenv('DB_PORT', 3306))
    )
    
    if connection.is_connected():
        print("✅ Conexión exitosa!")
        
        cursor = connection.cursor()
        
        # Crear base de datos si no existe
        print("\n" + "=" * 60)
        print("PASO 2: Creando base de datos...")
        print("=" * 60)
        
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {os.getenv('DB_NAME')}")
        print(f"✅ Base de datos '{os.getenv('DB_NAME')}' lista")
        
        # Usar la base de datos
        cursor.execute(f"USE {os.getenv('DB_NAME')}")
        
        # Crear tabla si no existe
        print("\n" + "=" * 60)
        print("PASO 3: Creando tabla empleado...")
        print("=" * 60)
        
        create_table = """
        CREATE TABLE IF NOT EXISTS empleado (
            Nombre VARCHAR(100) NOT NULL,
            `1Apellido` VARCHAR(100),
            `2Apellido` VARCHAR(100),
            Departamento VARCHAR(100),
            Tipo_de_Jornada VARCHAR(50),
            Horas INT,
            Hora_de_fichar INT,
            Sueldo INT,
            PRIMARY KEY (Nombre)
        );
        """
        
        cursor.execute(create_table)
        print("✅ Tabla 'empleado' lista")
        
        # Ver empleados existentes
        print("\n" + "=" * 60)
        print("PASO 4: Verificando empleados existentes...")
        print("=" * 60)
        
        cursor.execute("SELECT * FROM empleado")
        empleados = cursor.fetchall()
        
        print(f"Total de empleados: {len(empleados)}")
        
        if len(empleados) > 0:
            print("\nEmpleados registrados:")
            # Obtener nombres de columnas
            columns = [desc[0] for desc in cursor.description]
            for emp in empleados:
                print(f"  - {dict(zip(columns, emp))}")
        else:
            print("No hay empleados registrados")
        
        cursor.close()
        connection.close()
        
        print("\n✅ TODO ESTÁ LISTO PARA USAR")
        
except Error as e:
    print(f"❌ Error: {e}")
    print(f"Tipo: {type(e).__name__}")
except Exception as e:
    print(f"❌ Error inesperado: {e}")
    print(f"Tipo: {type(e).__name__}")
