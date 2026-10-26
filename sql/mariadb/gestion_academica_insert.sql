-- =====================================================================================
-- Datos ficticios de prueba para la base de datos gestion_academica
-- Archivo: gestion_academica_insert.sql
--
-- Ejecutar DESPUÉS de gestion_academica.sql. Las consultas necesitan datos: sin
-- registros, un SELECT no devolvería nada.
--
-- Los datos se insertan en orden: primero las tablas "padre" y luego las que tienen
-- llaves foráneas; si se invierte el orden, MariaDB rechaza los inserts porque el
-- registro al que apunta la FK todavía no existe.
-- Usa INSERT IGNORE: si una fila ya existe (mismo id) se omite en lugar de dar error,
-- así el script se puede ejecutar varias veces sin duplicar datos.
-- =====================================================================================

USE `gestion_academica`;

-- 1) facultad (no depende de nadie)
INSERT IGNORE INTO `facultad` (`id_facultad`, `nombre_facultad`, `decano`) VALUES
    (1, 'Facultad de Ingeniería',          'Carlos Ramírez Peña'),
    (2, 'Facultad de Ciencias Económicas', 'Marta Lucía Gómez'),
    (3, 'Facultad de Ciencias Básicas',    'Jorge Andrés Torres');

-- 2) estudiante (no depende de nadie)
INSERT IGNORE INTO `estudiante` (`id_estudiante`, `nombre`, `apellido`, `correo`, `programa_academico`, `semestre_actual`) VALUES
    (1, 'Laura',     'Martínez', 'laura.martinez@universidad.edu.co',     'Ingeniería de Sistemas',     4),
    (2, 'Andrés',    'Rojas',    'andres.rojas@universidad.edu.co',       'Ingeniería de Sistemas',     2),
    (3, 'Camila',    'Torres',   'camila.torres@universidad.edu.co',      'Ingeniería de Sistemas',     5),
    (4, 'Julián',    'Herrera',  'julian.herrera@universidad.edu.co',     'Ingeniería Industrial',      3),
    (5, 'Valentina', 'Gómez',    'valentina.gomez@universidad.edu.co',    'Administración de Empresas', 1),
    (6, 'Sebastián', 'Cruz',     'sebastian.cruz@universidad.edu.co',     'Ingeniería de Sistemas',     6),
    (7, 'Daniela',   'Vargas',   'daniela.vargas@universidad.edu.co',     'Contaduría Pública',         2),
    (8, 'Mateo',     'Castillo', 'mateo.castillo@universidad.edu.co',     'Ingeniería Industrial',      4);

-- 3) curso (depende de facultad)
INSERT IGNORE INTO `curso` (`id_curso`, `nombre_curso`, `creditos`, `id_facultad`) VALUES
    (1, 'Cálculo Diferencial',   4, 3),
    (2, 'Cálculo Integral',      4, 3),
    (3, 'Programación I',        3, 1),
    (4, 'Programación II',       3, 1),
    (5, 'Bases de Datos',        3, 1),
    (6, 'Estructuras de Datos',  3, 1),
    (7, 'Contabilidad General',  3, 2),
    (8, 'Estadística',           3, 3);

-- 4) prerrequisito (depende de curso). Formato: (curso, curso que debe aprobarse antes)
INSERT IGNORE INTO `prerrequisito` (`id_curso`, `id_curso_requisito`) VALUES
    (2, 1),   -- Cálculo Integral exige Cálculo Diferencial
    (4, 3),   -- Programación II exige Programación I
    (5, 4),   -- Bases de Datos exige Programación II
    (6, 4),   -- Estructuras de Datos exige Programación II
    (8, 1);   -- Estadística exige Cálculo Diferencial

-- 5) grupo (depende de curso)
-- cupo_disponible = cupo_maximo menos las matrículas 'Activa' de ese grupo (ver paso 6).
INSERT IGNORE INTO `grupo` (`id_grupo`, `id_curso`, `cupo_maximo`, `cupo_disponible`, `horario`, `profesor`) VALUES
    (1, 1, 30, 28, 'Lun-Mié 07:00-09:00', 'Pablo Mejía'),
    (2, 3, 25, 24, 'Mar-Jue 09:00-11:00', 'Sandra Ortiz'),
    (3, 4, 25, 25, 'Mar-Jue 11:00-13:00', 'Sandra Ortiz'),
    (4, 5, 20, 17, 'Lun-Mié 14:00-16:00', 'Ricardo Salazar'),
    (5, 6, 20, 19, 'Vie 08:00-12:00',     'Ricardo Salazar'),
    (6, 7, 30, 29, 'Mar-Jue 07:00-09:00', 'Elena Duarte'),
    (7, 8, 30, 29, 'Lun-Mié 16:00-18:00', 'Hernán Acosta'),
    (8, 2, 30, 29, 'Mar-Jue 14:00-16:00', 'Pablo Mejía');

-- 6) matricula (depende de estudiante y grupo)
INSERT IGNORE INTO `matricula` (`id_matricula`, `id_estudiante`, `id_grupo`, `fecha_matricula`, `estado`) VALUES
    (1,  1, 4, '2026-07-20', 'Activa'),
    (2,  1, 5, '2026-07-20', 'Activa'),
    (3,  2, 2, '2026-07-21', 'Activa'),
    (4,  2, 1, '2026-07-21', 'Activa'),
    (5,  3, 4, '2026-07-22', 'Activa'),
    (6,  3, 5, '2026-07-22', 'Retirada'),
    (7,  4, 7, '2026-07-22', 'Activa'),
    (8,  5, 1, '2026-07-23', 'Activa'),
    (9,  6, 4, '2026-07-23', 'Activa'),
    (10, 7, 6, '2026-07-24', 'Activa'),
    (11, 8, 8, '2026-07-24', 'Activa'),
    (12, 5, 2, '2026-07-23', 'Cancelada');

-- 7) registro_academico (depende de estudiante y curso)
-- nota_final es NULL cuando el curso todavía se está cursando.
INSERT IGNORE INTO `registro_academico` (`id_registro`, `id_estudiante`, `id_curso`, `nota_final`, `estado`, `periodo_cursado`) VALUES
    (1,  1, 1, 4.20, 'Aprobado',  '2025-1'),
    (2,  1, 3, 4.50, 'Aprobado',  '2025-1'),
    (3,  1, 4, 3.80, 'Aprobado',  '2025-2'),
    (4,  1, 5, NULL, 'Cursando',  '2026-2'),
    (5,  1, 6, NULL, 'Cursando',  '2026-2'),
    (6,  2, 3, NULL, 'Cursando',  '2026-2'),
    (7,  2, 1, NULL, 'Cursando',  '2026-2'),
    (8,  3, 1, 2.50, 'Reprobado', '2024-2'),
    (9,  3, 3, 4.00, 'Aprobado',  '2024-2'),
    (10, 3, 4, 3.50, 'Aprobado',  '2025-1'),
    (11, 3, 5, NULL, 'Cursando',  '2026-2'),
    (12, 4, 1, 3.20, 'Aprobado',  '2025-2'),
    (13, 4, 8, NULL, 'Cursando',  '2026-2'),
    (14, 5, 1, NULL, 'Cursando',  '2026-2'),
    (15, 6, 3, 4.80, 'Aprobado',  '2025-1'),
    (16, 6, 4, 4.10, 'Aprobado',  '2025-2'),
    (17, 6, 5, NULL, 'Cursando',  '2026-2'),
    (18, 7, 7, NULL, 'Cursando',  '2026-2'),
    (19, 8, 1, 3.90, 'Aprobado',  '2025-2'),
    (20, 8, 2, NULL, 'Cursando',  '2026-2');