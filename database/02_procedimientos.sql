-- =====================================================================
-- 02_procedimientos.sql  |  Procedimientos almacenados del proceso de venta
-- Ejecutar DESPUÉS de 01_ddl.sql
-- =====================================================================
USE venta_computadoras;

DROP PROCEDURE IF EXISTS sp_registrar_venta;
DROP PROCEDURE IF EXISTS sp_agregar_detalle;
DROP PROCEDURE IF EXISTS sp_anular_venta;

DELIMITER $$

-- 1) Crea la cabecera de la venta (totales en 0)
CREATE PROCEDURE sp_registrar_venta(
  IN  p_numero_comprobante VARCHAR(20),
  IN  p_id_cliente         INT,
  OUT p_id_venta           INT
)
BEGIN
  INSERT INTO venta (numero_comprobante, id_cliente)
  VALUES (p_numero_comprobante, p_id_cliente);
  SET p_id_venta = LAST_INSERT_ID();
END$$

-- 2) Agrega un producto a la venta: valida stock, toma el precio vigente,
--    descuenta stock y recalcula subtotal, IGV (18%) y total
CREATE PROCEDURE sp_agregar_detalle(
  IN p_id_venta    INT,
  IN p_id_producto INT,
  IN p_cantidad    INT
)
BEGIN
  DECLARE v_precio   DECIMAL(10,2);
  DECLARE v_stock    INT;
  DECLARE v_estado   VARCHAR(10);
  DECLARE v_subtotal DECIMAL(12,2);

  SELECT estado INTO v_estado FROM venta WHERE id_venta = p_id_venta FOR UPDATE;
  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
  END IF;
  IF v_estado = 'ANULADA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar una venta anulada';
  END IF;

  SELECT precio, stock INTO v_precio, v_stock
  FROM producto WHERE id_producto = p_id_producto FOR UPDATE;

  IF v_precio IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
  END IF;
  IF p_cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0';
  END IF;
  IF v_stock < p_cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
  END IF;

  INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal)
  VALUES (p_id_venta, p_id_producto, p_cantidad, v_precio, v_precio * p_cantidad);

  UPDATE producto SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;

  SELECT SUM(subtotal) INTO v_subtotal FROM detalle_venta WHERE id_venta = p_id_venta;
  UPDATE venta
     SET subtotal = v_subtotal,
         igv      = ROUND(v_subtotal * 0.18, 2),
         total    = v_subtotal + ROUND(v_subtotal * 0.18, 2)
   WHERE id_venta = p_id_venta;
END$$

-- 3) Anula una venta y devuelve el stock
CREATE PROCEDURE sp_anular_venta(IN p_id_venta INT)
BEGIN
  DECLARE v_estado VARCHAR(10);

  SELECT estado INTO v_estado FROM venta WHERE id_venta = p_id_venta FOR UPDATE;
  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
  END IF;
  IF v_estado = 'ANULADA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta ya está anulada';
  END IF;

  UPDATE producto p
    JOIN detalle_venta d ON d.id_producto = p.id_producto
     SET p.stock = p.stock + d.cantidad
   WHERE d.id_venta = p_id_venta;

  UPDATE venta SET estado = 'ANULADA' WHERE id_venta = p_id_venta;
END$$

DELIMITER ;
