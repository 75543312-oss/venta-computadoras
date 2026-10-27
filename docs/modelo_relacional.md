# Modelo Relacional

Notación: **PK** = llave primaria (subrayada conceptualmente), *FK* = llave foránea, `UK` = único.

```
CATEGORIA     (PK id_categoria, nombre UK)

MARCA         (PK id_marca, nombre UK)

PROVEEDOR     (PK id_proveedor, razon_social, ruc UK, telefono, email, direccion)

PRODUCTO      (PK id_producto, codigo UK, nombre, descripcion, precio, stock,
               FK id_categoria  -> CATEGORIA(id_categoria),
               FK id_marca      -> MARCA(id_marca),
               FK id_proveedor  -> PROVEEDOR(id_proveedor))

CLIENTE       (PK id_cliente, nombres, apellidos, tipo_documento,
               numero_documento, telefono, email, direccion,
               UK (tipo_documento, numero_documento))

VENTA         (PK id_venta, numero_comprobante UK, fecha, subtotal, igv, total, estado,
               FK id_cliente -> CLIENTE(id_cliente))

DETALLE_VENTA (PK id_detalle, cantidad, precio_unitario, subtotal,
               FK id_venta    -> VENTA(id_venta)       ON DELETE CASCADE,
               FK id_producto -> PRODUCTO(id_producto),
               UK (id_venta, id_producto))
```

## Restricciones de integridad

| Tabla | Restricción | Regla |
|-------|-------------|-------|
| producto | `ck_producto_precio` | `precio > 0` |
| producto | `ck_producto_stock` | `stock >= 0` |
| venta | `ck_venta_montos` | `subtotal`, `igv` y `total` ≥ 0 |
| detalle_venta | `ck_detalle_cantidad` | `cantidad > 0` |
| detalle_venta | `ck_detalle_precio` | `precio_unitario > 0` |
| detalle_venta | `uq_detalle_venta_producto` | un producto no se repite dentro de la misma venta |
| cliente | `uq_cliente_documento` | no se repite (tipo, número de documento) |
| Todas las FK | `ON DELETE RESTRICT` | no se puede borrar un registro que otro usa (excepto detalle al borrar su venta) |

## Normalización
El modelo cumple la **3FN**: cada atributo depende de la llave primaria, sin dependencias transitivas.
Se guardan `precio_unitario` y `subtotal` en `detalle_venta` a propósito: conservan el precio vigente
el día de la venta aunque luego cambie el precio del producto.
