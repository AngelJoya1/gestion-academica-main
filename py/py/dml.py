"""DML (Data Manipulation Language) — equivalente a sql/mariadb/Ejemplos SQL/02_DML.sql.

INSERT (facultades, estudiantes, cursos, prerrequisitos, grupos, matrículas, registros),
UPDATE (estado de una matrícula y cupos disponibles) y DELETE (una matrícula).

Diferencia con el .sql: el .sql usa ids fijos (id_curso = 1, id_grupo = 2...) que sólo
coinciden en una base vacía. Aquí todo se localiza por llave natural (correo, nombre del
curso, horario del grupo), así funciona sobre gestion_academica_insert.sql y es repetible
(INSERT IGNORE + comprobación previa en grupo). Las sentencias llevan parámetros (%s).

Requiere gestion_academica.sql y gestion_academica_insert.sql (y ddl.py por orden del guion).
"""

from conexion import conexion, consultar, ejecutar, imprimir

FACULTADES = [
    ("Ingeniería", "Carlos Ramírez"),
    ("Ciencias Económicas", "Laura Mendoza"),
    ("Ciencias Básicas", "Jorge Torres"),
]

ESTUDIANTES = [
    ("Ana", "Gómez", "ana.gomez@uni.edu", "Ingeniería de Sistemas", 4),
    ("Luis", "Pérez", "luis.perez@uni.edu", "Administración de Empresas", 2),
    ("Marta", "Rojas", "marta.rojas@uni.edu", "Ingeniería de Sistemas", 6),
    ("Carlos", "Díaz", "carlos.diaz@uni.edu", "Contaduría Pública", 1),
]

# (nombre del curso, créditos, facultad). nombre_curso es UNIQUE: si el curso ya existe se omite.
CURSOS = [
    ("Programación I", 3, "Ingeniería"),
    ("Bases de Datos", 4, "Ingeniería"),
    ("Estructuras de Datos", 4, "Ingeniería"),
    ("Contabilidad General", 3, "Ciencias Económicas"),
    ("Cálculo Diferencial", 4, "Ciencias Básicas"),
]

# (curso que exige, curso que debe aprobarse antes)
PRERREQUISITOS = [
    ("Bases de Datos", "Programación I"),
    ("Estructuras de Datos", "Programación I"),
]

# (curso, cupo máximo, horario, profesor). cupo_disponible empieza igual al cupo máximo.
GRUPOS = [
    ("Programación I", 30, "Lun 08:00-10:00", "Andrés Salazar"),
    ("Bases de Datos", 25, "Mar 10:00-12:00", "Marcela Ortiz"),
    ("Contabilidad General", 40, "Mié 14:00-16:00", "Héctor Vargas"),
    ("Cálculo Diferencial", 35, "Jue 08:00-10:00", "Sandra Muñoz"),
]

# (correo del estudiante, curso del grupo, horario del grupo, fecha). El estado queda 'Activa' por defecto.
MATRICULAS = [
    ("ana.gomez@uni.edu", "Bases de Datos", "Mar 10:00-12:00", "2026-01-20"),
    ("marta.rojas@uni.edu", "Bases de Datos", "Mar 10:00-12:00", "2026-01-20"),
    ("luis.perez@uni.edu", "Contabilidad General", "Mié 14:00-16:00", "2026-01-21"),
    ("carlos.diaz@uni.edu", "Cálculo Diferencial", "Jue 08:00-10:00", "2026-01-22"),
    ("luis.perez@uni.edu", "Programación I", "Lun 08:00-10:00", "2026-01-22"),
]

# (correo, curso, nota final, estado, periodo). La nota es None mientras se cursa.
REGISTROS = [
    ("ana.gomez@uni.edu", "Programación I", 4.50, "Aprobado", "2025-1"),
    ("marta.rojas@uni.edu", "Programación I", 3.80, "Aprobado", "2024-2"),
    ("ana.gomez@uni.edu", "Bases de Datos", None, "Cursando", "2026-1"),
    ("marta.rojas@uni.edu", "Bases de Datos", None, "Cursando", "2026-1"),
    ("luis.perez@uni.edu", "Contabilidad General", None, "Cursando", "2026-1"),
]

# Luis se retira del grupo de Programación I; Carlos se borra del grupo de Cálculo Diferencial.
RETIRO = ("luis.perez@uni.edu", "Programación I", "Lun 08:00-10:00")
BORRADO = ("carlos.diaz@uni.edu", "Cálculo Diferencial", "Jue 08:00-10:00")


def main():
    with conexion() as con:
        # INSERT: facultades y decanos (id_facultad es AUTO_INCREMENT; nombre_facultad es UNIQUE).
        n = sum(ejecutar(con, "INSERT IGNORE INTO `facultad` (`nombre_facultad`, `decano`) VALUES (%s, %s)", f)
                for f in FACULTADES)
        print(f"INSERT facultad: {n} fila(s)")

        # INSERT: estudiantes (el correo es UNIQUE).
        n = sum(ejecutar(
            con,
            """INSERT IGNORE INTO `estudiante`
                   (`nombre`, `apellido`, `correo`, `programa_academico`, `semestre_actual`)
               VALUES (%s, %s, %s, %s, %s)""", e) for e in ESTUDIANTES)
        print(f"INSERT estudiante: {n} fila(s)")

        # INSERT: cursos. La facultad se busca por nombre; los cursos que ya existen se omiten.
        n = sum(ejecutar(
            con,
            """INSERT IGNORE INTO `curso` (`nombre_curso`, `creditos`, `id_facultad`)
               SELECT %s, %s, f.`id_facultad` FROM `facultad` f WHERE f.`nombre_facultad` = %s""", c)
                for c in CURSOS)
        print(f"INSERT curso: {n} fila(s) (los cursos que ya existían se omiten)")

        # INSERT: prerrequisitos (la PK compuesta evita duplicados).
        n = sum(ejecutar(
            con,
            """INSERT IGNORE INTO `prerrequisito` (`id_curso`, `id_curso_requisito`)
               SELECT c.`id_curso`, r.`id_curso`
               FROM `curso` c INNER JOIN `curso` r ON r.`nombre_curso` = %s
               WHERE c.`nombre_curso` = %s""", (requisito, curso)) for curso, requisito in PRERREQUISITOS)
        print(f"INSERT prerrequisito: {n} fila(s)")

        # INSERT: grupos. No hay llave natural única, así que se comprueba antes (curso + horario).
        n = 0
        for curso, cupo, horario, profesor in GRUPOS:
            existe = consultar(
                con,
                """SELECT 1 AS existe FROM `grupo` g INNER JOIN `curso` c ON c.`id_curso` = g.`id_curso`
                   WHERE c.`nombre_curso` = %s AND g.`horario` = %s""", (curso, horario))
            if not existe:
                n += ejecutar(
                    con,
                    """INSERT INTO `grupo` (`id_curso`, `cupo_maximo`, `cupo_disponible`, `horario`, `profesor`)
                       SELECT c.`id_curso`, %s, %s, %s, %s FROM `curso` c WHERE c.`nombre_curso` = %s""",
                    (cupo, cupo, horario, profesor, curso))
        print(f"INSERT grupo: {n} fila(s)")

        # INSERT: matrículas (UNIQUE estudiante + grupo evita repetirlas).
        n = sum(ejecutar(
            con,
            """INSERT IGNORE INTO `matricula` (`id_estudiante`, `id_grupo`, `fecha_matricula`)
               SELECT e.`id_estudiante`, g.`id_grupo`, %s
               FROM `estudiante` e
               INNER JOIN `curso` c ON c.`nombre_curso` = %s
               INNER JOIN `grupo` g ON g.`id_curso` = c.`id_curso` AND g.`horario` = %s
               WHERE e.`correo` = %s""", (fecha, curso, horario, correo))
                for correo, curso, horario, fecha in MATRICULAS)
        print(f"INSERT matricula: {n} fila(s)")

        # INSERT: registros académicos (UNIQUE estudiante + curso + periodo).
        n = sum(ejecutar(
            con,
            """INSERT IGNORE INTO `registro_academico`
                   (`id_estudiante`, `id_curso`, `nota_final`, `estado`, `periodo_cursado`)
               SELECT e.`id_estudiante`, c.`id_curso`, %s, %s, %s
               FROM `estudiante` e INNER JOIN `curso` c ON c.`nombre_curso` = %s
               WHERE e.`correo` = %s""", (nota, estado, periodo, curso, correo))
                for correo, curso, nota, estado, periodo in REGISTROS)
        print(f"INSERT registro_academico: {n} fila(s)")

        # UPDATE: Luis queda 'Retirada' en Programación I (el WHERE evita tocar otras matrículas).
        correo, curso, horario = RETIRO
        n = ejecutar(
            con,
            """UPDATE `matricula` m
               INNER JOIN `estudiante` e ON e.`id_estudiante` = m.`id_estudiante`
               INNER JOIN `grupo` g      ON g.`id_grupo` = m.`id_grupo`
               INNER JOIN `curso` c      ON c.`id_curso` = g.`id_curso`
               SET m.`estado` = 'Retirada'
               WHERE e.`correo` = %s AND c.`nombre_curso` = %s AND g.`horario` = %s""",
            (correo, curso, horario))
        print(f"UPDATE matricula (Retirada): {n} fila(s)")

        # DELETE: borra la matrícula de Carlos en Cálculo Diferencial (sin WHERE se borrarían todas).
        correo, curso, horario = BORRADO
        n = ejecutar(
            con,
            """DELETE m FROM `matricula` m
               INNER JOIN `estudiante` e ON e.`id_estudiante` = m.`id_estudiante`
               INNER JOIN `grupo` g      ON g.`id_grupo` = m.`id_grupo`
               INNER JOIN `curso` c      ON c.`id_curso` = g.`id_curso`
               WHERE e.`correo` = %s AND c.`nombre_curso` = %s AND g.`horario` = %s""",
            (correo, curso, horario))
        print(f"DELETE matricula: {n} fila(s)")

        # UPDATE: cupo_disponible = cupo_maximo - matrículas 'Activa'. Va al final para que
        # cuente el retiro y el borrado anteriores y los cupos queden consistentes.
        n = ejecutar(
            con,
            """UPDATE `grupo` g
               SET g.`cupo_disponible` = g.`cupo_maximo` - (
                   SELECT COUNT(*) FROM `matricula` m
                   WHERE m.`id_grupo` = g.`id_grupo` AND m.`estado` = 'Activa')""")
        print(f"UPDATE grupo (cupos): {n} fila(s)")

        con.commit()

        imprimir("Cupos por grupo", consultar(
            con,
            """SELECT g.`id_grupo`, c.`nombre_curso`, g.`horario`, g.`cupo_maximo`, g.`cupo_disponible`
               FROM `grupo` g INNER JOIN `curso` c ON c.`id_curso` = g.`id_curso`
               ORDER BY g.`id_grupo`"""))


if __name__ == "__main__":
    main()
