-- ------------------------------------------------------------
-- SQL generado por build_insert_from_tickets.py (append)
-- Generado: 2025-11-25 13:58:43
-- Facturas: factura_001.txt,factura_002.txt,factura_003.txt,factura_004.txt,factura_005.txt,factura_006.txt,factura_007.txt,factura_008.txt,factura_009.txt,factura_010.txt,factura_011.txt,factura_012.txt,factura_013.txt,factura_014.txt,factura_015.txt,factura_016.txt,factura_017.txt,factura_018.txt,factura_019.txt,factura_020.txt
-- ------------------------------------------------------------

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Drop & recreate database `tienda` as requested
DROP DATABASE IF EXISTS `tienda`;
CREATE DATABASE `tienda` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `tienda`;

DROP TABLE IF EXISTS `items`;
DROP TABLE IF EXISTS `invoices`;

CREATE TABLE `sucursal` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(255),
  `direccion` TEXT,
  `cif` VARCHAR(64)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `empleado` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `codigo` VARCHAR(64),
  `nombre` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `producto` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `descripcion` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `ticket` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `sucursal_id` INT,
  `empleado_id` INT,
  `fecha` VARCHAR(32),
  `hora` VARCHAR(16),
  `numero` VARCHAR(128),
  `subtotal` DECIMAL(12,2),
  `iva` DECIMAL(12,2),
  `total` DECIMAL(12,2),
  `forma_pago` VARCHAR(64),
  `autorizacion` VARCHAR(64),
  FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal`(`id`),
  FOREIGN KEY (`empleado_id`) REFERENCES `empleado`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `ticket_linea` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `ticket_id` INT,
  `producto_id` INT,
  `cantidad` DECIMAL(12,3),
  `precio_unitario` DECIMAL(12,4),
  `importe` DECIMAL(12,2),
  FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`),
  FOREIGN KEY (`producto_id`) REFERENCES `producto`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `pago` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `ticket_id` INT,
  `metodo` VARCHAR(64),
  `autorizacion` VARCHAR(64),
  `importe` DECIMAL(12,2),
  FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `sucursal` (`id`,`nombre`,`direccion`,`cif`) VALUES (1,'SUPERMERCADOS EL AHORRO','Av. Principal #123 - Madrid CIF: B12345678  Tel: 910123456 ------------------------------------------------','B12345678');
INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (1,'015','Juan Pérez');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (1,1,1,'11/09/2025','17:01','20010001',25.42,13.00,30.76,'TARJETA','741486');
INSERT INTO `producto` (`id`,`descripcion`) VALUES (1,'Pasta Spaghetti 500g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,1,2.00,0.8500,1.70);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (2,'Café Molido 250g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,2,1.00,3.8000,3.80);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (3,'Arroz Redondo 1kg');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,3,2.00,1.1500,2.30);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (4,'Aceite de Oliva 1L');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,4,2.00,6.5000,13.00);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (5,'Sal Fina 1kg');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,5,3.00,0.5000,1.50);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (6,'Manzana Golden (kg)');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (1,6,2.50,1.2480,3.12);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (1,'TARJETA','741486',30.76);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (2,'033','Laura García');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (2,1,2,'12/09/2025','18:26','20010002',28.10,5.90,34.00,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,6,0.50,1.2400,0.62);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (7,'Pechuga de Pollo (kg)');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,7,1.00,6.2000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,5,2.00,0.5000,1.00);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (8,'Cebolla (kg)');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,8,1.25,1.1040,1.38);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (9,'Huevos Camperos 12u');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,9,1.00,3.1000,3.10);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (10,'Pimiento Rojo (kg)');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,10,1.50,2.4000,3.60);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (11,'Queso Manchego 250g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,11,2.00,4.2000,8.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (2,2,1.00,3.8000,3.80);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (2,'EFECTIVO','',34.00);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (3,'011','Carlos Ruiz');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (3,1,3,'13/09/2025','10:15','20010003',22.30,4.68,26.98,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,8,2.00,1.1000,2.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,9,1.00,3.1000,3.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,1,3.00,0.8500,2.55);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,11,2.00,4.2000,8.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,5,1.00,0.5000,0.50);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (12,'Leche Entera 1L');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,12,3.00,0.9500,2.85);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (13,'Tomate Triturado 400g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (3,13,3.00,0.9000,2.70);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (3,'EFECTIVO','',26.98);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (4,'028','Ana Fernández');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (4,1,4,'14/09/2025','10:29','20010004',18.10,6.50,21.90,'TARJETA','257572');
INSERT INTO `producto` (`id`,`descripcion`) VALUES (14,'Galletas María 200g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,14,2.00,0.8000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,3,3.00,1.1500,3.45);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (15,'Banana (kg)');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,15,1.00,1.7500,1.75);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,9,1.00,3.1000,3.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (4,1,2.00,0.8500,1.70);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (4,'TARJETA','257572',21.90);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (5,'019','Sofía Martínez');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (5,1,5,'15/09/2025','13:37','20010005',32.75,6.88,39.63,'TARJETA','114488');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,13,2.00,0.9000,1.80);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,9,1.00,3.1000,3.10);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (16,'Azúcar 1kg');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,16,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,10,2.50,2.4000,6.00);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (17,'Pan Baguette 250g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,17,2.00,0.7000,1.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,14,1.00,0.8000,0.80);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (18,'Mantequilla 250g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,18,3.00,1.6000,4.80);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,2,3.00,3.8000,11.40);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (19,'Yogur Natural 125g');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,19,1.00,0.4500,0.45);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (5,12,2.00,0.9500,1.90);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (5,'TARJETA','114488',39.63);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (6,'042','Diego Gómez');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (6,1,6,'16/09/2025','17:35','20010006',34.25,13.00,41.44,'TARJETA','253659');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,5,2.00,0.5000,1.00);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,15,1.00,1.7500,1.75);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,3,1.00,1.1500,1.15);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,2,1.00,3.8000,3.80);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,11,1.00,4.2000,4.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,4,2.00,6.5000,13.00);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,6,1.00,1.2500,1.25);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,12,3.00,0.9500,2.85);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,19,1.00,0.4500,0.45);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (6,10,2.00,2.4000,4.80);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (6,'TARJETA','253659',41.44);

INSERT INTO `empleado` (`id`,`codigo`,`nombre`) VALUES (7,'024','Marta López');
INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (7,1,7,'17/09/2025','10:57','20010007',29.10,6.50,35.21,'TARJETA','286629');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,9,2.00,3.1000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,11,1.00,4.2000,4.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,7,1.00,6.2000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,16,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,12,2.00,0.9500,1.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,14,2.00,0.8000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,5,1.00,0.5000,0.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (7,19,2.00,0.4500,0.90);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (7,'TARJETA','286629',35.21);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (8,1,1,'18/09/2025','19:12','20010008',38.15,8.01,46.16,'TARJETA','656754');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,5,2.00,0.5000,1.00);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,7,2.50,6.2000,15.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,10,1.00,2.4000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,13,3.00,0.9000,2.70);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,11,3.00,4.2000,12.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,12,3.00,0.9500,2.85);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (8,8,1.00,1.1000,1.10);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (8,'TARJETA','656754',46.16);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (9,1,2,'19/09/2025','13:36','20010009',31.25,6.56,37.81,'TARJETA','388285');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,1,3.00,0.8500,2.55);
INSERT INTO `producto` (`id`,`descripcion`) VALUES (20,'Refresco Cola 2L');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,20,3.00,1.3000,3.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,15,2.00,1.7500,3.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,7,0.50,6.2000,3.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,12,3.00,0.9500,2.85);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,8,0.50,1.1000,0.55);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,16,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,3,2.00,1.1500,2.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,17,3.00,0.7000,2.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (9,9,3.00,3.1000,9.30);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (9,'TARJETA','388285',37.81);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (10,1,3,'20/09/2025','17:58','20010010',22.15,6.50,26.80,'TARJETA','132091');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,16,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,1,2.00,0.8500,1.70);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,18,2.00,1.6000,3.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,8,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,2,2.00,3.8000,7.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,19,1.00,0.4500,0.45);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (10,5,1.00,0.5000,0.50);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (10,'TARJETA','132091',26.80);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (11,1,4,'21/09/2025','11:53','20010011',40.00,6.50,48.40,'TARJETA','539623');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,16,3.00,1.1000,3.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,14,2.00,0.8000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,9,2.00,3.1000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,2,3.00,3.8000,11.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,11,2.00,4.2000,8.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (11,20,2.00,1.3000,2.60);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (11,'TARJETA','539623',48.40);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (12,1,5,'22/09/2025','13:25','20010012',14.20,2.98,17.18,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,20,1.00,1.3000,1.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,1,1.00,0.8500,0.85);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,19,1.00,0.4500,0.45);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,13,3.00,0.9000,2.70);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,5,1.00,0.5000,0.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (12,11,2.00,4.2000,8.40);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (12,'EFECTIVO','',17.18);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (13,1,6,'23/09/2025','16:10','20010013',28.05,5.89,33.94,'TARJETA','997874');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,19,3.00,0.4500,1.35);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,11,3.00,4.2000,12.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,14,2.00,0.8000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,20,1.00,1.3000,1.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,3,3.00,1.1500,3.45);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (13,7,1.25,6.2000,7.75);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (13,'TARJETA','997874',33.94);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (14,1,7,'24/09/2025','11:21','20010014',27.76,6.50,33.59,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,3,2.00,1.1500,2.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,15,2.00,1.7500,3.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,7,1.00,6.2000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,5,2.00,0.5000,1.00);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,17,2.00,0.7000,1.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,16,2.00,1.1000,2.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,6,1.25,1.2480,1.56);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,1,3.00,0.8500,2.55);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (14,8,0.50,1.1000,0.55);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (14,'EFECTIVO','',33.59);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (15,1,1,'25/09/2025','15:58','20010015',19.25,4.04,23.29,'TARJETA','134875');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,10,1.00,2.4000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,17,2.00,0.7000,1.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,13,3.00,0.9000,2.70);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,14,3.00,0.8000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,18,1.00,1.6000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,8,2.00,1.1000,2.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,9,1.00,3.1000,3.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,5,2.00,0.5000,1.00);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,3,1.00,1.1500,1.15);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (15,20,1.00,1.3000,1.30);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (15,'TARJETA','134875',23.29);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (16,1,2,'26/09/2025','10:34','20010016',23.25,4.88,28.13,'TARJETA','819358');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,7,1.00,6.2000,6.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,11,1.00,4.2000,4.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,18,2.00,1.6000,3.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,14,3.00,0.8000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,10,1.00,2.4000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,17,2.00,0.7000,1.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (16,3,3.00,1.1500,3.45);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (16,'TARJETA','819358',28.13);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (17,1,3,'27/09/2025','18:14','20010017',23.73,4.98,28.71,'TARJETA','199052');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,3,2.00,1.1500,2.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,15,0.50,1.7600,0.88);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,8,2.50,1.1000,2.75);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,10,1.00,2.4000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,9,1.00,3.1000,3.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,13,1.00,0.9000,0.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (17,2,3.00,3.8000,11.40);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (17,'TARJETA','199052',28.71);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (18,1,4,'28/09/2025','14:51','20010018',47.60,19.50,57.60,'TARJETA','643300');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,3,2.00,1.1500,2.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,4,3.00,6.5000,19.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,19,2.00,0.4500,0.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,14,3.00,0.8000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,2,1.00,3.8000,3.80);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,7,2.50,6.2000,15.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (18,18,2.00,1.6000,3.20);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (18,'TARJETA','643300',57.60);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (19,1,5,'29/09/2025','10:47','20010019',36.52,7.67,44.19,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,2,2.00,3.8000,7.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,19,2.00,0.4500,0.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,16,2.00,1.1000,2.20);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,14,3.00,0.8000,2.40);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,6,0.50,1.2400,0.62);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,3,1.00,1.1500,1.15);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,8,1.00,1.1000,1.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,12,3.00,0.9500,2.85);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,9,3.00,3.1000,9.30);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (19,11,2.00,4.2000,8.40);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (19,'EFECTIVO','',44.19);

INSERT INTO `ticket` (`id`,`sucursal_id`,`empleado_id`,`fecha`,`hora`,`numero`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`) VALUES (20,1,6,'30/09/2025','12:55','20010020',38.00,6.50,45.98,'EFECTIVO','');
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,7,2.50,6.2000,15.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,4,1.00,6.5000,6.50);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,17,3.00,0.7000,2.10);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,14,2.00,0.8000,1.60);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,13,1.00,0.9000,0.90);
INSERT INTO `ticket_linea` (`ticket_id`,`producto_id`,`cantidad`,`precio_unitario`,`importe`) VALUES (20,2,3.00,3.8000,11.40);
INSERT INTO `pago` (`ticket_id`,`metodo`,`autorizacion`,`importe`) VALUES (20,'EFECTIVO','',45.98);

SET FOREIGN_KEY_CHECKS = 1;
