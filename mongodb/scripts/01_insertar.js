// 01_insertar.js
// Crea la base de datos "tienda" y registra empresas, productos y una factura.
// Uso en mongosh:  load("scripts/01_insertar.js")

db = db.getSiblingDB("tienda");

// Limpiar para poder ejecutar el script varias veces
db.empresas.deleteMany({});
db.productos.deleteMany({});
db.facturas.deleteMany({});

// ---------- EMPRESAS (clientes a quienes se factura) ----------
const empresas = db.empresas.insertMany([
  {
    nombre: "Tech Solutions SAC",
    ruc: "20123456789",
    direccion: "Av. Tecnología 123, Huancayo",
    telefono: "064-123456"
  },
  {
    nombre: "Consultoría Global EIRL",
    ruc: "20987654321",
    direccion: "Calle Consultores 456, Lima",
    telefono: "01-9876543"
  }
]);

// ---------- PRODUCTOS (solo los campos necesarios) ----------
const productos = db.productos.insertMany([
  { nombre: "Laptop Pro 15",        precio: 3200, marca: "Lenovo",   categoria: "laptops" },
  { nombre: "Laptop Gamer X",       precio: 4500, marca: "Asus",     categoria: "laptops" },
  { nombre: "Monitor 24 pulgadas",  precio: 650,  marca: "Samsung",  categoria: "monitores" },
  { nombre: "Teclado Mecánico",     precio: 180,  marca: "Logitech", categoria: "accesorios" },
  { nombre: "Mouse Inalámbrico",    precio: 90,   marca: "Logitech", categoria: "accesorios" },
  { nombre: "Disco SSD 1TB",        precio: 320,  marca: "Kingston", categoria: "almacenamiento" }
]);

// ---------- FACTURA / VENTA (relaciona empresa + productos) ----------
// empresa_id y producto_id guardan el _id del otro documento (la relación).
// nombre y precio se copian en cada ítem para conservar el precio del día de la venta.
const idEmpresa = empresas.insertedIds[0];

const items = [
  { producto_id: productos.insertedIds[0], nombre: "Laptop Pro 15",  precio: 3200, cantidad: 2 },
  { producto_id: productos.insertedIds[4], nombre: "Mouse Inalámbrico", precio: 90, cantidad: 2 }
];

const total = items.reduce((suma, i) => suma + i.precio * i.cantidad, 0);

db.facturas.insertOne({
  numero: "F001-0001",
  fecha: new Date(),
  empresa_id: idEmpresa,
  items: items,
  total: total
});

print("Datos insertados en la base 'tienda'.");
print("Empresas: " + db.empresas.countDocuments());
print("Productos: " + db.productos.countDocuments());
print("Facturas: " + db.facturas.countDocuments());
