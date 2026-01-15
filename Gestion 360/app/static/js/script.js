// Variables globales
const formAgregar = document.getElementById('formAgregar');
const formEditar = document.getElementById('formEditar');
const tablaEmpleados = document.getElementById('cuerpoTabla');
const modal = document.getElementById('modalEditar');
const closeBtn = document.querySelector('.close');
const mensajeEstado = document.getElementById('mensajeEstado');

// Cargar empleados al iniciar
document.addEventListener('DOMContentLoaded', () => {
    cargarEmpleados();
    configurarEventos();
});

// Configurar eventos
function configurarEventos() {
    formAgregar.addEventListener('submit', agregarEmpleado);
    formEditar.addEventListener('submit', guardarCambios);
    closeBtn.addEventListener('click', cerrarModal);
    window.addEventListener('click', (e) => {
        if (e.target === modal) {
            cerrarModal();
        }
    });
}

// Cargar lista de empleados
async function cargarEmpleados() {
    try {
        const response = await fetch('/api/empleados');
        if (!response.ok) throw new Error('Error al cargar empleados');
        
        const empleados = await response.json();
        mostrarEmpleados(empleados);
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error al cargar empleados', 'error');
    }
}

// Mostrar empleados en la tabla
function mostrarEmpleados(empleados) {
    tablaEmpleados.innerHTML = '';
    
    if (empleados.length === 0) {
        tablaEmpleados.innerHTML = '<tr><td colspan="9" style="text-align: center;">No hay empleados registrados</td></tr>';
        return;
    }
    
    empleados.forEach(empleado => {
        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td>${empleado.Nombre}</td>
            <td>${empleado.PrimerApellido}</td>
            <td>${empleado.SegundoApellido}</td>
            <td>${empleado.Departamento}</td>
            <td>${empleado.Tipo_de_Jornada}</td>
            <td>${empleado.Horas}</td>
            <td>${empleado.Hora_de_fichar}</td>
            <td>${empleado.Sueldo}</td>
            <td>
                <button class="btn btn-edit" onclick="abrirModalEditar('${empleado.Nombre}', '${empleado.PrimerApellido}', '${empleado.SegundoApellido}', '${empleado.Departamento}', '${empleado.Tipo_de_Jornada}', ${empleado.Horas}, ${empleado.Hora_de_fichar}, ${empleado.Sueldo})">Editar</button>
                <button class="btn btn-danger" onclick="eliminarEmpleado('${empleado.Nombre}')">Eliminar</button>
            </td>
        `;
        tablaEmpleados.appendChild(fila);
    });
}

// Agregar nuevo empleado
async function agregarEmpleado(e) {
    e.preventDefault();
    
    const nuevoEmpleado = {
        Nombre: document.getElementById('nombre').value,
        primer_apellido: document.getElementById('apellido1').value,
        segundo_apellido: document.getElementById('apellido2').value,
        Departamento: document.getElementById('departamento').value,
        Tipo_de_Jornada: document.getElementById('tipoJornada').value,
        Horas: parseInt(document.getElementById('horas').value),
        Hora_de_fichar: parseInt(document.getElementById('horaFichar').value),
        Sueldo: parseInt(document.getElementById('sueldo').value)
    };
    
    console.log('Enviando:', nuevoEmpleado);
    
    try {
        const response = await fetch('/api/empleados', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(nuevoEmpleado)
        });
        
        console.log('Response status:', response.status);
        const data = await response.json();
        console.log('Response data:', data);
        
        if (!response.ok) {
            throw new Error(data.detail || 'Error al agregar empleado');
        }
        
        mostrarMensaje('Empleado agregado exitosamente', 'exito');
        formAgregar.reset();
        cargarEmpleados();
    } catch (error) {
        console.error('Error completo:', error);
        mostrarMensaje(error.message, 'error');
    }
}

// Eliminar empleado
async function eliminarEmpleado(nombre) {
    if (!confirm(`¿Está seguro de que desea eliminar a ${nombre}?`)) {
        return;
    }
    
    try {
        const response = await fetch(`/api/empleados/${nombre}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || 'Error al eliminar empleado');
        }
        
        mostrarMensaje('Empleado eliminado exitosamente', 'exito');
        cargarEmpleados();
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje(error.message, 'error');
    }
}

// Abrir modal para editar
function abrirModalEditar(nombre, apellido1, apellido2, departamento, tipoJornada, horas, horaFichar, sueldo) {
    document.getElementById('editarNombre').value = nombre;
    document.getElementById('editarApellido1').value = apellido1;
    document.getElementById('editarApellido2').value = apellido2;
    document.getElementById('editarDepartamento').value = departamento;
    document.getElementById('editarTipoJornada').value = tipoJornada;
    document.getElementById('editarHoras').value = horas;
    document.getElementById('editarHoraFichar').value = horaFichar;
    document.getElementById('editarSueldo').value = sueldo;
    modal.style.display = 'block';
}

// Cerrar modal
function cerrarModal() {
    modal.style.display = 'none';
}

// Guardar cambios
async function guardarCambios(e) {
    e.preventDefault();
    
    const nombre = document.getElementById('editarNombre').value;
    const datosActualizados = {
        primer_apellido: document.getElementById('editarApellido1').value,
        segundo_apellido: document.getElementById('editarApellido2').value,
        Departamento: document.getElementById('editarDepartamento').value,
        Tipo_de_Jornada: document.getElementById('editarTipoJornada').value,
        Horas: parseInt(document.getElementById('editarHoras').value),
        Hora_de_fichar: parseInt(document.getElementById('editarHoraFichar').value),
        Sueldo: parseInt(document.getElementById('editarSueldo').value)
    };
    
    try {
        const response = await fetch(`/api/empleados/${nombre}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(datosActualizados)
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || 'Error al actualizar empleado');
        }
        
        mostrarMensaje('Empleado actualizado exitosamente', 'exito');
        cerrarModal();
        cargarEmpleados();
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje(error.message, 'error');
    }
}

// Mostrar mensajes
function mostrarMensaje(mensaje, tipo) {
    mensajeEstado.textContent = mensaje;
    mensajeEstado.className = `mensaje-${tipo}`;
    
    setTimeout(() => {
        mensajeEstado.className = '';
    }, 4000);
}
