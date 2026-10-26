sql
-- =====================================================================================
-- Base de Datos: Gestión Académica (estudiantes, cursos, grupos y matrículas)
-- Motor: MariaDB (XAMPP)
-- Archivo: gestion_academica.sql  ->  SCRIPT PRINCIPAL que construye la base de datos
--
-- Qué hace este script:
--   1. Crea la base de datos (si no existe) y la selecciona.
--   2. Crea las 7 tablas del modelo entidad-relación (si no existen).
--   3. Define las llaves primarias (PK) y las llaves foráneas (FK) que relacionan
--      las tablas entre sí.
--
-- Se puede ejecutar varias veces sin error porque todo usa IF NOT EXISTS.
-- =====================================================================================

-- Crea la base de datos solo si todavía no existe.
-- utf8mb4 permite guardar tildes, ñ y cualquier carácter especial sin problemas.
CREATE DATABASE IF NOT EXISTS `gestion_academica`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

-- Selecciona la base de datos: todo lo que sigue se crea dentro de ella.
USE `gestion_academica`;

-- =====================================================================================
-- RESUMEN DE RELACIONES (tabla hija -> tabla padre)
-- =====================================================================================
-- curso               (id_facultad)                 -> facultad            : 1 facultad tiene muchos cursos
-- prerrequisito       (id_curso)                    -> curso               : un curso tiene varios requisitos
-- prerrequisito       (id_curso_requisito)          -> curso               : un curso es requisito de varios cursos
-- grupo               (id_curso)                    -> curso               : 1 curso tiene muchos grupos
-- matricula           (id_estudiante)               -> estudiante          : 1 estudiante tiene muchas matrículas
-- matricula           (id_grupo)                    -> grupo               : 1 grupo tiene muchas matrículas
-- registro_academico  (id_estudiante)               -> estudiante          : 1 estudiante tiene muchos registros
-- registro_academico  (id_curso)                    -> curso               : 1 curso aparece en muchos registros
--
-- Relaciones muchos a muchos resueltas con tablas intermedias:
--   curso      <-> curso   : prerrequisito
--   estudiante <-> grupo   : matricula
--   estudiante <-> curso   : registro_academico
-- =====================================================================================

-- =====================================================================================
-- TABLA: facultad
-- Guarda las facultades de la universidad. Es una tabla "padre": no depende de nadie.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `facultad` (
    -- Llave primaria autoincremental: MariaDB asigna 1, 2, 3... automáticamente.
    `id_facultad`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- Nombre de la facultad; UNIQUE evita registrar dos veces la misma.
    `nombre_facultad` VARCHAR(100) NOT NULL,
    -- Nombre del decano (la persona que dirige la facultad).
    `decano`          VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id_facultad`),
    CONSTRAINT `uq_facultad_nombre` UNIQUE (`nombre_facultad`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Facultades de la universidad.';

-- =====================================================================================
-- TABLA: estudiante
-- Guarda los datos personales y académicos de cada estudiante. Tabla "padre".
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `estudiante` (
    `id_estudiante`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nombre`             VARCHAR(60)  NOT NULL,
    `apellido`           VARCHAR(60)  NOT NULL,
    -- El correo no se puede repetir: identifica de forma única al estudiante.
    `correo`             VARCHAR(120) NOT NULL,
    `programa_academico` VARCHAR(100) NOT NULL,
    -- Semestre que cursa actualmente (entre 1 y 12).
    `semestre_actual`    TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id_estudiante`),
    CONSTRAINT `uq_estudiante_correo` UNIQUE (`correo`),
    CONSTRAINT `chk_estudiante_semestre` CHECK (`semestre_actual` BETWEEN 1 AND 12)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Estudiantes de la universidad.';

-- =====================================================================================
-- TABLA: curso
-- Materias que se dictan. Cada curso pertenece a UNA facultad (relación 1 a muchos).
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `curso` (
    `id_curso`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nombre_curso` VARCHAR(100) NOT NULL,
    -- Créditos académicos del curso (entre 1 y 10).
    `creditos`     TINYINT UNSIGNED NOT NULL,
    -- LLAVE FORÁNEA: apunta a la facultad a la que pertenece el curso.
    `id_facultad`  INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id_curso`),
    CONSTRAINT `uq_curso_nombre` UNIQUE (`nombre_curso`),
    CONSTRAINT `chk_curso_creditos` CHECK (`creditos` BETWEEN 1 AND 10),
    -- RESTRICT: no deja borrar una facultad que todavía tenga cursos.
    CONSTRAINT `fk_curso_facultad`
        FOREIGN KEY (`id_facultad`) REFERENCES `facultad` (`id_facultad`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Cursos (materias) ofrecidos por cada facultad.';

-- =====================================================================================
-- TABLA: prerrequisito
-- Tabla intermedia que resuelve la relación muchos a muchos de curso con curso:
-- "para ver el curso A hay que haber aprobado el curso B".
-- La llave primaria es COMPUESTA: la unión de los dos campos no se puede repetir.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `prerrequisito` (
    -- Curso que EXIGE el requisito.
    `id_curso`           INT UNSIGNED NOT NULL,
    -- Curso que se debe haber aprobado antes.
    `id_curso_requisito` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id_curso`, `id_curso_requisito`),
    -- Un curso no puede ser requisito de sí mismo.
    CONSTRAINT `chk_prerrequisito_distintos` CHECK (`id_curso` <> `id_curso_requisito`),
    CONSTRAINT `fk_prerrequisito_curso`
        FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id_curso`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_prerrequisito_requisito`
        FOREIGN KEY (`id_curso_requisito`) REFERENCES `curso` (`id_curso`)
        ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Cursos que se deben aprobar antes de ver otro curso.';

-- =====================================================================================
-- TABLA: grupo
-- Un curso se dicta en varios grupos (con su horario, profesor y cupo).
-- Relación: 1 curso -> muchos grupos.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `grupo` (
    `id_grupo`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- LLAVE FORÁNEA: curso al que pertenece el grupo.
    `id_curso`        INT UNSIGNED NOT NULL,
    -- Cantidad máxima de estudiantes que caben en el grupo.
    `cupo_maximo`     SMALLINT UNSIGNED NOT NULL,
    -- Cupos que todavía quedan libres.
    `cupo_disponible` SMALLINT UNSIGNED NOT NULL,
    `horario`         VARCHAR(60)  NOT NULL,
    `profesor`        VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id_grupo`),
    -- Los cupos libres nunca pueden superar el cupo máximo.
    CONSTRAINT `chk_grupo_cupos` CHECK (`cupo_disponible` <= `cupo_maximo`),
    CONSTRAINT `fk_grupo_curso`
        FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id_curso`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Grupos en los que se dicta cada curso.';

-- =====================================================================================
-- TABLA: matricula
-- Tabla intermedia que resuelve la relación muchos a muchos entre estudiante y grupo:
-- un estudiante se matricula en varios grupos y un grupo tiene varios estudiantes.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `matricula` (
    `id_matricula`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- LLAVES FORÁNEAS hacia las dos tablas que se están relacionando.
    `id_estudiante`   INT UNSIGNED NOT NULL,
    `id_grupo`        INT UNSIGNED NOT NULL,
    `fecha_matricula` DATE NOT NULL,
    -- Solo se permiten estos tres valores.
    `estado`          ENUM('Activa', 'Retirada', 'Cancelada') NOT NULL DEFAULT 'Activa',
    PRIMARY KEY (`id_matricula`),
    -- Un estudiante no puede matricularse dos veces en el mismo grupo.
    CONSTRAINT `uq_matricula_estudiante_grupo` UNIQUE (`id_estudiante`, `id_grupo`),
    CONSTRAINT `fk_matricula_estudiante`
        FOREIGN KEY (`id_estudiante`) REFERENCES `estudiante` (`id_estudiante`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_matricula_grupo`
        FOREIGN KEY (`id_grupo`) REFERENCES `grupo` (`id_grupo`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Matrículas de los estudiantes en los grupos.';

-- =====================================================================================
-- TABLA: registro_academico
-- Historial del estudiante: qué cursos ha visto, con qué nota y en qué periodo.
-- Resuelve la relación muchos a muchos entre estudiante y curso.
-- =====================================================================================
CREATE TABLE IF NOT EXISTS `registro_academico` (
    `id_registro`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- LLAVES FORÁNEAS hacia estudiante y curso.
    `id_estudiante`   INT UNSIGNED NOT NULL,
    `id_curso`        INT UNSIGNED NOT NULL,
    -- Nota de 0.00 a 5.00; NULL mientras el curso todavía se está cursando.
    `nota_final`      DECIMAL(3,2) NULL,
    `estado`          ENUM('Cursando', 'Aprobado', 'Reprobado', 'Retirado') NOT NULL DEFAULT 'Cursando',
    -- Periodo académico en formato año-semestre, por ejemplo 2026-1.
    `periodo_cursado` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`id_registro`),
    -- Un estudiante no repite el mismo curso en el mismo periodo.
    CONSTRAINT `uq_registro_estudiante_curso_periodo` UNIQUE (`id_estudiante`, `id_curso`, `periodo_cursado`),
    CONSTRAINT `chk_registro_nota` CHECK (`nota_final` IS NULL OR `nota_final` BETWEEN 0 AND 5),
    CONSTRAINT `fk_registro_estudiante`
        FOREIGN KEY (`id_estudiante`) REFERENCES `estudiante` (`id_estudiante`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_registro_curso`
        FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id_curso`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
  COMMENT = 'Historial académico: cursos vistos, notas y periodos.';