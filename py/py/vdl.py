"""VDL (View Definition Language) — equivalente a sql/mariadb/Ejemplos SQL/04_VDL.sql.

CREATE OR REPLACE VIEW de las dos vistas del proyecto, consulta de cada una y listado
de las vistas de la base de datos. El DROP VIEW queda detrás de la opción --drop:
    python py/vdl.py --drop
"""

import sys

from conexion import conexion, consultar, ejecutar, imprimir

VISTAS = {
    "vista_oferta_grupos": (
        """CREATE OR REPLACE VIEW `vista_oferta_grupos` AS
           SELECT gr.`id_grupo`, c.`nombre_curso`, c.`creditos`, f.`nombre_facultad`,
                  gr.`horario`, gr.`profesor`, gr.`cupo_disponible`
           FROM `grupo` gr
           INNER JOIN `curso` c    ON gr.`id_curso` = c.`id_curso`
           INNER JOIN `facultad` f ON c.`id_facultad` = f.`id_facultad`""",
        # Las vistas se consultan como una tabla: admiten WHERE y ORDER BY.
        "SELECT * FROM `vista_oferta_grupos` WHERE `cupo_disponible` > 0",
    ),
    "vista_matriculas_activas": (
        """CREATE OR REPLACE VIEW `vista_matriculas_activas` AS
           SELECT e.`nombre`, e.`apellido`, e.`programa_academico`, c.`nombre_curso`, m.`fecha_matricula`
           FROM `matricula` m
           INNER JOIN `estudiante` e ON m.`id_estudiante` = e.`id_estudiante`
           INNER JOIN `grupo` gr     ON m.`id_grupo` = gr.`id_grupo`
           INNER JOIN `curso` c      ON gr.`id_curso` = c.`id_curso`
           WHERE m.`estado` = 'Activa'""",
        "SELECT * FROM `vista_matriculas_activas` ORDER BY `apellido`",
    ),
}


def main(argv):
    with conexion() as con:
        if "--drop" in argv:
            for nombre in VISTAS:
                ejecutar(con, f"DROP VIEW IF EXISTS `{nombre}`")
                print(f"Vista eliminada: {nombre}")
            con.commit()
            return
        for nombre, (crear, consulta) in VISTAS.items():
            ejecutar(con, crear)
            imprimir(nombre, consultar(con, consulta))
        con.commit()
        imprimir("Vistas de la base de datos", consultar(con, "SHOW FULL TABLES WHERE Table_type = 'VIEW'"))


if __name__ == "__main__":
    main(sys.argv[1:])
