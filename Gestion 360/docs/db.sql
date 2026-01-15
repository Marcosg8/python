-- Crear base y usuario
CREATE DATABASE IF NOT EXISTS gestor_empleado;
CREATE USER IF NOT EXISTS 'marcos'@'localhost' IDENTIFIED BY 'casa';
GRANT ALL PRIVILEGES ON gestor_empleado.* TO 'marcos'@'localhost';
FLUSH PRIVILEGES;

-- Usar BD
USE gestor_empleado;

-- Crear tabla empleado (estructura de tu captura)
CREATE TABLE IF NOT EXISTS empleado (
    Nombre VARCHAR(100) NOT NULL,
    PrimerApellido VARCHAR(100),
    SegundoApellido VARCHAR(100),
    Departamento VARCHAR(100),
    Tipo_de_Jornada VARCHAR(50),
    Horas INT,
    Hora_de_fichar INT,
    Sueldo INT,
    PRIMARY KEY (Nombre)
);

-- Datos de ejemplo
INSERT INTO empleado (Nombre, PrimerApellido, SegundoApellido, Departamento, Tipo_de_Jornada, Horas, Hora_de_fichar, Sueldo) VALUES
('Juan', 'Pérez', 'García', 'Ventas', 'Completa', 40, 9, 2000),
('María', 'López', 'Martínez', 'Marketing', 'Completa', 40, 8, 2500),
('Carlos', 'Ruiz', 'Sánchez', 'IT', 'Media', 20, 10, 1500);