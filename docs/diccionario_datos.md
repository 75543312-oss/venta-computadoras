# Diccionario de Datos

Base de datos: `venta_computadoras` (MySQL 8.x, `utf8mb4`)

## categoria
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_categoria | INT AUTO_INCREMENT | No | PK | Identificador de la categoría |
| nombre | VARCHAR(50) | No | UK | Nombre (Laptops, Monitores, Accesorios…) |

## marca
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_marca | INT AUTO_INCREMENT | No | PK | Identificador de la marca |
| nombre | VARCHAR(50) | No | UK | Nombre de la marca (Lenovo, HP, Asus…) |

## proveedor
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_proveedor | INT AUTO_INCREMENT | No | PK | Identificador del proveedor |
| razon_social | VARCHAR(100) | No | | Razón social |
| ruc | CHAR(11) | No | UK | RUC del proveedor |
| telefono | VARCHAR(20) | Sí | | Teléfono de contacto |
| email | VARCHAR(100) | Sí | | Correo electrónico |
| direccion | VARCHAR(150) | Sí | | Dirección |

## producto (computadoras, monitores, accesorios, componentes)
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_producto | INT AUTO_INCREMENT | No | PK | Identificador del producto |
| codigo | VARCHAR(20) | No | UK | Código interno (ej. `LEN-LP-001`) |
| nombre | VARCHAR(100) | No | | Nombre comercial |
| descripcion | VARCHAR(255) | Sí | | Especificaciones breves |
| precio | DECIMAL(10,2) | No | | Precio unitario. Debe ser > 0 |
| stock | INT | No | | Unidades disponibles. Debe ser ≥ 0 (por defecto 0) |
| id_categoria | INT | No | FK | → categoria.id_categoria |
| id_marca | INT | No | FK | → marca.id_marca |
| id_proveedor | INT | No | FK | → proveedor.id_proveedor |

## cliente
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_cliente | INT AUTO_INCREMENT | No | PK | Identificador del cliente |
| nombres | VARCHAR(80) | No | | Nombres (o razón social si es empresa) |
| apellidos | VARCHAR(80) | No | | Apellidos |
| tipo_documento | ENUM('DNI','RUC','CE') | No | UK* | Tipo de documento (por defecto DNI) |
| numero_documento | VARCHAR(15) | No | UK* | Número de documento |
| telefono | VARCHAR(20) | Sí | | Teléfono |
| email | VARCHAR(100) | Sí | | Correo electrónico |
| direccion | VARCHAR(150) | Sí | | Dirección |

\* La unicidad es sobre el par (`tipo_documento`, `numero_documento`).

## venta
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_venta | INT AUTO_INCREMENT | No | PK | Identificador de la venta |
| numero_comprobante | VARCHAR(20) | No | UK | Número de factura (ej. `F001-0001`) |
| fecha | DATETIME | No | | Fecha y hora (por defecto, la actual) |
| id_cliente | INT | No | FK | → cliente.id_cliente |
| subtotal | DECIMAL(12,2) | No | | Suma de los subtotales del detalle |
| igv | DECIMAL(12,2) | No | | 18 % del subtotal |
| total | DECIMAL(12,2) | No | | subtotal + igv |
| estado | ENUM('PENDIENTE','PAGADA','ANULADA') | No | | Estado de la venta (por defecto PENDIENTE) |

## detalle_venta
| Campo | Tipo | Nulo | Clave | Descripción |
|-------|------|------|-------|-------------|
| id_detalle | INT AUTO_INCREMENT | No | PK | Identificador del detalle |
| id_venta | INT | No | FK | → venta.id_venta (se borra en cascada) |
| id_producto | INT | No | FK | → producto.id_producto |
| cantidad | INT | No | | Unidades vendidas. Debe ser > 0 |
| precio_unitario | DECIMAL(10,2) | No | | Precio del producto al momento de la venta |
| subtotal | DECIMAL(12,2) | No | | cantidad × precio_unitario |

## Procedimientos almacenados
| Nombre | Parámetros | Función |
|--------|-----------|---------|
| `sp_registrar_venta` | `p_numero_comprobante`, `p_id_cliente`, `OUT p_id_venta` | Crea la cabecera de la venta |
| `sp_agregar_detalle` | `p_id_venta`, `p_id_producto`, `p_cantidad` | Valida stock, registra el ítem con el precio vigente, descuenta stock y recalcula subtotal, IGV y total |
| `sp_anular_venta` | `p_id_venta` | Marca la venta como ANULADA y devuelve el stock |
