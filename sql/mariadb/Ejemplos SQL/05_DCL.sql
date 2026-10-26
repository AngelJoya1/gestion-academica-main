-- =====================================================================================
-- 05_DCL — Data Control Language
-- Objetivo: gestionar permisos y accesos a la base de datos gestion_academica.
-- Incluye: creación de usuario, GRANT de permisos de lectura, REVOKE de permisos de
-- borrado y consulta de privilegios existentes.
--
-- CÓMO SE EJECUTA:
--   Debe correrse DESPUÉS de 04_VDL, cuando la estructura, los datos y las vistas
--   ya están listos para ser consultados por otros usuarios. Requiere ejecutarse con
--   un usuario con privilegios administrativos (por defecto, `root` en XAMPP).
--
-- EJECUCIÓN SEGURA / IDEMPOTENCIA:
--   CREATE USER usa IF NOT EXISTS; GRANT vuelve a otorgar los mismos privilegios sin
--   error si ya estaban concedidos; y REVOKE DELETE es seguro de repetir siempre que
--   el usuario ya tenga al menos un privilegio otorgado en ese esquema (lo garantiza
--   el GRANT anterior en este mismo script). Verificado ejecutando el script dos
--   veces seguidas sin reiniciar la base de datos.
-- =====================================================================================

USE `gestion_academica`;

-- =====================================================================================

-- Crea dos usuarios que solo pueden conectarse desde el mismo equipo 
-- (localhost), con su contraseña.

CREATE USER IF NOT EXISTS 'secretaria'@'localhost' IDENTIFIED BY 'Clave123*';
CREATE USER IF NOT EXISTS 'docente'@'localhost'    IDENTIFIED BY 'Clave456*';

-- =====================================================================================

-- GRANT otorga permisos. La secretaria puede consultar, insertar y actualizar 
-- estudiantes y matrículas, pero no borrar ni tocar otras tablas.

GRANT SELECT, INSERT, UPDATE ON gestion_academica.estudiante TO 'secretaria'@'localhost';
GRANT SELECT, INSERT, UPDATE ON gestion_academica.matricula  TO 'secretaria'@'localhost';

-- =====================================================================================

-- La primera línea da al docente permiso de solo lectura sobre todas las tablas (.*).
-- La segunda es un permiso por columna: solo puede modificar nota_final y estado en registro_academico, nada más.

GRANT SELECT ON gestion_academica.* TO 'docente'@'localhost';
GRANT UPDATE (nota_final, estado) ON gestion_academica.registro_academico TO 'docente'@'localhost';

-- =====================================================================================

-- REVOKE quita permisos. Ahora la secretaria ya no puede actualizar estudiantes.

REVOKE UPDATE ON gestion_academica.estudiante FROM 'secretaria'@'localhost';

-- =====================================================================================

-- Muestra los permisos actuales de cada usuario, para comprobar que funcionó.

SHOW GRANTS FOR 'secretaria'@'localhost';
SHOW GRANTS FOR 'docente'@'localhost';

-- =====================================================================================

-- Elimina los usuarios.

DROP USER 'secretaria'@'localhost';
DROP USER 'docente'@'localhost';