-- =====================================================================================
-- 06_TCL — Transaction Control Language
-- Objetivo: agrupar operaciones relacionadas en transacciones que aseguren la
-- integridad de los datos (COMMIT/ROLLBACK/SAVEPOINT).
-- Equivalente al ejemplo de "registrar contratos y firmas" del resumen de comandos,
-- adaptado a "registrar una renta junto con los ejemplares que se lleva el cliente".
--
-- CÓMO SE EJECUTA:
--   Debe correrse AL FINAL, después de 05_DCL
-- =====================================================================================

USE `gestion_academica`;

-- =====================================================================================



-

-- Inicia la transacción: desde aquí los cambios son provisionales.

START TRANSACTION;

-- ---------------------------------------------------------------------------------

-- Matricula a Marta en el grupo 4.

INSERT INTO matricula (id_estudiante, id_grupo, fecha_matricula)
VALUES (3, 4, '2026-01-23');

-- ---------------------------------------------------------------------------------

-- Descuenta un cupo del grupo. La condición cupo_disponible > 0 evita que el cupo quede negativo.

UPDATE grupo SET cupo_disponible = cupo_disponible - 1
WHERE id_grupo = 4 AND cupo_disponible > 0;

-- =====================================================================================

-- Crea un punto de control con nombre. Podrás volver hasta aquí sin deshacer todo.

SAVEPOINT matricula_marta;

-- ---------------------------------------------------------------------------------

-- Matricula a Luis y descuenta otro cupo. Supongamos que fue un error.

INSERT INTO matricula (id_estudiante, id_grupo, fecha_matricula)
VALUES (2, 4, '2026-01-23');
UPDATE grupo SET cupo_disponible = cupo_disponible - 1 WHERE id_grupo = 4;

-- =====================================================================================

-- Deshace solo lo hecho después del savepoint: la matrícula de Luis y su descuento de 
-- cupo desaparecen, pero la de Marta se conserva.

ROLLBACK TO matricula_marta;

-- ---------------------------------------------------------------------------------

-- Confirma y guarda definitivamente lo que quedó. Si usas ROLLBACK; en su lugar, 
-- se deshace toda la transacción.

COMMIT;