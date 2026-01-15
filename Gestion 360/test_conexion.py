import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

print("Intentando conectar a MySQL...")
print(f"Host: {os.getenv('DB_HOST')}")
print(f"Usuario: {os.getenv('DB_USER')}")
print(f"Base de datos: {os.getenv('DB_NAME')}")
print(f"Puerto: {os.getenv('DB_PORT')}")

try:
    connection = mysql.connector.connect(
        host=os.getenv('DB_HOST'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        database=os.getenv('DB_NAME'),
        port=int(os.getenv('DB_PORT', 3306))
    )
    
    if connection.is_connected():
        print("\n✅ Conexión exitosa!")
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM empleado")
        empleados = cursor.fetchall()
        
        print(f"\n📊 Total de empleados: {len(empleados)}")
        print("\nEmpleados en la base de datos:")
        for emp in empleados:
            print(f"  - {emp}")
        
        cursor.close()
        connection.close()
    else:
        print("❌ No se pudo conectar")
        
except Exception as e:
    print(f"❌ Error: {e}")
    print(f"Tipo de error: {type(e).__name__}")
