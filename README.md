# Sistema para Venta de Computadoras – Diseño de Base de Datos

## Descripción técnica
Base de datos relacional para un sistema de venta de computadoras y accesorios. Gestiona el **catálogo de productos**
(con categoría, marca y proveedor), los **clientes** y el **proceso de venta** con facturación (cabecera + detalle,
cálculo de IGV al 18 %, control de stock y anulación de ventas).

- **Motor:** MySQL 8.x (compatible con MariaDB 10.5+)
- **Modelo:** 7 tablas en 3ª Forma Normal, con llaves primarias, foráneas, `UNIQUE` y `CHECK`
- **Lógica de negocio:** 3 procedimientos almacenados (`sp_registrar_venta`, `sp_agregar_detalle`, `sp_anular_venta`)
- **Rutas:** documentación de 24 endpoints REST mapeados a consultas SQL
- **Extra:** versión equivalente en MongoDB (carpeta `mongodb/`)

## Datos de identificación
| | |
|---|---|
| **Estudiante** | [NOMBRE COMPLETO] |
| **Carrera** | [CARRERA] |
| **Asignatura** | [ASIGNATURA] |
| **Proyecto** | Base de Datos – Venta de Computadoras |

## Estructura del repositorio
```
venta-computadoras/
├── README.md
├── .gitignore
├── docs/
│   ├── diagrama_ER.md            Diagrama Entidad-Relación (Mermaid)
│   ├── modelo_relacional.md      Modelo relacional y restricciones
│   └── diccionario_datos.md      Diccionario de datos
├── database/
│   ├── 01_ddl.sql                Creación de BD, tablas, PK, FK y restricciones
│   ├── 02_procedimientos.sql     Procedimientos almacenados del proceso de venta
│   ├── 03_dml.sql                Datos de prueba
│   └── 04_consultas.sql          Consultas clave (una por ruta)
├── routes/
│   └── rutas.md                  Endpoints de la API y su operación en la BD
└── mongodb/                      Versión NoSQL (práctica complementaria)
```

## Diagrama Entidad-Relación
Ver [`docs/diagrama_ER.md`](docs/diagrama_ER.md). Resumen:

```
CATEGORIA ─┐
MARCA ─────┼──< PRODUCTO >──< DETALLE_VENTA >── VENTA >── CLIENTE
PROVEEDOR ─┘
```

## Ejecución del script de la base de datos

### Requisitos
- MySQL 8.x o MariaDB 10.5+ instalado y en ejecución

### Opción 1: línea de comandos
Desde la carpeta `database/`, ejecutar **en este orden**:

```bash
mysql -u root -p < 01_ddl.sql
mysql -u root -p < 02_procedimientos.sql
mysql -u root -p < 03_dml.sql
mysql -u root -p < 04_consultas.sql      # opcional: muestra los resultados
```

### Opción 2: MySQL Workbench
1. Abrir **File → Open SQL Script** y cargar `01_ddl.sql`; ejecutar con el rayo ⚡.
2. Repetir con `02_procedimientos.sql`, `03_dml.sql` y `04_consultas.sql`.

> `01_ddl.sql` elimina y vuelve a crear la base `venta_computadoras`, por lo que se puede reejecutar para reiniciar los datos.

### Verificación
Después de ejecutar `03_dml.sql`:
```sql
USE venta_computadoras;
SELECT numero_comprobante, subtotal, igv, total, estado FROM venta;
```
Resultado esperado:

| numero_comprobante | subtotal | igv | total | estado |
|---|---|---|---|---|
| F001-0001 | 5780.00 | 1040.40 | 6820.40 | PAGADA |
| F001-0002 | 5030.00 | 905.40 | 5935.40 | PENDIENTE |
| F001-0003 | 1120.00 | 201.60 | 1321.60 | PAGADA |

## Proceso de venta
```sql
START TRANSACTION;
  CALL sp_registrar_venta('F001-0004', 3, @id_venta);
  CALL sp_agregar_detalle(@id_venta, 3, 1);   -- valida stock, descuenta y recalcula totales
  CALL sp_agregar_detalle(@id_venta, 6, 2);
COMMIT;

CALL sp_anular_venta(2);                      -- anula y devuelve el stock
```

## Rutas principales
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/productos` | Catálogo de productos |
| GET | `/api/clientes/:id/ventas` | Historial de compras del cliente |
| POST | `/api/ventas` | Registrar una venta con sus ítems |
| GET | `/api/ventas/:id` | Factura completa |
| PATCH | `/api/ventas/:id/anular` | Anular venta y reponer stock |
| GET | `/api/reportes/mas-vendidos` | Productos más vendidos |

Documentación completa: [`routes/rutas.md`](routes/rutas.md).

## Documentación
- [Diagrama Entidad-Relación](docs/diagrama_ER.md)
- [Modelo relacional](docs/modelo_relacional.md)
- [Diccionario de datos](docs/diccionario_datos.md)
- [Rutas / Endpoints](routes/rutas.md)
