"""TCL (Transaction Control Language) — equivalente a sql/mariadb/Ejemplos SQL/06_TCL.sql.

START TRANSACTION + SAVEPOINT + ROLLBACK TO SAVEPOINT + COMMIT:
  1. Matricula a Marta en Cálculo Diferencial y descuenta un cupo.
  2. SAVEPOINT matricula_marta.
  3. Matricula a Luis y descuenta otro cupo (supuesto error).
  4. ROLLBACK TO matricula_marta: se deshace lo de Luis, se conserva lo de Marta.
  5. COMMIT.

Es repetible: si Marta ya está matriculada en ese grupo no se vuelve a insertar.
Requiere gestion_academica_insert.sql y dml.py (crea el grupo de Cálculo Diferencial).
"""


from conexion import conexion, consultar, ejecutar, imprimir

CORREO_MARTA = "marta.rojas@uni.edu"
CORREO_LUIS = "luis.perez@uni.edu"
CURSO = "Cálculo Diferencial"
HORARIO = "Jue 08:00-10:00"
FECHA = "2026-01-23"


def _uno(con, sql, params):
    filas = consultar(con, sql, params)
    return filas[0]["id"] if filas else None


def _matriculado(con, id_estudiante, id_grupo):
    return bool(consultar(
        con,
        "SELECT 1 AS existe FROM `matricula` WHERE `id_estudiante` = %s AND `id_grupo` = %s",
        (id_estudiante, id_grupo)))


def _cupo(con, id_grupo):
    return consultar(con, "SELECT `cupo_disponible` FROM `grupo` WHERE `id_grupo` = %s", (id_grupo,))[0]["cupo_disponible"]


def _matricular_y_descontar(con, id_estudiante, id_grupo):
    """INSERT de la matrícula + descuento de un cupo. Devuelve False si no había cupo."""
    ejecutar(
        con,
        "INSERT INTO `matricula` (`id_estudiante`, `id_grupo`, `fecha_matricula`) VALUES (%s, %s, %s)",
        (id_estudiante, id_grupo, FECHA))
    # cupo_disponible > 0 evita que el cupo quede negativo.
    return ejecutar(
        con,
        "UPDATE `grupo` SET `cupo_disponible` = `cupo_disponible` - 1 WHERE `id_grupo` = %s AND `cupo_disponible` > 0",
        (id_grupo,)) == 1


def main():
    with conexion() as con:
        marta = _uno(con, "SELECT `id_estudiante` AS id FROM `estudiante` WHERE `correo` = %s", (CORREO_MARTA,))
        luis = _uno(con, "SELECT `id_estudiante` AS id FROM `estudiante` WHERE `correo` = %s", (CORREO_LUIS,))
        grupo = _uno(
            con,
            """SELECT g.`id_grupo` AS id FROM `grupo` g INNER JOIN `curso` c ON c.`id_curso` = g.`id_curso`
               WHERE c.`nombre_curso` = %s AND g.`horario` = %s""", (CURSO, HORARIO))
        if None in (marta, luis, grupo):
            raise SystemExit("Faltan datos de ejemplo: ejecuta gestion_academica_insert.sql y dml.py primero.")

        # START TRANSACTION: desde aquí los cambios son provisionales.
        con.begin()

        # 1) Marta en el grupo de Cálculo Diferencial.
        if _matriculado(con, marta, grupo):
            print("Marta ya está matriculada en ese grupo; no se inserta de nuevo.")
        elif not _matricular_y_descontar(con, marta, grupo):
            con.rollback()
            raise SystemExit("El grupo no tiene cupos disponibles; transacción deshecha.")
        else:
            print("Marta matriculada y cupo descontado (provisional).")

        # 2) SAVEPOINT: punto de control al que se puede volver sin deshacer todo.
        ejecutar(con, "SAVEPOINT matricula_marta")

        # 3) Luis en el mismo grupo (supuesto error).
        if _matriculado(con, luis, grupo):
            print("Luis ya estaba matriculado en ese grupo; se omite la parte del error.")
        else:
            _matricular_y_descontar(con, luis, grupo)
            print(f"Luis matriculado (provisional). Cupo dentro de la transacción: {_cupo(con, grupo)}")

            # 4) ROLLBACK TO SAVEPOINT: desaparece lo de Luis, se conserva lo de Marta.
            ejecutar(con, "ROLLBACK TO SAVEPOINT matricula_marta")
            print(f"ROLLBACK TO matricula_marta. Cupo tras el rollback parcial: {_cupo(con, grupo)}")

        # 5) COMMIT guarda lo que quedó (con ROLLBACK en su lugar se deshace toda la transacción).
        con.commit()
        print("COMMIT: cambios guardados.")

        imprimir(
            "Matrículas del grupo",
            consultar(
                con,
                """SELECT e.`nombre`, e.`apellido`, m.`estado`, m.`fecha_matricula`
                   FROM `matricula` m INNER JOIN `estudiante` e ON e.`id_estudiante` = m.`id_estudiante`
                   WHERE m.`id_grupo` = %s ORDER BY m.`id_matricula`""", (grupo,)))
        imprimir("Cupo del grupo", [{"id_grupo": grupo, "cupo_disponible": _cupo(con, grupo)}])


if __name__ == "__main__":
    main()
