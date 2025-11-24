
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




