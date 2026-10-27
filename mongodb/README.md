# Versión MongoDB (práctica complementaria)

Implementación NoSQL del mismo caso (colecciones `empresas`, `productos`, `facturas`), siguiendo los ejemplos de clase:
`insertMany`, `find` con operadores, `updateOne/updateMany/replaceOne`, `deleteOne/deleteMany` y `aggregate` con `$addFields`.

```bash
mongosh mongodb://localhost:27017
```
```js
load("scripts/01_insertar.js")
load("scripts/02_consultas.js")
load("scripts/03_actualizar.js")
load("scripts/04_eliminar.js")
```
Ejecutar `mongosh` desde esta carpeta (`mongodb/`).
