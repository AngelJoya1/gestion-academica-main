-- =====================================================================================
-- 01_DDL — Data Definition Language
-- Objetivo: definir y modificar la estructura de la base de datos gestion_academica.
-- Incluye: CREATE, ALTER (agregar/modificar columnas) y DROP (eliminar tabla de prueba).
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de sql\mariadb\gestion_academica.sql (las tablas base ya deben
--   existir) y ANTES de 02_DML, porque aquí se agregan columnas que los scripts
--   siguientes van a utilizar.
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   Todas las sentencias usan IF [NOT] EXISTS (CREATE TABLE, ADD COLUMN, CREATE INDEX,
--   DROP TABLE), por lo que este script puede ejecutarse varias veces seguidas sin
--   error: si la columna, el índice o la tabla ya existen, la sentencia simplemente no
--   hace nada en vez de fallar.
-- =====================================================================================

USE "gestion_academica";

-- ---------------------------------------------------------------------------------
-- CREATE: crea una tabla nueva de prueba para demostrar el comando CREATE TABLE.
-- Se usa para validar que el esquema y los permisos funcionan antes de tocar las
-- tablas reales del modelo.
-- Las siguientes tablas ya fueron creadas en sql\mariadb\gestion_academica.sql
-- ---------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tabla_estudiantes_prueba` (    
    `nombre`             VARCHAR(60)  NOT NULL,
    `apellido`           VARCHAR(60)  NOT NULL,
    id_estudiante INT UNSIGNED NOT NULL AUTO_INCREMENT,    
    `programa_academico` VARCHAR(100) NOT NULL,
    `semestre_actual`    TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id_estudiante`),
    CONSTRAINT `chk_estudiante_semestre` CHECK (`semestre_actual` BETWEEN 1 AND 12)
);

-- ---------------------------------------------------------------------------------
-- ALTER: agrega una columna nueva a la tabla `estudiantes` para registrar columnas que no existen en
-- la tabla original, pero son necesarias para la base de datos
-- ---------------------------------------------------------------------------------

ALTER TABLE `tabla_estudiantes_prueba`
    ADD COLUMN IF NOT EXISTS telefono VARCHAR(20) NULL; -- Añade el telefono de los estudiantes si poseen uno

ALTER TABLE `tabla_estudiantes_prueba`    
    ADD COLUMN IF NOT EXISTS `correo` VARCHAR(120) NOT NULL;

-- ---------------------------------------------------------------------------------
-- ALTER: Modifica el tamaño maximo del campo apellido, de 60 a 80
-- ---------------------------------------------------------------------------------

ALTER TABLE `tabla_estudiantes_prueba`    
    MODIFY apellido VARCHAR(80) NOT NULL;
    
-- ---------------------------------------------------------------------------------
-- CREATE INDEX: Crea un indice sobre programa_academico para acelerar las busquedas
-- ---------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_estudiante_programa ON estudiante (programa_academico);
    
 -- ---------------------------------------------------------------------------------
-- DROP: elimina la tabla de prueba creada al inicio del script, ya que sólo servía
-- para demostrar el comando CREATE TABLE y no forma parte del modelo final.
-- ---------------------------------------------------------------------------------

DROP TABLE IF EXISTS `tabla_estudiantes_prueba`;
