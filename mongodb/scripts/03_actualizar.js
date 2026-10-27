// 03_actualizar.js
// Actualizaciones con updateOne, updateMany y replaceOne.
// Uso en mongosh:  load("scripts/03_actualizar.js")

db = db.getSiblingDB("tienda");

// Ejemplo 1: updateOne - cambiar el precio de un producto
db.productos.updateOne(
  { nombre: "Teclado Mecánico" },
  { $set: { precio: 199 }, $currentDate: { lastModified: true } }
);

// Ejemplo 2: updateMany - marcar todos los accesorios como revisados
db.productos.updateMany(
  { categoria: "accesorios" },
  { $set: { marca_revisada: true }, $currentDate: { lastModified: true } }
);

// Ejemplo 3: replaceOne - reemplazar los datos de una empresa
db.empresas.replaceOne(
  { ruc: "20987654321" },
  {
    nombre: "Consultoría Global EIRL",
    ruc: "20987654321",
    direccion: "Av. Nueva 789, Lima",
    telefono: "01-5551234"
  }
);

print("Actualizaciones aplicadas.");
printjson(db.productos.find({ categoria: "accesorios" }).toArray());
