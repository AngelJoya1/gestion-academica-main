"""DQL (Data Query Language) — equivalente a sql/mariadb/Ejemplos SQL/03_DQL.sql.

Consultas de solo lectura: SELECT, JOIN, ORDER BY + LIMIT, GROUP BY y HAVING.
Sin argumentos ejecuta todas; con un nombre ejecuta una sola:
    python py/dql.py promedios
"""

import sys

from conexion import conexion, consultar, imprimir

CONSULTAS = {
    "estudiantes": (
        "Todos los estudiantes",
        "SELECT * FROM `estudiante`",
    ),
    "matriculas_detalle": (
        "Quién está matriculado en qué curso, con horario y profesor",
        # La matrícula apunta al grupo y el grupo al curso, por eso hay que pasar por grupo.
        """SELECT e.`nombre`, e.`apellido`, c.`nombre_curso`, gr.`horario`, gr.`profesor`, m.`estado`
           FROM `matricula` m
           INNER JOIN `estudiante` e ON m.`id_estudiante` = e.`id_estudiante`
           INNER JOIN `grupo` gr     ON m.`id_grupo` = gr.`id_grupo`
           INNER JOIN `curso` c      ON gr.`id_curso` = c.`id_curso`""",
    ),
    "top_cupos": (
        "Los 3 grupos con más cupos libres",
        """SELECT c.`nombre_curso`, gr.`cupo_disponible`
           FROM `grupo` gr
           INNER JOIN `curso` c ON gr.`id_curso` = c.`id_curso`
           ORDER BY gr.`cupo_disponible` DESC, gr.`id_grupo`
           LIMIT 3""",
    ),
    "promedios": (
        "Promedio de notas y cursos aprobados por estudiante",
        """SELECT e.`nombre`, e.`apellido`,
                  ROUND(AVG(r.`nota_final`), 2) AS promedio,
                  COUNT(*) AS cursos_aprobados
           FROM `registro_academico` r
           INNER JOIN `estudiante` e ON r.`id_estudiante` = e.`id_estudiante`
           WHERE r.`estado` = 'Aprobado'
           GROUP BY e.`id_estudiante`, e.`nombre`, e.`apellido`""",
    ),
    "cursos_con_matriculados": (
        "Cursos con 2 o más matriculados activos (HAVING)",
        """SELECT c.`nombre_curso`, COUNT(*) AS total_matriculados
           FROM `matricula` m
           INNER JOIN `grupo` gr ON m.`id_grupo` = gr.`id_grupo`
           INNER JOIN `curso` c  ON gr.`id_curso` = c.`id_curso`
           WHERE m.`estado` = 'Activa'
           GROUP BY c.`nombre_curso`
           HAVING COUNT(*) >= 2""",
    ),
    "prerrequisitos": (
        "Cada curso junto al curso que exige (auto-JOIN)",
        """SELECT c.`nombre_curso` AS curso, req.`nombre_curso` AS requiere
           FROM `prerrequisito` p
           INNER JOIN `curso` c   ON p.`id_curso` = c.`id_curso`
           INNER JOIN `curso` req ON p.`id_curso_requisito` = req.`id_curso`""",
    ),
}


def main(argv):
    nombres = argv or list(CONSULTAS)
    desconocidas = [n for n in nombres if n not in CONSULTAS]
    if desconocidas:
        sys.exit(f"Consulta desconocida: {', '.join(desconocidas)}. Opciones: {', '.join(CONSULTAS)}")
    with conexion() as con:
        for nombre in nombres:
            titulo, sql = CONSULTAS[nombre]
            imprimir(titulo, consultar(con, sql))


if __name__ == "__main__":
    main(sys.argv[1:])
