-- =====================================================================================
-- 04_VDL — View Definition Language
-- Objetivo: definir y administrar vistas basadas en la estructura y datos ya cargados.
-- Incluye: CREATE VIEW, consulta de la vista y DROP VIEW de ejemplo.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 03_DQL, cuando ya se confirmó que los datos base
--   son correctos. Las vistas se apoyan en las tablas pelicula, ejemplar y estado.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Ambas vistas se definen con CREATE OR REPLACE VIEW, por lo que ejecutarlo varias
--   veces simplemente vuelve a definir la misma vista sin error. Los SELECT son de
--   sólo lectura y el DROP VIEW usa IF EXISTS (queda comentado por defecto).
-- =====================================================================================

USE `gestion_academica`;

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: Crea la vista o la reemplaza si ya existe
-- ---------------------------------------------------------------------------------

CREATE OR REPLACE VIEW vista_oferta_grupos AS
SELECT gr.id_grupo, c.nombre_curso, c.creditos, f.nombre_facultad,
       gr.horario, gr.profesor, gr.cupo_disponible
FROM grupo gr
JOIN curso c    ON gr.id_curso = c.id_curso
JOIN facultad f ON c.id_facultad = f.id_facultad;

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: Una vista con filtro incluido: solo muestra las matrículas activas.
-- ---------------------------------------------------------------------------------

CREATE OR REPLACE VIEW vista_matriculas_activas AS
SELECT e.nombre, e.apellido, e.programa_academico, c.nombre_curso, m.fecha_matricula
FROM matricula m
JOIN estudiante e ON m.id_estudiante = e.id_estudiante
JOIN grupo gr     ON m.id_grupo = gr.id_grupo
JOIN curso c      ON gr.id_curso = c.id_curso
WHERE m.estado = 'Activa';

-- ---------------------------------------------------------------------------------
-- CREATE VIEW: Las vistas se consultan igual que una tabla, y se les puede aplicar 
-- WHERE y ORDER BY.
-- ---------------------------------------------------------------------------------

SELECT * FROM vista_oferta_grupos WHERE cupo_disponible > 0;
SELECT * FROM vista_matriculas_activas ORDER BY apellido;

-- ---------------------------------------------------------------------------------
-- Lista solo las vistas de la base de datos.
-- ---------------------------------------------------------------------------------

SHOW FULL TABLES WHERE Table_type = 'VIEW';