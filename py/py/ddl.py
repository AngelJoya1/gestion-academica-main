"""DDL (Data Definition Language) — equivalente a sql/mariadb/Ejemplos SQL/01_DDL.sql.

CREATE / ALTER (agregar y modificar columnas) / CREATE INDEX / DROP.
Idempotente: todo usa IF [NOT] EXISTS, se puede ejecutar varias veces.
Requiere haber ejecutado antes sql/mariadb/gestion_academica.sql.
"""

from conexion import conexion, consultar, ejecutar, imprimir

# CREATE + ALTER + CREATE INDEX (todo lo que deja algo para mostrar antes del DROP).
SENTENCIAS = [
    # CREATE: tabla de prueba para demostrar CREATE TABLE.
    # (el CHECK se llama chk_prueba_semestre para no repetir el nombre del CHECK de `estudiante`)
    """CREATE TABLE IF NOT EXISTS `tabla_estudiantes_prueba` (
        `nombre`             VARCHAR(60)  NOT NULL,
        `apellido`           VARCHAR(60)  NOT NULL,
        `id_estudiante`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `programa_academico` VARCHAR(100) NOT NULL,
        `semestre_actual`    TINYINT UNSIGNED NOT NULL,
        PRIMARY KEY (`id_estudiante`),
        CONSTRAINT `chk_prueba_semestre` CHECK (`semestre_actual` BETWEEN 1 AND 12)
    )""",
    # ALTER: teléfono opcional del estudiante.
    "ALTER TABLE `tabla_estudiantes_prueba` ADD COLUMN IF NOT EXISTS `telefono` VARCHAR(20) NULL",
    # ALTER: correo del estudiante.
    "ALTER TABLE `tabla_estudiantes_prueba` ADD COLUMN IF NOT EXISTS `correo` VARCHAR(120) NOT NULL",
    # ALTER: amplía el apellido de 60 a 80 caracteres.
    "ALTER TABLE `tabla_estudiantes_prueba` MODIFY `apellido` VARCHAR(80) NOT NULL",
    # CREATE INDEX: acelera las búsquedas por programa académico.
    "CREATE INDEX IF NOT EXISTS `idx_estudiante_programa` ON `estudiante` (`programa_academico`)",
]

# DROP: elimina la tabla de prueba, que no forma parte del modelo final.
ELIMINAR = "DROP TABLE IF EXISTS `tabla_estudiantes_prueba`"


def main():
    with conexion() as con:
        for sql in SENTENCIAS:
            ejecutar(con, sql)
            print("OK:", " ".join(sql.split())[:90])

        imprimir("Estructura de tabla_estudiantes_prueba", consultar(con, "SHOW COLUMNS FROM `tabla_estudiantes_prueba`"))
        imprimir(
            "Índice creado en estudiante",
            consultar(con, "SHOW INDEX FROM `estudiante` WHERE Key_name = 'idx_estudiante_programa'"),
        )

        ejecutar(con, ELIMINAR)
        print("OK:", ELIMINAR)
        con.commit()


if __name__ == "__main__":
    main()
