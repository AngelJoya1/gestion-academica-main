"""DCL (Data Control Language) — equivalente a sql/mariadb/Ejemplos SQL/05_DCL.sql.

CREATE USER / GRANT / REVOKE / SHOW GRANTS / DROP USER. Requiere una cuenta
administrativa (por defecto root de XAMPP). Es repetible: CREATE USER usa IF NOT EXISTS
y DROP USER usa IF EXISTS.

Igual que el .sql, al final elimina los dos usuarios de ejemplo.

Las contraseñas se pueden cambiar con las variables de entorno
GESTION_ACADEMICA_PASS_SECRETARIA y GESTION_ACADEMICA_PASS_DOCENTE; los valores por
defecto son los mismos del .sql.
"""

import os

from conexion import conexion, consultar, ejecutar

BD = "gestion_academica"
CLAVES = {
    "secretaria": os.getenv("GESTION_ACADEMICA_PASS_SECRETARIA", "Clave123*"),
    "docente": os.getenv("GESTION_ACADEMICA_PASS_DOCENTE", "Clave456*"),
}


def main():
    with conexion() as con:
        # CREATE USER: cuentas que sólo se conectan desde el mismo equipo (localhost).
        # La contraseña va como parámetro; los nombres de usuario son fijos (definidos arriba).
        for usuario, clave in CLAVES.items():
            ejecutar(con, f"CREATE USER IF NOT EXISTS '{usuario}'@'localhost' IDENTIFIED BY %s", (clave,))
            print(f"CREATE USER: '{usuario}'@'localhost'")

        # GRANT: la secretaria consulta, inserta y actualiza estudiantes y matrículas.
        for tabla in ("estudiante", "matricula"):
            ejecutar(con, f"GRANT SELECT, INSERT, UPDATE ON `{BD}`.`{tabla}` TO 'secretaria'@'localhost'")
        # GRANT: el docente sólo lee todo y puede modificar únicamente nota_final y estado (por columna).
        ejecutar(con, f"GRANT SELECT ON `{BD}`.* TO 'docente'@'localhost'")
        ejecutar(con, f"GRANT UPDATE (`nota_final`, `estado`) ON `{BD}`.`registro_academico` TO 'docente'@'localhost'")

        # REVOKE: la secretaria deja de poder actualizar estudiantes.
        ejecutar(con, f"REVOKE UPDATE ON `{BD}`.`estudiante` FROM 'secretaria'@'localhost'")
        ejecutar(con, "FLUSH PRIVILEGES")

        # SHOW GRANTS: comprobar que los permisos quedaron como se esperaba.
        for usuario in CLAVES:
            print(f"\n== Privilegios de {usuario} ==")
            for fila in consultar(con, f"SHOW GRANTS FOR '{usuario}'@'localhost'"):
                print(next(iter(fila.values())))

        # DROP USER: elimina los usuarios de ejemplo.
        for usuario in CLAVES:
            ejecutar(con, f"DROP USER IF EXISTS '{usuario}'@'localhost'")
            print(f"DROP USER: '{usuario}'@'localhost'")


if __name__ == "__main__":
    main()
