SELECT * FROM `7. limpieza`;
ALTER TABLE `7. limpieza` RENAME TO limpieza;

SELECT * FROM limpieza;

-- Comenzamos con el DATA CLEANING

USE new_schema;
SELECT * FROM limpieza;
-- Como constantemente estaremos utilizando este codigo para verificar, lo automatizaremos para evitar escribirlo siempre

DELIMITER //
CREATE PROCEDURE limp()
BEGIN 
	SELECT * FROM limpieza;
END // 
DELIMITER ;
CALL limp();

-- Como siguiente paso corregimos los errores en la columnas

ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_emp varchar (20) null;
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar (20) null;

-- Ahora vamos a verificar si hay valores duplicados

SELECT Id_emp, count(*) AS cantidad_duplicados
FROM limpieza
GROUP BY Id_emp
HAVING count(*) > 1;

-- Crear una tabla temporal sin los duplicados y luego hacerla real

RENAME TABLE limpieza to conduplicados;
CREATE TEMPORARY TABLE temp_limpieza AS
	SELECT DISTINCT * FROM conduplicados;
SELECT count(*) AS registros FROM conduplicados;
SELECT count(*) AS registros FROM temp_limpieza;

CREATE TABLE LIMPIEZA AS SELECT * FROM temp_limpieza;

-- Vemos que el comando automatizado funciona y modificamos los nombres de las tablas olvidados pero no el formato de nada.
SELECT * FROM LIMPIEZA;
CALL LIMP();

ALTER TABLE LIMPIEZA CHANGE COLUMN `Apellido` Last_name varchar (50) null;
ALTER TABLE limpieza CHANGE COLUMN `star_date` Start_date varchar (50) null;
ALTER TABLE LIMPIEZA CHANGE COLUMN `finish_date` Finish_date varchar (50) null;
ALTER TABLE LIMPIEZA CHANGE COLUMN `promotion_date` Promotion_date varchar (50) null;
ALTER TABLE LIMPIEZA CHANGE COLUMN `birth_date` Birth_date varchar (50) null;
ALTER TABLE LIMPIEZA CHANGE COLUMN `salary` Salary varchar (50) null;


-- Ahora verificamos los tipos de datos

DESCRIBE LIMPIEZA;

								-- lo QUE HACEMOS ES QUITAR LOS ESPACIOS, PERO ANTES DE ACTUALIZAR DEBEMOS VERIFICAR.

SELECT name
FROM LIMPIEZA 
WHERE Name LIKE ' %' OR Name LIKE '% ' OR Name LIKE '%  %';

SELECT name, TRIM(name) AS name
FROM limpieza
WHERE Name LIKE ' %' OR Name LIKE '% ' OR Name LIKE '%  %';  
								-- HABIENDO VERIFICADO PODEMOS PROCEDER A MODIFICAR DEFINITIVAMENTE.
UPDATE LIMPIEZA 
SET Name = TRIM(name) WHERE Name LIKE ' %' OR Name LIKE '% ' OR Name LIKE '%  %';
								-- VERIFICAMOS SI SE EJECUTO EL CAMBIO CON UN EJEMPLO CONCRETO. 
CALL limp();

				-- procedemos a hacer lo mismo con los apellidos

SELECT Last_name
FROM LIMPIEZA 
WHERE Last_name LIKE ' %' OR Last_name LIKE '% ' OR Last_name LIKE '%  %';

UPDATE LIMPIEZA 
SET Last_name = TRIM(Last_name) WHERE Last_name LIKE ' %' OR Last_name LIKE '% ' OR Last_name LIKE '%  %';

CALL limp();

		-- Aqui quitamos los dobles espacios en medio si es que hay de la columna AREA. Primero verificamos, y si esta bien, cambiamos y verificamos.

SELECT AREA, TRIM(REGEXP_REPLACE(AREA, '\\s+', ' ')) AS Ensayo
FROM LIMPIEZA;

UPDATE LIMPIEZA 
SET AREA = TRIM(REGEXP_REPLACE(AREA, '\\s+', ' '));

CALL LIMP();
ALTER TABLE LIMPIEZA CHANGE COLUMN `area` Area varchar (50) null;

-- AHORA MODIFICAMOS HOMBRE Y MUJER PARA QUE QUEDE EN INGLES

SELECT Gender, 
CASE 
	WHEN GENDER = 'hombre' THEN 'Male'
    WHEN GENDER = 'mujer' THEN 'Female'
    ELSE 'OTHER'
END AS ejemplo_gender
FROM LIMPIEZA;

UPDATE limpieza
SET Gender = 
CASE 
	WHEN GENDER = 'hombre' THEN 'Male'
    WHEN GENDER = 'mujer' THEN 'Female'
    ELSE 'OTHER'
END ;

CALL LIMP();

-- Ahora cambiamos el type, que es buleano donde si es 0 es trabajo hibrido y si es 1 es trabajo remoto

ALTER TABLE limpieza
MODIFY COLUMN type TEXT;

SELECT type, CASE 
	WHEN type = '0' THEN 'Hybrid'
    WHEN type = '1' THEN 'Remote'
END AS ejemplo_type
FROM LIMPIEZA;

UPDATE limpieza 
SET type = CASE 
	WHEN type = '0' THEN 'Hybrid'
    WHEN type = '1' THEN 'Remote'
    ELSE 'Other'
END;

call limp();

-- AHORA BUSCA MODIFICAR EL SALARIO QUE ESTA EN FORMATO texto a numero, pero primero modificar cosas.

SELECT salary, 
	CAST(trim(REPLACE (REPLACE(Salary, '$', ''), ',','')) AS DECIMAL (15,2)) AS SALARY_CORREGIDO
FROM LIMPIEZA ;

UPDATE LIMPIEZA 
SET SALARY = CAST(trim(REPLACE (REPLACE(Salary, '$', ''), ',','')) AS DECIMAL (15,2));

call limp();

alter table limpieza
modify column salary int null;
describe limpieza;

-- AHORA NOS TOCA MODIFICAR FECHAS. empezamos con birth_date.

SELECT birth_date
from limpieza;

SELECT Birth_date, CASE
	WHEN birth_date like '%/%' THEN date_format((str_to_date (Birth_date, '%m/%d/%Y')), '%Y-%m-%d' )
    WHEN birth_date like '%-%' THEN date_format((str_to_date (Birth_date, '%m-%d-%Y')), '%Y-%m-%d' )
    ELSE NULL
    END AS NEW_BIRTH_DATE
    FROM LIMPIEZA;
    
    -- cambiamos la forma en la que se da las fechas para unificar. 
    
    UPDATE limpieza
    SET birth_date = CASE
	WHEN birth_date like '%/%' THEN date_format((str_to_date (Birth_date, '%m/%d/%Y')), '%Y-%m-%d' )
    WHEN birth_date like '%-%' THEN date_format((str_to_date (Birth_date, '%m-%d-%Y')), '%Y-%m-%d' )
    ELSE NULL 
    END;
    
    call limp();
    
    -- cambiamos la forma en la que se da las fechas para unificar. 
    
    alter table limpieza
    modify column birth_date date;
    describe limpieza;
    
    -- ahora replicamos todo con start date

SELECT start_date
from limpieza;

SELECT start_date, CASE
	WHEN start_date like '%/%' THEN date_format((str_to_date (start_date, '%m/%d/%Y')), '%Y-%m-%d' )
    WHEN start_date like '%-%' THEN date_format((str_to_date (start_date, '%m-%d-%Y')), '%Y-%m-%d' )
    ELSE NULL
    END AS NEW_start_date
    FROM LIMPIEZA;

UPDATE limpieza
SET start_date = CASE
	WHEN start_date like '%/%' THEN date_format((str_to_date (start_date, '%m/%d/%Y')), '%Y-%m-%d' )
    WHEN start_date like '%-%' THEN date_format((str_to_date (start_date, '%m-%d-%Y')), '%Y-%m-%d' )
    ELSE NULL
    END;
    
    CALL LIMP();
    
	alter table limpieza
    modify column start_date date;
    describe limpieza;
    
    -- AHORA VAMOS A LA COLUMNA DE FINISH DATE DONDE LA FECHA ES MAS COMPLEJA
    
    SELECT FINISH_DATE
    FROM limpieza;
    
    SELECT Finish_date, STR_TO_DATE(Finish_date, '%Y-%m-%d %H:%i:%s') AS FECHA_FINAL
	FROM LIMPIEZA;
    
    SELECT Finish_date, date_format(str_to_Date(Finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') as new_finish_date
    from limpieza;
    
    ALTER TABLE limpieza 
    ADD COLUMN date_backup text;
    
    call limp();
    
    UPDATE limpieza set date_backup = Finish_date;
   
   SELECT Finish_date, str_to_date(Finish_date, '%Y-%m-%d %H:%i:%s UTC') AS FECHA_FINAL FROM LIMPIEZA;
    
	UPDATE LIMPIEZA SET Finish_date = STR_TO_DATE(Finish_date, '%Y-%m-%d %H:%i:%s UTC')
    WHERE finish_date <> '';
    
    SELECT Finish_date, date_format(str_to_Date(Finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') as new_finish_date
    from limpieza;
    
    -- #  ahora separaremos la fecha de la hora, para ello agregamos una columna
    
    ALTER TABLE LIMPIEZA  add column fecha date, ADD COLUMN hora time;
    
    alter table limpieza drop column date;
    alter table limpieza drop column hour;
    
    call limp ();
    
    UPDATE limpieza SET 
		fecha = date(finish_Date), 
		hora = time(finish_date)
	WHERE finish_date is not null and finish_Date <> '';
    
    update limpieza set 
    finish_Date = null where finish_Date = '';
    
    ALTER TABLE limpieza modify column finish_Date datetime;
    describe limpieza;
    
    -- ahora que hemos modificado todo en las fechas de forma correct, nos permite hacer calculos
    
    SELECT 
    concat(substring_index (name, ' ',1), "_", substring(last_name,1, 2), '.', substring(type,1,1), '@consulting.com') AS EMAIL
    FROM limpieza;
    
    CALL LIMP();
    
    ALTER TABLE LIMPIEZA ADD COLUMN EMAIL VARCHAR (100);
	
    UPDATE LIMPIEZA SET  
    EMAIL = concat(substring_index (name, ' ',1), "_", substring(last_name,1, 2), '.', substring(type,1,1), '@consulting.com') ;
        
    
    -- AHORA VAMOS A SELECCIONAR LO QUE REALMENTE QUEREMOS DE  LA TABLA, PARA GUARDARLO EN UNA TABLA FINAL
    
    SELECT Id_emp, Name, Last_name, Birth_date, Gender, Area, Salary, EMAIL, Finish_date FROM LIMPIEZA
    WHERE finish_date <= curdate() OR finish_date is null
    ORDER BY area, name;
    
    SELECT AREA, COUNT(*) AS cantidad_emp FROM LIMPIEZA
    GROUP BY area
    order by cantidad_emp DESC;
    
    CREATE TABLE tablaFinal AS 
    SELECT Id_emp, Name, Last_name, Birth_date, Gender, Area, Salary, EMAIL, Finish_date 
    FROM LIMPIEZA;
    
    
    
    






