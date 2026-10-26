-- =====================================================================================
-- 02_DML.sql — Data Manipulation Language
-- Objetivo: manipular los datos ya cargados en la base de datos gestion_academica.
-- Incluye: INSERT (nuevas facultades y decanos), UPDATE (actualizar los cupos disponibles) y
-- DELETE (eliminación de una matricula).
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de gestion_academica.sql (los datos de ejemplo ya deben
--   existir) y de 01_DDL.
-- ===================================================================================

USE `gestion_academica`;

-- ---------------------------------------------------------------------------------
-- INSERT: Registra nuevas facultades, y con ellas, nuevos decanos. 
-- No incluimos id_facultad porque es AUTO_INCREMENT
-- ---------------------------------------------------------------------------------

INSERT INTO facultad (nombre_facultad, decano)
VALUES ('Ingeniería', 'Carlos Ramírez'),
       ('Ciencias Económicas', 'Laura Mendoza'),
       ('Ciencias Básicas', 'Jorge Torres');

-- ---------------------------------------------------------------------------------
-- INSERT: Ingresa cuatro nuevos estudiantes con nombres, apellidos, e-mails, y carreras
-- respectivamente
-- ---------------------------------------------------------------------------------

INSERT INTO estudiante (nombre, apellido, correo, programa_academico, semestre_actual)
VALUES ('Ana',   'Gómez', 'ana.gomez@uni.edu',   'Ingeniería de Sistemas',     4),
       ('Luis',  'Pérez', 'luis.perez@uni.edu',  'Administración de Empresas', 2),
       ('Marta', 'Rojas', 'marta.rojas@uni.edu', 'Ingeniería de Sistemas',     6),
       ('Carlos','Díaz',  'carlos.diaz@uni.edu', 'Contaduría Pública',         1);       

-- ---------------------------------------------------------------------------------
-- INSERT: Crea un grupo por curso, con cupo, horario y profesor. cupo_disponible empieza igual a cupo_maximo; el CHECK impide que sea mayor.
-- ---------------------------------------------------------------------------------

INSERT INTO grupo (id_curso, cupo_maximo, cupo_disponible, horario, profesor)
VALUES (1, 30, 30, 'Lun 08:00-10:00', 'Andrés Salazar'),
       (2, 25, 25, 'Mar 10:00-12:00', 'Marcela Ortiz'),
       (4, 40, 40, 'Mié 14:00-16:00', 'Héctor Vargas'),
       (5, 35, 35, 'Jue 08:00-10:00', 'Sandra Muñoz');

-- ---------------------------------------------------------------------------------
-- INSERT: Inserta 5 cursos. El último número es id_facultad: por ejemplo, Programación I pertenece a la 
-- facultad 1 (Ingeniería). Ese valor debe existir en facultad.
-- ---------------------------------------------------------------------------------

INSERT INTO curso (nombre_curso, creditos, id_facultad)
VALUES ('Programación I',        3, 1),
       ('Bases de Datos',        4, 1),
       ('Estructuras de Datos',  4, 1),
       ('Contabilidad General',  3, 2),
       ('Cálculo Diferencial',   4, 3);

-- ---------------------------------------------------------------------------------
-- INSERT: Define que para ver Bases de Datos (2) hay que aprobar Programación I (1), y lo mismo para Estructuras de Datos (3).
-- ---------------------------------------------------------------------------------

INSERT INTO prerrequisito (id_curso, id_curso_requisito)
VALUES (2, 1),
       (3, 1);

-- ---------------------------------------------------------------------------------
-- INSERT: Crea un grupo por curso, con cupo, horario y profesor. cupo_disponible empieza igual a cupo_maximo; 
-- el CHECK impide que sea mayor.
-- ---------------------------------------------------------------------------------

INSERT INTO matricula (id_estudiante, id_grupo, fecha_matricula)
VALUES (1, 2, '2026-01-20'),
       (3, 2, '2026-01-20'),
       (2, 3, '2026-01-21'),
       (4, 4, '2026-01-22'),
       (2, 1, '2026-01-22');

-- ---------------------------------------------------------------------------------
-- INSERT: Matricula estudiantes en grupos. Por ejemplo, (1, 2, ...) es Ana en el grupo de Bases de Datos. 
-- No ponemos estado porque su valor por defecto es 'Activa'. La combinación estudiante + grupo no se puede repetir (UNIQUE).
-- ---------------------------------------------------------------------------------

INSERT INTO registro_academico (id_estudiante, id_curso, nota_final, estado, periodo_cursado)
VALUES (1, 1, 4.50, 'Aprobado', '2025-1'),
       (3, 1, 3.80, 'Aprobado', '2024-2'),
       (1, 2, NULL, 'Cursando',  '2026-1'),
       (3, 2, NULL, 'Cursando',  '2026-1'),
       (2, 4, NULL, 'Cursando',  '2026-1');

-- ---------------------------------------------------------------------------------
-- UPDATE: Actualiza el cupo maximo de matriculas menos el numero de matriculas
-- activas
-- ---------------------------------------------------------------------------------

UPDATE grupo g
SET g.cupo_disponible = g.cupo_maximo - (
    SELECT COUNT(*) FROM matricula m
    WHERE m.id_grupo = g.id_grupo AND m.estado = 'Activa'
);

-- ---------------------------------------------------------------------------------
-- UPDATE: Actualiza el estado del alumno Luis, en el grupo 1. Se debe usar WHERE, de lo contrario
-- todo el grupo 1 sera eliminado
-- ---------------------------------------------------------------------------------

UPDATE matricula SET estado = 'Retirada'
WHERE id_estudiante = 2 AND id_grupo = 1;

-- ---------------------------------------------------------------------------------
-- DELETE: Borra la matrícula de Carlos en el grupo 4. 
-- Sin WHERE se borrarían todas las matrículas.
-- ---------------------------------------------------------------------------------

DELETE FROM matricula WHERE id_estudiante = 4 AND id_grupo = 4;