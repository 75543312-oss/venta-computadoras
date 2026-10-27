// 04_eliminar.js
// Eliminación con deleteOne, deleteMany y dropDatabase.
// Uso en mongosh:  load("scripts/04_eliminar.js")

db = db.getSiblingDB("tienda");

// Ejemplo 1: deleteOne - borrar un producto
db.productos.deleteOne({ nombre: "Disco SSD 1TB" });

// Ejemplo 2: deleteMany - borrar todos los productos de una categoría
db.productos.deleteMany({ categoria: "monitores" });

print("Productos restantes: " + db.productos.countDocuments());

// Ejemplo 3: borrar TODA la base de datos (descomentar solo si se quiere reiniciar)
// db.dropDatabase();
