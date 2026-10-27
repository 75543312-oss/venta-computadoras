# Rutas / Endpoints de la Base de Datos

Mapeo de las rutas de la API REST hacia las operaciones SQL.
Prefijo base: `/api`. Formato de intercambio: JSON.
Las consultas `Q1…Q9` están en [`database/04_consultas.sql`](../database/04_consultas.sql) y los procedimientos en [`database/02_procedimientos.sql`](../database/02_procedimientos.sql).

## Productos
| Método | Ruta | Descripción | Operación en la BD |
|--------|------|-------------|--------------------|
| GET | `/api/productos` | Lista el catálogo | Q1 |
| GET | `/api/productos?categoria=1&min=1000&max=4000` | Filtra por categoría y rango de precio | Q2 |
| GET | `/api/productos/stock-bajo` | Productos con stock < 10 | Q3 |
| GET | `/api/productos/:id` | Detalle de un producto | `SELECT … FROM producto WHERE id_producto = ?` |
| POST | `/api/productos` | Crea un producto | `INSERT INTO producto (...) VALUES (...)` |
| PUT | `/api/productos/:id` | Actualiza un producto | `UPDATE producto SET ... WHERE id_producto = ?` |
| DELETE | `/api/productos/:id` | Elimina un producto (falla si ya fue vendido) | `DELETE FROM producto WHERE id_producto = ?` |

## Clientes
| Método | Ruta | Descripción | Operación en la BD |
|--------|------|-------------|--------------------|
| GET | `/api/clientes` | Lista de clientes | `SELECT * FROM cliente` |
| GET | `/api/clientes/:id` | Datos de un cliente | `SELECT * FROM cliente WHERE id_cliente = ?` |
| GET | `/api/clientes/:id/ventas` | Historial de compras | Q6 |
| POST | `/api/clientes` | Registra un cliente | `INSERT INTO cliente (...) VALUES (...)` |
| PUT | `/api/clientes/:id` | Actualiza un cliente | `UPDATE cliente SET ... WHERE id_cliente = ?` |

## Catálogos y proveedores
| Método | Ruta | Descripción | Operación en la BD |
|--------|------|-------------|--------------------|
| GET | `/api/categorias` | Lista de categorías | `SELECT * FROM categoria` |
| GET | `/api/marcas` | Lista de marcas | `SELECT * FROM marca` |
| GET | `/api/proveedores` | Lista de proveedores | `SELECT * FROM proveedor` |
| POST | `/api/proveedores` | Registra un proveedor | `INSERT INTO proveedor (...) VALUES (...)` |

## Ventas (proceso principal)
| Método | Ruta | Descripción | Operación en la BD |
|--------|------|-------------|--------------------|
| GET | `/api/ventas` | Lista de ventas | `SELECT … FROM venta ORDER BY fecha DESC` |
| GET | `/api/ventas/:id` | Factura completa (cabecera + detalle) | Q4 + Q5 |
| POST | `/api/ventas` | Registra una venta con sus ítems | Transacción con `sp_registrar_venta` + `sp_agregar_detalle` |
| PATCH | `/api/ventas/:id/pagar` | Marca la venta como pagada | `UPDATE venta SET estado='PAGADA' WHERE id_venta = ?` |
| PATCH | `/api/ventas/:id/anular` | Anula la venta y repone stock | `CALL sp_anular_venta(?)` |

### Ejemplo: `POST /api/ventas`
**Petición**
```json
{
  "numero_comprobante": "F001-0004",
  "id_cliente": 3,
  "items": [
    { "id_producto": 3, "cantidad": 1 },
    { "id_producto": 6, "cantidad": 2 }
  ]
}
```

**Operación en la BD (una sola transacción)**
```sql
START TRANSACTION;
  CALL sp_registrar_venta('F001-0004', 3, @id_venta);
  CALL sp_agregar_detalle(@id_venta, 3, 1);
  CALL sp_agregar_detalle(@id_venta, 6, 2);
COMMIT;            -- ante cualquier error del servidor: ROLLBACK
```

**Respuesta `201 Created`**
```json
{
  "id_venta": 4,
  "numero_comprobante": "F001-0004",
  "subtotal": 3460.00,
  "igv": 622.80,
  "total": 4082.80,
  "estado": "PENDIENTE"
}
```

**Errores posibles**
| Código | Causa | Mensaje de la BD |
|--------|-------|------------------|
| 409 | Stock insuficiente | `Stock insuficiente` |
| 404 | Producto o venta inexistente | `El producto no existe` / `La venta no existe` |
| 409 | Comprobante duplicado | violación de `uq_venta_comprobante` |
| 422 | Cantidad inválida | `La cantidad debe ser mayor a 0` |

## Reportes
| Método | Ruta | Descripción | Operación en la BD |
|--------|------|-------------|--------------------|
| GET | `/api/reportes/mas-vendidos` | Top 5 de productos más vendidos | Q7 |
| GET | `/api/reportes/ventas-mensuales` | Total vendido por mes | Q8 |
| GET | `/api/reportes/ventas-por-categoria` | Ingresos por categoría | Q9 |

## Flujo del proceso de venta
```
Cliente elige productos
        │
        ▼
POST /api/ventas ──► sp_registrar_venta ──► sp_agregar_detalle (por cada ítem)
        │                                      ├─ valida stock
        │                                      ├─ toma precio vigente
        │                                      ├─ descuenta stock
        │                                      └─ recalcula subtotal / IGV / total
        ▼
PATCH /api/ventas/:id/pagar     (estado = PAGADA)
        │
        └─ si se cancela ► PATCH /api/ventas/:id/anular ► sp_anular_venta (repone stock)
```
