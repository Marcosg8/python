from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List, Optional
from app.database import get_empleados, agregar_empleado, eliminar_empleado, actualizar_empleado
import os

app = FastAPI(title="Gestor de Empleados")

# Servir archivos estáticos
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Modelos
class EmpleadoData(BaseModel):
    Nombre: str
    primer_apellido: str
    segundo_apellido: str
    Departamento: str
    Tipo_de_Jornada: str
    Horas: int
    Hora_de_fichar: int
    Sueldo: int

class EmpleadoActualizar(BaseModel):
    primer_apellido: str
    segundo_apellido: str
    Departamento: str
    Tipo_de_Jornada: str
    Horas: int
    Hora_de_fichar: int
    Sueldo: int

# Rutas
@app.get("/")
async def root():
    """Servir la página principal"""
    return FileResponse("app/template/pages/index.html")

@app.get("/api/empleados", response_model=List[dict])
async def listar_empleados():
    """Obtener lista de todos los empleados"""
    empleados = get_empleados()
    if empleados is None:
        raise HTTPException(status_code=500, detail="Error al conectar con la base de datos")
    return empleados

@app.post("/api/empleados")
async def crear_empleado(empleado: EmpleadoData):
    """Crear un nuevo empleado"""
    try:
        success = agregar_empleado(
            nombre=empleado.Nombre,
            primer_apellido=empleado.primer_apellido,
            segundo_apellido=empleado.segundo_apellido,
            departamento=empleado.Departamento,
            tipo_jornada=empleado.Tipo_de_Jornada,
            horas=empleado.Horas,
            hora_fichar=empleado.Hora_de_fichar,
            sueldo=empleado.Sueldo
        )
        if not success:
            raise HTTPException(status_code=400, detail="Error al agregar empleado - verifica que el nombre sea único")
        return {"mensaje": "Empleado agregado exitosamente"}
    except Exception as e:
        print(f"Error en crear_empleado: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Error: {str(e)}")

@app.delete("/api/empleados/{nombre}")
async def borrar_empleado(nombre: str):
    """Eliminar un empleado por nombre"""
    success = eliminar_empleado(nombre)
    if not success:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    return {"mensaje": "Empleado eliminado exitosamente"}

@app.put("/api/empleados/{nombre}")
async def editar_empleado(nombre: str, empleado: EmpleadoActualizar):
    """Actualizar datos de un empleado"""
    success = actualizar_empleado(
        nombre=nombre,
        primer_apellido=empleado.primer_apellido,
        segundo_apellido=empleado.segundo_apellido,
        departamento=empleado.Departamento,
        tipo_jornada=empleado.Tipo_de_Jornada,
        horas=empleado.Horas,
        hora_fichar=empleado.Hora_de_fichar,
        sueldo=empleado.Sueldo
    )
    if not success:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    return {"mensaje": "Empleado actualizado exitosamente"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
