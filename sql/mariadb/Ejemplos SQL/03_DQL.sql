-- =====================================================================================
-- 03_DQL — Data Query Language
-- Objetivo: consultar los datos ya cargados para verificar que todo esté correcto.
-- Incluye: SELECT con condiciones, JOIN entre tablas y GROUP BY con conteos.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 02_DML, ya que consulta datos y columnas 
-- generados en los scripts previos.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Todas las sentencias son SELECT de sólo lectura: no modifican datos, por lo que
--   ejecutar este script una o cien veces seguidas siempre produce el mismo
--   resultado y nunca falla por repetición.
-- =====================================================================================

USE `gestion_academica`;

-- ---------------------------------------------------------------------------------
-- SELECT * FROM trae todas las columnas de una tabla
-- ---------------------------------------------------------------------------------

SELECT * FROM estudiante;

-- ---------------------------------------------------------------------------------
-- SELECT: Muestra quién está matriculado en qué curso, con horario y profesor.
-- FROM matricula m: parte de las matrículas (alias m).
-- Cada JOIN ... ON ... une una tabla relacionada comparando la llave foránea con la llave primaria.
-- Para llegar de la matrícula al curso hay que pasar por grupo, porque la matrícula apunta al grupo y el grupo apunta al curso.
-- ---------------------------------------------------------------------------------

SELECT e.nombre, e.apellido, c.nombre_curso, gr.horario, gr.profesor, m.estado
FROM matricula m
JOIN estudiante e ON m.id_estudiante = e.id_estudiante
JOIN grupo gr     ON m.id_grupo = gr.id_grupo
JOIN curso c      ON gr.id_curso = c.id_curso;

-- ---------------------------------------------------------------------------------
-- SELECT: LIMIT 3 devuelve solo las 3 primeras filas: los 3 grupos con más cupos libres.
-- ---------------------------------------------------------------------------------

SELECT c.nombre_curso, gr.cupo_disponible
FROM grupo gr
JOIN curso c ON gr.id_curso = c.id_curso
ORDER BY gr.cupo_disponible DESC
LIMIT 3;

-- ---------------------------------------------------------------------------------
-- SELECT: Toma el promedio de notas y lo redondea a dos decimales, cuenta los cursos 
-- aprobados y muestra los dos valores
-- ---------------------------------------------------------------------------------

SELECT e.nombre, e.apellido,
       ROUND(AVG(r.nota_final), 2) AS promedio,
       COUNT(*) AS cursos_aprobados
FROM registro_academico r
JOIN estudiante e ON r.id_estudiante = e.id_estudiante
WHERE r.estado = 'Aprobado'
GROUP BY e.id_estudiante, e.nombre, e.apellido;

-- ---------------------------------------------------------------------------------
-- SELECT: HAVING filtra después de agrupar (el WHERE filtra antes). Aquí muestra solo 
-- los cursos con 2 o más matriculados activos.
-- ---------------------------------------------------------------------------------

SELECT c.nombre_curso, COUNT(*) AS total_matriculados
FROM matricula m
JOIN grupo gr ON m.id_grupo = gr.id_grupo
JOIN curso c  ON gr.id_curso = c.id_curso
WHERE m.estado = 'Activa'
GROUP BY c.nombre_curso
HAVING COUNT(*) >= 2;

-- ---------------------------------------------------------------------------------
-- SELECT: Une la tabla curso consigo misma, con dos alias distintos (c y req), para 
-- mostrar cada curso junto al curso que exige.
-- ---------------------------------------------------------------------------------

SELECT c.nombre_curso AS curso, req.nombre_curso AS requiere
FROM prerrequisito p
JOIN curso c   ON p.id_curso = c.id_curso
JOIN curso req ON p.id_curso_requisito = req.id_curso;