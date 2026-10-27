# Diagrama Entidad-Relación (DER)

> El diagrama está en formato Mermaid: GitHub lo dibuja automáticamente al abrir este archivo.

```mermaid
erDiagram
    CATEGORIA ||--o{ PRODUCTO : clasifica
    MARCA ||--o{ PRODUCTO : identifica
    PROVEEDOR ||--o{ PRODUCTO : suministra
    CLIENTE ||--o{ VENTA : realiza
    VENTA ||--|{ DETALLE_VENTA : contiene
    PRODUCTO ||--o{ DETALLE_VENTA : "se vende en"

    CATEGORIA {
        int id_categoria PK
        varchar nombre UK
    }
    MARCA {
        int id_marca PK
        varchar nombre UK
    }
    PROVEEDOR {
        int id_proveedor PK
        varchar razon_social
        char ruc UK
        varchar telefono
        varchar email
        varchar direccion
    }
    PRODUCTO {
        int id_producto PK
        varchar codigo UK
        varchar nombre
        varchar descripcion
        decimal precio
        int stock
        int id_categoria FK
        int id_marca FK
        int id_proveedor FK
    }
    CLIENTE {
        int id_cliente PK
        varchar nombres
        varchar apellidos
        enum tipo_documento
        varchar numero_documento
        varchar telefono
        varchar email
        varchar direccion
    }
    VENTA {
        int id_venta PK
        varchar numero_comprobante UK
        datetime fecha
        int id_cliente FK
        decimal subtotal
        decimal igv
        decimal total
        enum estado
    }
    DETALLE_VENTA {
        int id_detalle PK
        int id_venta FK
        int id_producto FK
        int cantidad
        decimal precio_unitario
        decimal subtotal
    }
```

## Cardinalidades

| Relación | Cardinalidad | Explicación |
|----------|--------------|-------------|
| Categoría – Producto | 1 : N | Una categoría agrupa muchos productos; un producto tiene una sola categoría |
| Marca – Producto | 1 : N | Una marca tiene muchos productos |
| Proveedor – Producto | 1 : N | Un proveedor suministra muchos productos |
| Cliente – Venta | 1 : N | Un cliente puede hacer muchas compras; cada venta es de un solo cliente |
| Venta – Detalle de venta | 1 : N | Una venta tiene al menos un ítem |
| Producto – Detalle de venta | 1 : N | Un producto puede aparecer en muchos detalles |
| Venta – Producto (resultante) | N : M | Resuelta con la tabla `detalle_venta` |
