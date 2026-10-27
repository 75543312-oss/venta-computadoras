// 02_consultas.js
// Búsquedas con find y operadores de comparación.
// Uso en mongosh:  load("scripts/02_consultas.js")

db = db.getSiblingDB("tienda");

print("\n--- Todos los productos ---");
printjson(db.productos.find().toArray());

print("\n--- Productos de la marca Logitech ---");
printjson(db.productos.find({ marca: "Logitech" }).toArray());

print("\n--- Precio mayor a 500 ($gt) ---");
printjson(db.productos.find({ precio: { $gt: 500 } }).toArray());

print("\n--- Precio entre 100 y 700 ($gte y $lte) ---");
printjson(db.productos.find({ precio: { $gte: 100, $lte: 700 } }).toArray());

print("\n--- Categoría laptops o monitores ($in) ---");
printjson(db.productos.find({ categoria: { $in: ["laptops", "monitores"] } }).toArray());

print("\n--- Marca que empieza con 'L' ($regex) ---");
printjson(db.productos.find({ marca: { $regex: /^L/ } }).toArray());

print("\n--- Todo menos accesorios ($ne) ---");
printjson(db.productos.find({ categoria: { $ne: "accesorios" } }).toArray());

// ---------- Seguir la relación factura -> empresa -> productos ----------
print("\n--- Factura F001-0001 con su empresa y productos ---");
const factura = db.facturas.findOne({ numero: "F001-0001" });
printjson(factura);

const empresa = db.empresas.findOne({ _id: factura.empresa_id });
print("Empresa:");
printjson(empresa);

const idsProductos = factura.items.map(i => i.producto_id);
print("Productos vendidos:");
printjson(db.productos.find({ _id: { $in: idsProductos } }).toArray());

// ---------- Agregar un campo calculado con aggregate ($addFields) ----------
print("\n--- Facturas con IGV (18%) calculado ---");
printjson(
  db.facturas.aggregate([
    { $addFields: { igv: { $multiply: ["$total", 0.18] } } }
  ]).toArray()
);
