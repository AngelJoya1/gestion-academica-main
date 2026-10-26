"""Conexión alternativa con el conector oficial de MariaDB (paquete `mariadb`).

Requiere:  pip install mariadb   (necesita MariaDB Connector/C instalado en el sistema)
El resto de scripts del proyecto usa PyMySQL (conexion.py), que no necesita nada extra.
"""

import sys
import mariadb

try:
    # Establecer la conexión con la base de datos
    conexion = mariadb.connect(
        user="root",
        password="",
        host="127.0.0.1",
        port=3306,
        database="gestion_academica"
    )
except mariadb.Error as e:
    print(f"Error al conectar a MariaDB: {e}")
    sys.exit(1)

# Crear un cursor para ejecutar sentencias SQL
cursor = conexion.cursor()

# Ejecutar una consulta de ejemplo
cursor.execute("SELECT id_facultad, nombre_facultad, decano FROM facultad")

# Recorrer los resultados
for (id_facultad, nombre_facultad, decano) in cursor:
    print(f"ID: {id_facultad}, Facultad: {nombre_facultad}, Decano: {decano}")

# Cerrar cursor y conexión
cursor.close()
conexion.close()
