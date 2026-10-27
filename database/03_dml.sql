-- =====================================================================
-- 03_dml.sql  |  Datos de prueba
-- Ejecutar DESPUÉS de 01_ddl.sql y 02_procedimientos.sql
-- =====================================================================
USE venta_computadoras;

INSERT INTO categoria (id_categoria, nombre) VALUES
  (1, 'Laptops'),
  (2, 'PC de escritorio'),
  (3, 'Monitores'),
  (4, 'Accesorios'),
  (5, 'Componentes'),
  (6, 'Impresoras');

INSERT INTO marca (id_marca, nombre) VALUES
  (1, 'Lenovo'),
  (2, 'Asus'),
  (3, 'HP'),
  (4, 'Dell'),
  (5, 'Samsung'),
  (6, 'Logitech'),
  (7, 'Kingston');

INSERT INTO proveedor (id_proveedor, razon_social, ruc, telefono, email, direccion) VALUES
  (1, 'Distribuidora Tecnológica SAC', '20111111111', '01-4445566', 'ventas@distritec.pe',  'Av. Industrial 450, Lima'),
  (2, 'Importaciones Andinas EIRL',    '20222222222', '064-221133', 'contacto@andinas.pe',  'Jr. Real 789, Huancayo'),
  (3, 'Mayorista Digital SA',          '20333333333', '01-7778899', 'compras@mdigital.pe',  'Av. Arequipa 1200, Lima');

INSERT INTO producto (id_producto, codigo, nombre, descripcion, precio, stock, id_categoria, id_marca, id_proveedor) VALUES
  (1,  'LEN-LP-001', 'Laptop Lenovo IdeaPad 15',      'Core i5, 8GB RAM, 512GB SSD',        2800.00, 15, 1, 1, 1),
  (2,  'ASU-LP-002', 'Laptop Asus TUF Gaming',        'Ryzen 7, 16GB RAM, RTX 4050',        4200.00,  8, 1, 2, 1),
  (3,  'HP-LP-003',  'Laptop HP Pavilion 14',         'Core i5, 16GB RAM, 512GB SSD',       3100.00, 10, 1, 3, 3),
  (4,  'DEL-PC-004', 'PC Dell OptiPlex',              'Core i7, 16GB RAM, 1TB SSD',         2500.00,  6, 2, 4, 3),
  (5,  'SAM-MN-005', 'Monitor Samsung 24"',           'Full HD, 75Hz, HDMI',                 650.00, 20, 3, 5, 2),
  (6,  'LOG-AC-006', 'Teclado Mecánico Logitech',     'Switches táctiles, retroiluminado',   180.00, 30, 4, 6, 2),
  (7,  'LOG-AC-007', 'Mouse Inalámbrico Logitech',    '1600 DPI, USB',                        90.00, 40, 4, 6, 2),
  (8,  'KIN-CP-008', 'SSD Kingston 1TB',              'NVMe M.2',                            320.00, 25, 5, 7, 1),
  (9,  'HP-IM-009',  'Impresora HP Multifuncional',   'Tinta continua, WiFi',                550.00, 12, 6, 3, 3),
  (10, 'KIN-CP-010', 'Memoria RAM Kingston 16GB',     'DDR4 3200MHz',                        240.00, 35, 5, 7, 1);

INSERT INTO cliente (id_cliente, nombres, apellidos, tipo_documento, numero_documento, telefono, email, direccion) VALUES
  (1, 'Carlos',  'Pérez Quispe',    'DNI', '45678912', '987654321', 'carlos.perez@mail.com',  'Jr. Puno 123, Huancayo'),
  (2, 'Laura',   'Gómez Rojas',     'DNI', '41234567', '976543210', 'laura.gomez@mail.com',   'Av. Giráldez 456, Huancayo'),
  (3, 'Miguel',  'Torres Lazo',     'DNI', '47891234', '965432109', 'miguel.torres@mail.com', 'Calle Lima 78, Huancayo'),
  (4, 'Sofía',   'López Cárdenas',  'CE',  '001234567','954321098', 'sofia.lopez@mail.com',   'Av. Ferrocarril 900, Huancayo'),
  (5, 'Tech Solutions SAC', '-',    'RUC', '20123456789','064-123456','compras@techsol.pe',   'Av. Tecnología 123, Huancayo');

-- Ventas registradas con los procedimientos (descuentan stock y calculan IGV)
START TRANSACTION;
  CALL sp_registrar_venta('F001-0001', 1, @v1);
  CALL sp_agregar_detalle(@v1, 1, 2);   -- 2 Laptop Lenovo
  CALL sp_agregar_detalle(@v1, 7, 2);   -- 2 Mouse Logitech
COMMIT;

START TRANSACTION;
  CALL sp_registrar_venta('F001-0002', 2, @v2);
  CALL sp_agregar_detalle(@v2, 2, 1);   -- 1 Laptop Asus
  CALL sp_agregar_detalle(@v2, 5, 1);   -- 1 Monitor Samsung
  CALL sp_agregar_detalle(@v2, 6, 1);   -- 1 Teclado Logitech
COMMIT;

START TRANSACTION;
  CALL sp_registrar_venta('F001-0003', 5, @v3);
  CALL sp_agregar_detalle(@v3, 8, 2);   -- 2 SSD Kingston
  CALL sp_agregar_detalle(@v3, 10, 2);  -- 2 RAM Kingston
COMMIT;

UPDATE venta SET estado = 'PAGADA' WHERE numero_comprobante IN ('F001-0001', 'F001-0003');
