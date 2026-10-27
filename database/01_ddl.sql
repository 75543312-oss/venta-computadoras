-- =====================================================================
-- 01_ddl.sql  |  Sistema de Venta de Computadoras
-- Motor: MySQL 8.x  (compatible con MariaDB 10.5+)
-- Crea la base de datos, tablas, llaves primarias, foráneas y restricciones
-- =====================================================================

DROP DATABASE IF EXISTS venta_computadoras;
CREATE DATABASE venta_computadoras
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE venta_computadoras;

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------
CREATE TABLE categoria (
  id_categoria INT          NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(50)  NOT NULL,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE marca (
  id_marca INT         NOT NULL AUTO_INCREMENT,
  nombre   VARCHAR(50) NOT NULL,
  CONSTRAINT pk_marca PRIMARY KEY (id_marca),
  CONSTRAINT uq_marca_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE proveedor (
  id_proveedor INT          NOT NULL AUTO_INCREMENT,
  razon_social VARCHAR(100) NOT NULL,
  ruc          CHAR(11)     NOT NULL,
  telefono     VARCHAR(20),
  email        VARCHAR(100),
  direccion    VARCHAR(150),
  CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor),
  CONSTRAINT uq_proveedor_ruc UNIQUE (ruc)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Productos (computadoras, monitores, accesorios, componentes...)
-- ---------------------------------------------------------------------
CREATE TABLE producto (
  id_producto  INT           NOT NULL AUTO_INCREMENT,
  codigo       VARCHAR(20)   NOT NULL,
  nombre       VARCHAR(100)  NOT NULL,
  descripcion  VARCHAR(255),
  precio       DECIMAL(10,2) NOT NULL,
  stock        INT           NOT NULL DEFAULT 0,
  id_categoria INT           NOT NULL,
  id_marca     INT           NOT NULL,
  id_proveedor INT           NOT NULL,
  CONSTRAINT pk_producto PRIMARY KEY (id_producto),
  CONSTRAINT uq_producto_codigo UNIQUE (codigo),
  CONSTRAINT ck_producto_precio CHECK (precio > 0),
  CONSTRAINT ck_producto_stock  CHECK (stock >= 0),
  CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_producto_marca FOREIGN KEY (id_marca)
    REFERENCES marca (id_marca) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_producto_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES proveedor (id_proveedor) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_producto_nombre ON producto (nombre);

-- ---------------------------------------------------------------------
-- Clientes
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente       INT          NOT NULL AUTO_INCREMENT,
  nombres          VARCHAR(80)  NOT NULL,
  apellidos        VARCHAR(80)  NOT NULL,
  tipo_documento   ENUM('DNI','RUC','CE') NOT NULL DEFAULT 'DNI',
  numero_documento VARCHAR(15)  NOT NULL,
  telefono         VARCHAR(20),
  email            VARCHAR(100),
  direccion        VARCHAR(150),
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_documento UNIQUE (tipo_documento, numero_documento)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Ventas (cabecera) y detalle
-- ---------------------------------------------------------------------
CREATE TABLE venta (
  id_venta           INT           NOT NULL AUTO_INCREMENT,
  numero_comprobante VARCHAR(20)   NOT NULL,
  fecha              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_cliente         INT           NOT NULL,
  subtotal           DECIMAL(12,2) NOT NULL DEFAULT 0,
  igv                DECIMAL(12,2) NOT NULL DEFAULT 0,
  total              DECIMAL(12,2) NOT NULL DEFAULT 0,
  estado             ENUM('PENDIENTE','PAGADA','ANULADA') NOT NULL DEFAULT 'PENDIENTE',
  CONSTRAINT pk_venta PRIMARY KEY (id_venta),
  CONSTRAINT uq_venta_comprobante UNIQUE (numero_comprobante),
  CONSTRAINT ck_venta_montos CHECK (subtotal >= 0 AND igv >= 0 AND total >= 0),
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_venta_fecha ON venta (fecha);

CREATE TABLE detalle_venta (
  id_detalle      INT           NOT NULL AUTO_INCREMENT,
  id_venta        INT           NOT NULL,
  id_producto     INT           NOT NULL,
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_detalle),
  CONSTRAINT uq_detalle_venta_producto UNIQUE (id_venta, id_producto),
  CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
  CONSTRAINT ck_detalle_precio   CHECK (precio_unitario > 0),
  CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
    REFERENCES venta (id_venta) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
    REFERENCES producto (id_producto) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
