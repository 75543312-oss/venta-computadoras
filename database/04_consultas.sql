-- =====================================================================
-- 04_consultas.sql  |  Consultas clave del sistema (cada una alimenta una ruta)
-- =====================================================================
USE venta_computadoras;

-- Q1  GET /api/productos  -> catálogo con categoría, marca y proveedor
SELECT p.id_producto, p.codigo, p.nombre, p.precio, p.stock,
       c.nombre AS categoria, m.nombre AS marca, pr.razon_social AS proveedor
FROM producto p
JOIN categoria c  ON c.id_categoria = p.id_categoria
JOIN marca m      ON m.id_marca     = p.id_marca
JOIN proveedor pr ON pr.id_proveedor = p.id_proveedor
ORDER BY p.nombre;

-- Q2  GET /api/productos?categoria=1&min=1000&max=4000  -> filtro
SELECT id_producto, nombre, precio, stock
FROM producto
WHERE id_categoria = 1 AND precio BETWEEN 1000 AND 4000;

-- Q3  GET /api/productos/stock-bajo  -> productos con stock menor a 10
SELECT id_producto, nombre, stock FROM producto WHERE stock < 10 ORDER BY stock;

-- Q4  GET /api/ventas/:id  -> cabecera de la factura con datos del cliente
SELECT v.id_venta, v.numero_comprobante, v.fecha, v.estado,
       CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
       c.tipo_documento, c.numero_documento,
       v.subtotal, v.igv, v.total
FROM venta v
JOIN cliente c ON c.id_cliente = v.id_cliente
WHERE v.id_venta = 1;

-- Q5  GET /api/ventas/:id  -> detalle de la factura
SELECT d.id_detalle, p.codigo, p.nombre, d.cantidad, d.precio_unitario, d.subtotal
FROM detalle_venta d
JOIN producto p ON p.id_producto = d.id_producto
WHERE d.id_venta = 1;

-- Q6  GET /api/clientes/:id/ventas  -> historial de compras de un cliente
SELECT id_venta, numero_comprobante, fecha, total, estado
FROM venta
WHERE id_cliente = 1
ORDER BY fecha DESC;

-- Q7  GET /api/reportes/mas-vendidos  -> top de productos vendidos
SELECT p.nombre, SUM(d.cantidad) AS unidades, SUM(d.subtotal) AS ingresos
FROM detalle_venta d
JOIN venta v    ON v.id_venta = d.id_venta AND v.estado <> 'ANULADA'
JOIN producto p ON p.id_producto = d.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY unidades DESC
LIMIT 5;

-- Q8  GET /api/reportes/ventas-mensuales  -> total vendido por mes
SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, COUNT(*) AS ventas, SUM(total) AS total
FROM venta
WHERE estado <> 'ANULADA'
GROUP BY DATE_FORMAT(fecha, '%Y-%m')
ORDER BY mes;

-- Q9  GET /api/reportes/ventas-por-categoria
SELECT c.nombre AS categoria, SUM(d.cantidad) AS unidades, SUM(d.subtotal) AS ingresos
FROM detalle_venta d
JOIN venta v     ON v.id_venta = d.id_venta AND v.estado <> 'ANULADA'
JOIN producto p  ON p.id_producto = d.id_producto
JOIN categoria c ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY ingresos DESC;

-- ---------------------------------------------------------------------
-- Proceso de venta completo (POST /api/ventas) - se ejecuta en transacción
-- ---------------------------------------------------------------------
-- START TRANSACTION;
--   CALL sp_registrar_venta('F001-0004', 3, @id);
--   CALL sp_agregar_detalle(@id, 3, 1);
--   CALL sp_agregar_detalle(@id, 6, 2);
-- COMMIT;          -- si algún CALL falla: ROLLBACK;

-- Anular una venta y devolver stock (PATCH /api/ventas/:id/anular)
-- CALL sp_anular_venta(2);
