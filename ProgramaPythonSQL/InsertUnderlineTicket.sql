
DROP DATABASE IF EXISTS `tienda`;
CREATE DATABASE IF NOT EXISTS `tienda` DEFAULT CHARACTER SET = utf8mb4 DEFAULT COLLATE = utf8mb4_general_ci;
USE `tienda`;

CREATE TABLE IF NOT EXISTS `sucursal` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`nombre` VARCHAR(255) NOT NULL,
	`direccion` VARCHAR(255),
	`cif` VARCHAR(50),
	`telefono` VARCHAR(50),
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `empleado` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`codigo` VARCHAR(50),
	`nombre` VARCHAR(255) NOT NULL,
	`sucursal_id` INT UNSIGNED,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	KEY `idx_empleado_sucursal` (`sucursal_id`),
	CONSTRAINT `fk_empleado_sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `producto` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`sku` VARCHAR(100),
	`nombre` VARCHAR(255) NOT NULL,
	`unidad` VARCHAR(50),
	`precio_unitario` DECIMAL(12,4) DEFAULT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `ux_producto_sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ticket` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ticket_num` VARCHAR(50) NOT NULL,
	`fecha` DATE,
	`hora` TIME,
	`sucursal_id` INT UNSIGNED,
	`empleado_id` INT UNSIGNED,
	`subtotal` DECIMAL(12,2),
	`iva` DECIMAL(12,2),
	`total` DECIMAL(12,2),
	`forma_pago` VARCHAR(50),
	`autorizacion` VARCHAR(100),
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `ux_ticket_ticketnum` (`ticket_num`),
	KEY `idx_ticket_sucursal` (`sucursal_id`),
	KEY `idx_ticket_empleado` (`empleado_id`),
	CONSTRAINT `fk_ticket_sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal`(`id`) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT `fk_ticket_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleado`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ticket_linea` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ticket_id` INT UNSIGNED NOT NULL,
	`producto_id` INT UNSIGNED,
	`descripcion` VARCHAR(255),
	`cantidad` DECIMAL(14,3) NOT NULL,
	`unidad` VARCHAR(50),
	`precio_unitario` DECIMAL(12,4),
	`importe` DECIMAL(14,2),
	`line_order` INT UNSIGNED DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `idx_linea_ticket` (`ticket_id`),
	CONSTRAINT `fk_linea_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT `fk_linea_producto` FOREIGN KEY (`producto_id`) REFERENCES `producto`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pago` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ticket_id` INT UNSIGNED NOT NULL,
	`forma_pago` VARCHAR(50),
	`importe` DECIMAL(14,2),
	`autorizacion` VARCHAR(100),
	`detalles` VARCHAR(255),
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	KEY `idx_pago_ticket` (`ticket_id`),
	CONSTRAINT `fk_pago_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- INSERTS generados a partir de los archivos en `facturas/`

-- Sucursal (única en las facturas)
INSERT INTO `sucursal` (`id`,`nombre`,`direccion`,`cif`,`telefono`,`created_at`) VALUES
(1,'SUPERMERCADOS EL AHORRO','Av. Principal #123 - Madrid','B12345678','910123456',CURRENT_TIMESTAMP);

-- Empleados (código y nombre extraídos de las facturas)
INSERT INTO `empleado` (`id`,`codigo`,`nombre`,`sucursal_id`,`created_at`) VALUES
(1,'015','Juan Pérez',1,CURRENT_TIMESTAMP),
(2,'033','Laura García',1,CURRENT_TIMESTAMP),
(3,'011','Carlos Ruiz',1,CURRENT_TIMESTAMP),
(4,'028','Ana Fernández',1,CURRENT_TIMESTAMP),
(5,'019','Sofía Martínez',1,CURRENT_TIMESTAMP),
(6,'042','Diego Gómez',1,CURRENT_TIMESTAMP),
(7,'024','Marta López',1,CURRENT_TIMESTAMP);

-- Productos (nombre y unidad inferidos)
INSERT INTO `producto` (`id`,`sku`,`nombre`,`unidad`,`precio_unitario`,`created_at`) VALUES
(1,NULL,'Pasta Spaghetti 500g','500g',NULL,CURRENT_TIMESTAMP),
(2,NULL,'Café Molido 250g','250g',NULL,CURRENT_TIMESTAMP),
(3,NULL,'Arroz Redondo 1kg','1kg',NULL,CURRENT_TIMESTAMP),
(4,NULL,'Aceite de Oliva 1L','1L',NULL,CURRENT_TIMESTAMP),
(5,NULL,'Sal Fina 1kg','1kg',NULL,CURRENT_TIMESTAMP),
(6,NULL,'Manzana Golden (kg)','kg',NULL,CURRENT_TIMESTAMP),
(7,NULL,'Pechuga de Pollo (kg)','kg',NULL,CURRENT_TIMESTAMP),
(8,NULL,'Cebolla (kg)','kg',NULL,CURRENT_TIMESTAMP),
(9,NULL,'Huevos Camperos 12u','12u',NULL,CURRENT_TIMESTAMP),
(10,NULL,'Pimiento Rojo (kg)','kg',NULL,CURRENT_TIMESTAMP),
(11,NULL,'Queso Manchego 250g','250g',NULL,CURRENT_TIMESTAMP),
(12,NULL,'Galletas María 200g','200g',NULL,CURRENT_TIMESTAMP),
(13,NULL,'Banana (kg)','kg',NULL,CURRENT_TIMESTAMP),
(14,NULL,'Leche Entera 1L','1L',NULL,CURRENT_TIMESTAMP),
(15,NULL,'Tomate Triturado 400g','400g',NULL,CURRENT_TIMESTAMP),
(16,NULL,'Azúcar 1kg','1kg',NULL,CURRENT_TIMESTAMP),
(17,NULL,'Pan Baguette 250g','250g',NULL,CURRENT_TIMESTAMP),
(18,NULL,'Mantequilla 250g','250g',NULL,CURRENT_TIMESTAMP),
(19,NULL,'Yogur Natural 125g','125g',NULL,CURRENT_TIMESTAMP),
(20,NULL,'Refresco Cola 2L','2L',NULL,CURRENT_TIMESTAMP);

-- Tickets, líneas y pagos (uno por cada archivo factura_001..factura_020)
-- Nota: se insertan ids explícitos para mantener referencias consistentes en este script.

-- Ticket 1 (factura_001.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(1,'20010001','2025-09-11','17:01',1,1,25.42,5.34,30.76,'TARJETA','741486',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(1,1,1,'Pasta Spaghetti 500g',2.000,'500g',0.8500,1.70,1),
(2,1,2,'Café Molido 250g',1.000,'250g',3.8000,3.80,2),
(3,1,3,'Arroz Redondo 1kg',2.000,'1kg',1.1500,2.30,3),
(4,1,4,'Aceite de Oliva 1L',2.000,'1L',6.5000,13.00,4),
(5,1,5,'Sal Fina 1kg',3.000,'1kg',0.5000,1.50,5),
(6,1,6,'Manzana Golden (kg)',2.500,'kg',1.2480,3.12,6);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(1,1,'TARJETA',30.76,'741486',NULL,CURRENT_TIMESTAMP);

-- Ticket 2 (factura_002.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(2,'20010002','2025-09-12','18:26',1,2,28.10,5.90,34.00,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(7,2,6,'Manzana Golden (kg)',0.500,'kg',1.2400,0.62,1),
(8,2,7,'Pechuga de Pollo (kg)',1.000,'kg',6.2000,6.20,2),
(9,2,5,'Sal Fina 1kg',2.000,'1kg',0.5000,1.00,3),
(10,2,8,'Cebolla (kg)',1.250,'kg',1.1040,1.38,4),
(11,2,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,5),
(12,2,10,'Pimiento Rojo (kg)',1.500,'kg',2.4000,3.60,6),
(13,2,11,'Queso Manchego 250g',2.000,'250g',4.2000,8.40,7),
(14,2,2,'Café Molido 250g',1.000,'250g',3.8000,3.80,8);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(2,2,'EFECTIVO',34.00,NULL,NULL,CURRENT_TIMESTAMP);

-- Ticket 3 (factura_003.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(3,'20010003','2025-09-13','10:15',1,3,22.30,4.68,26.98,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(15,3,8,'Cebolla (kg)',2.000,'kg',1.1000,2.20,1),
(16,3,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,2),
(17,3,1,'Pasta Spaghetti 500g',3.000,'500g',0.8500,2.55,3),
(18,3,11,'Queso Manchego 250g',2.000,'250g',4.2000,8.40,4),
(19,3,5,'Sal Fina 1kg',1.000,'1kg',0.5000,0.50,5),
(20,3,18,'Leche Entera 1L',3.000,'1L',0.9500,2.85,6),
(21,3,15,'Tomate Triturado 400g',3.000,'400g',0.9000,2.70,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(3,3,'EFECTIVO',26.98,NULL,NULL,CURRENT_TIMESTAMP);

-- Ticket 4 (factura_004.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(4,'20010004','2025-09-14','10:29',1,4,18.10,3.80,21.90,'TARJETA','257572',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(22,4,12,'Galletas María 200g',2.000,'200g',0.8000,1.60,1),
(23,4,3,'Arroz Redondo 1kg',3.000,'1kg',1.1500,3.45,2),
(24,4,13,'Banana (kg)',1.000,'kg',1.7500,1.75,3),
(25,4,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,4),
(26,4,4,'Aceite de Oliva 1L',1.000,'1L',6.5000,6.50,5),
(27,4,1,'Pasta Spaghetti 500g',2.000,'500g',0.8500,1.70,6);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(4,4,'TARJETA',21.90,'257572',NULL,CURRENT_TIMESTAMP);

-- Ticket 5 (factura_005.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(5,'20010005','2025-09-15','13:37',1,5,32.75,6.88,39.63,'TARJETA','114488',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(28,5,15,'Tomate Triturado 400g',2.000,'400g',0.9000,1.80,1),
(29,5,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,2),
(30,5,16,'Azúcar 1kg',1.000,'1kg',1.1000,1.10,3),
(31,5,10,'Pimiento Rojo (kg)',2.500,'kg',2.4000,6.00,4),
(32,5,17,'Pan Baguette 250g',2.000,'250g',0.7000,1.40,5),
(33,5,12,'Galletas María 200g',1.000,'200g',0.8000,0.80,6),
(34,5,18,'Mantequilla 250g',3.000,'250g',1.6000,4.80,7),
(35,5,2,'Café Molido 250g',3.000,'250g',3.8000,11.40,8),
(36,5,19,'Yogur Natural 125g',1.000,'125g',0.4500,0.45,9),
(37,5,14,'Leche Entera 1L',2.000,'1L',0.9500,1.90,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(5,5,'TARJETA',39.63,'114488',NULL,CURRENT_TIMESTAMP);

-- Ticket 6 (factura_006.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(6,'20010006','2025-09-16','17:35',1,6,34.25,7.19,41.44,'TARJETA','253659',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(38,6,5,'Sal Fina 1kg',2.000,'1kg',0.5000,1.00,1),
(39,6,13,'Banana (kg)',1.000,'kg',1.7500,1.75,2),
(40,6,3,'Arroz Redondo 1kg',1.000,'1kg',1.1500,1.15,3),
(41,6,2,'Café Molido 250g',1.000,'250g',3.8000,3.80,4),
(42,6,11,'Queso Manchego 250g',1.000,'250g',4.2000,4.20,5),
(43,6,4,'Aceite de Oliva 1L',2.000,'1L',6.5000,13.00,6),
(44,6,6,'Manzana Golden (kg)',1.000,'kg',1.2500,1.25,7),
(45,6,14,'Leche Entera 1L',3.000,'1L',0.9500,2.85,8),
(46,6,19,'Yogur Natural 125g',1.000,'125g',0.4500,0.45,9),
(47,6,10,'Pimiento Rojo (kg)',2.000,'kg',2.4000,4.80,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(6,6,'TARJETA',41.44,'253659',NULL,CURRENT_TIMESTAMP);

-- Ticket 7 (factura_007.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(7,'20010007','2025-09-17','10:57',1,7,29.10,6.11,35.21,'TARJETA','286629',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(48,7,9,'Huevos Camperos 12u',2.000,'12u',3.1000,6.20,1),
(49,7,11,'Queso Manchego 250g',1.000,'250g',4.2000,4.20,2),
(50,7,4,'Aceite de Oliva 1L',1.000,'1L',6.5000,6.50,3),
(51,7,7,'Pechuga de Pollo (kg)',1.000,'kg',6.2000,6.20,4),
(52,7,16,'Azúcar 1kg',1.000,'1kg',1.1000,1.10,5),
(53,7,14,'Leche Entera 1L',2.000,'1L',0.9500,1.90,6),
(54,7,12,'Galletas María 200g',2.000,'200g',0.8000,1.60,7),
(55,7,5,'Sal Fina 1kg',1.000,'1kg',0.5000,0.50,8),
(56,7,19,'Yogur Natural 125g',2.000,'125g',0.4500,0.90,9);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(7,7,'TARJETA',35.21,'286629',NULL,CURRENT_TIMESTAMP);

-- Ticket 8 (factura_008.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(8,'20010008','2025-09-18','19:12',1,1,38.15,8.01,46.16,'TARJETA','656754',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(57,8,5,'Sal Fina 1kg',2.000,'1kg',0.5000,1.00,1),
(58,8,7,'Pechuga de Pollo (kg)',2.500,'kg',6.2000,15.50,2),
(59,8,10,'Pimiento Rojo (kg)',1.000,'kg',2.4000,2.40,3),
(60,8,15,'Tomate Triturado 400g',3.000,'400g',0.9000,2.70,4),
(61,8,11,'Queso Manchego 250g',3.000,'250g',4.2000,12.60,5),
(62,8,14,'Leche Entera 1L',3.000,'1L',0.9500,2.85,6),
(63,8,8,'Cebolla (kg)',1.000,'kg',1.1000,1.10,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(8,8,'TARJETA',46.16,'656754',NULL,CURRENT_TIMESTAMP);

-- Ticket 9 (factura_009.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(9,'20010009','2025-09-19','13:36',1,2,31.25,6.56,37.81,'TARJETA','388285',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(64,9,1,'Pasta Spaghetti 500g',3.000,'500g',0.8500,2.55,1),
(65,9,20,'Refresco Cola 2L',3.000,'2L',1.3000,3.90,2),
(66,9,13,'Banana (kg)',2.000,'kg',1.7500,3.50,3),
(67,9,7,'Pechuga de Pollo (kg)',0.500,'kg',6.2000,3.10,4),
(68,9,14,'Leche Entera 1L',3.000,'1L',0.9500,2.85,5),
(69,9,8,'Cebolla (kg)',0.500,'kg',1.1000,0.55,6),
(70,9,16,'Azúcar 1kg',1.000,'1kg',1.1000,1.10,7),
(71,9,3,'Arroz Redondo 1kg',2.000,'1kg',1.1500,2.30,8),
(72,9,17,'Pan Baguette 250g',3.000,'250g',0.7000,2.10,9),
(73,9,9,'Huevos Camperos 12u',3.000,'12u',3.1000,9.30,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(9,9,'TARJETA',37.81,'388285',NULL,CURRENT_TIMESTAMP);

-- Ticket 10 (factura_010.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(10,'20010010','2025-09-20','17:58',1,3,22.15,4.65,26.80,'TARJETA','132091',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(74,10,16,'Azúcar 1kg',1.000,'1kg',1.1000,1.10,1),
(75,10,1,'Pasta Spaghetti 500g',2.000,'500g',0.8500,1.70,2),
(76,10,18,'Mantequilla 250g',2.000,'250g',1.6000,3.20,3),
(77,10,4,'Aceite de Oliva 1L',1.000,'1L',6.5000,6.50,4),
(78,10,8,'Cebolla (kg)',1.000,'kg',1.1000,1.10,5),
(79,10,2,'Café Molido 250g',2.000,'250g',3.8000,7.60,6),
(80,10,19,'Yogur Natural 125g',1.000,'125g',0.4500,0.45,7),
(81,10,5,'Sal Fina 1kg',1.000,'1kg',0.5000,0.50,8);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(10,10,'TARJETA',26.80,'132091',NULL,CURRENT_TIMESTAMP);

-- Ticket 11 (factura_011.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(11,'20010011','2025-09-21','11:53',1,4,40.00,8.40,48.40,'TARJETA','539623',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(82,11,16,'Azúcar 1kg',3.000,'1kg',1.1000,3.30,1),
(83,11,12,'Galletas María 200g',2.000,'200g',0.8000,1.60,2),
(84,11,9,'Huevos Camperos 12u',2.000,'12u',6.2000,6.20,3),
(85,11,4,'Aceite de Oliva 1L',1.000,'1L',6.5000,6.50,4),
(86,11,2,'Café Molido 250g',3.000,'250g',3.8000,11.40,5),
(87,11,11,'Queso Manchego 250g',2.000,'250g',4.2000,8.40,6),
(88,11,20,'Refresco Cola 2L',2.000,'2L',1.3000,2.60,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(11,11,'TARJETA',48.40,'539623',NULL,CURRENT_TIMESTAMP);

-- Ticket 12 (factura_012.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(12,'20010012','2025-09-22','13:25',1,5,14.20,2.98,17.18,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(89,12,20,'Refresco Cola 2L',1.000,'2L',1.3000,1.30,1),
(90,12,1,'Pasta Spaghetti 500g',1.000,'500g',0.8500,0.85,2),
(91,12,19,'Yogur Natural 125g',1.000,'125g',0.4500,0.45,3),
(92,12,15,'Tomate Triturado 400g',3.000,'400g',0.9000,2.70,4),
(93,12,5,'Sal Fina 1kg',1.000,'1kg',0.5000,0.50,5),
(94,12,11,'Queso Manchego 250g',2.000,'250g',4.2000,8.40,6);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(12,12,'EFECTIVO',17.18,NULL,NULL,CURRENT_TIMESTAMP);

-- Ticket 13 (factura_013.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(13,'20010013','2025-09-23','16:10',1,6,28.05,5.89,33.94,'TARJETA','997874',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(95,13,19,'Yogur Natural 125g',3.000,'125g',0.4500,1.35,1),
(96,13,11,'Queso Manchego 250g',3.000,'250g',4.2000,12.60,2),
(97,13,12,'Galletas María 200g',2.000,'200g',0.8000,1.60,3),
(98,13,20,'Refresco Cola 2L',1.000,'2L',1.3000,1.30,4),
(99,13,3,'Arroz Redondo 1kg',3.000,'1kg',1.1500,3.45,5),
(100,13,7,'Pechuga de Pollo (kg)',1.250,'kg',6.2000,7.75,6);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(13,13,'TARJETA',33.94,'997874',NULL,CURRENT_TIMESTAMP);

-- Ticket 14 (factura_014.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(14,'20010014','2025-09-24','11:21',1,7,27.76,5.83,33.59,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(101,14,3,'Arroz Redondo 1kg',2.000,'1kg',1.1500,2.30,1),
(102,14,13,'Banana (kg)',2.000,'kg',1.7500,3.50,2),
(103,14,7,'Pechuga de Pollo (kg)',1.000,'kg',6.2000,6.20,3),
(104,14,5,'Sal Fina 1kg',2.000,'1kg',0.5000,1.00,4),
(105,14,17,'Pan Baguette 250g',2.000,'250g',0.7000,1.40,5),
(106,14,16,'Azúcar 1kg',2.000,'1kg',1.1000,2.20,6),
(107,14,4,'Aceite de Oliva 1L',1.000,'1L',6.5000,6.50,7),
(108,14,6,'Manzana Golden (kg)',1.250,'kg',1.2480,1.56,8),
(109,14,1,'Pasta Spaghetti 500g',3.000,'500g',0.8500,2.55,9),
(110,14,8,'Cebolla (kg)',0.500,'kg',1.1000,0.55,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(14,14,'EFECTIVO',33.59,NULL,NULL,CURRENT_TIMESTAMP);

-- Ticket 15 (factura_015.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(15,'20010015','2025-09-25','15:58',1,1,19.25,4.04,23.29,'TARJETA','134875',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(111,15,10,'Pimiento Rojo (kg)',1.000,'kg',2.4000,2.40,1),
(112,15,17,'Pan Baguette 250g',2.000,'250g',0.7000,1.40,2),
(113,15,15,'Tomate Triturado 400g',3.000,'400g',0.9000,2.70,3),
(114,15,12,'Galletas María 200g',3.000,'200g',0.8000,2.40,4),
(115,15,18,'Mantequilla 250g',1.000,'250g',1.6000,1.60,5),
(116,15,8,'Cebolla (kg)',2.000,'kg',1.1000,2.20,6),
(117,15,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,7),
(118,15,5,'Sal Fina 1kg',2.000,'1kg',0.5000,1.00,8),
(119,15,3,'Arroz Redondo 1kg',1.000,'1kg',1.1500,1.15,9),
(120,15,20,'Refresco Cola 2L',1.000,'2L',1.3000,1.30,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(15,15,'TARJETA',23.29,'134875',NULL,CURRENT_TIMESTAMP);

-- Ticket 16 (factura_016.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(16,'20010016','2025-09-26','10:34',1,2,23.25,4.88,28.13,'TARJETA','819358',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(121,16,7,'Pechuga de Pollo (kg)',1.000,'kg',6.2000,6.20,1),
(122,16,11,'Queso Manchego 250g',1.000,'250g',4.2000,4.20,2),
(123,16,18,'Mantequilla 250g',2.000,'250g',1.6000,3.20,3),
(124,16,12,'Galletas María 200g',3.000,'200g',0.8000,2.40,4),
(125,16,10,'Pimiento Rojo (kg)',1.000,'kg',2.4000,2.40,5),
(126,16,17,'Pan Baguette 250g',2.000,'250g',0.7000,1.40,6),
(127,16,3,'Arroz Redondo 1kg',3.000,'1kg',1.1500,3.45,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(16,16,'TARJETA',28.13,'819358',NULL,CURRENT_TIMESTAMP);

-- Ticket 17 (factura_017.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(17,'20010017','2025-09-27','18:14',1,3,23.73,4.98,28.71,'TARJETA','199052',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(128,17,3,'Arroz Redondo 1kg',2.000,'1kg',1.1500,2.30,1),
(129,17,13,'Banana (kg)',0.500,'kg',1.7600,0.88,2),
(130,17,8,'Cebolla (kg)',2.500,'kg',1.1000,2.75,3),
(131,17,10,'Pimiento Rojo (kg)',1.000,'kg',2.4000,2.40,4),
(132,17,9,'Huevos Camperos 12u',1.000,'12u',3.1000,3.10,5),
(133,17,15,'Tomate Triturado 400g',1.000,'400g',0.9000,0.90,6),
(134,17,2,'Café Molido 250g',3.000,'250g',3.8000,11.40,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(17,17,'TARJETA',28.71,'199052',NULL,CURRENT_TIMESTAMP);

-- Ticket 18 (factura_018.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(18,'20010018','2025-09-28','14:51',1,4,47.60,10.00,57.60,'TARJETA','643300',CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(135,18,3,'Arroz Redondo 1kg',2.000,'1kg',1.1500,2.30,1),
(136,18,4,'Aceite de Oliva 1L',3.000,'1L',6.5000,19.50,2),
(137,18,19,'Yogur Natural 125g',2.000,'125g',0.4500,0.90,3),
(138,18,12,'Galletas María 200g',3.000,'200g',0.8000,2.40,4),
(139,18,2,'Café Molido 250g',1.000,'250g',3.8000,3.80,5),
(140,18,7,'Pechuga de Pollo (kg)',2.500,'kg',6.2000,15.50,6),
(141,18,18,'Mantequilla 250g',2.000,'250g',1.6000,3.20,7);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(18,18,'TARJETA',57.60,'643300',NULL,CURRENT_TIMESTAMP);

-- Ticket 19 (factura_019.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(19,'20010019','2025-09-29','10:47',1,5,36.52,7.67,44.19,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

INSERT INTO `ticket_linea` (`id`,`ticket_id`,`producto_id`,`descripcion`,`cantidad`,`unidad`,`precio_unitario`,`importe`,`line_order`) VALUES
(142,19,2,'Café Molido 250g',2.000,'250g',3.8000,7.60,1),
(143,19,19,'Yogur Natural 125g',2.000,'125g',0.4500,0.90,2),
(144,19,16,'Azúcar 1kg',2.000,'1kg',1.1000,2.20,3),
(145,19,12,'Galletas María 200g',3.000,'200g',0.8000,2.40,4),
(146,19,6,'Manzana Golden (kg)',0.500,'kg',1.2400,0.62,5),
(147,19,3,'Arroz Redondo 1kg',1.000,'1kg',1.1500,1.15,6),
(148,19,8,'Cebolla (kg)',1.000,'kg',1.1000,1.10,7),
(149,19,14,'Leche Entera 1L',3.000,'1L',0.9500,2.85,8),
(150,19,9,'Huevos Camperos 12u',3.000,'12u',3.1000,9.30,9),
(151,19,11,'Queso Manchego 250g',2.000,'250g',4.2000,8.40,10);

INSERT INTO `pago` (`id`,`ticket_id`,`forma_pago`,`importe`,`autorizacion`,`detalles`,`created_at`) VALUES
(19,19,'EFECTIVO',44.19,NULL,NULL,CURRENT_TIMESTAMP);

-- Ticket 20 (factura_020.txt)
INSERT INTO `ticket` (`id`,`ticket_num`,`fecha`,`hora`,`sucursal_id`,`empleado_id`,`subtotal`,`iva`,`total`,`forma_pago`,`autorizacion`,`created_at`) VALUES
(20,'20010020','2025-09-30','12:00',1,2,0.00,0.00,0.00,'EFECTIVO',NULL,CURRENT_TIMESTAMP);

-- Nota: `factura_020.txt` no estaba listada previamente con contenido; si existe y contiene datos reales,
-- reemplazar la inserción anterior por los valores correspondientes y añadir sus líneas/pago.


