USE GD2C2021

--DROP PREVENTIVO DE FUNCIONES------------------------------------------------------------

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'getAgeRange')
	DROP FUNCTION los_desnormalizados.getAgeRange

--DROP PREVENTIVO DE TABLAS------------------------------------------------------------
IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CAMION')
DROP TABLE  los_desnormalizados.BI_DIM_CAMION

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TIEMPO')
DROP TABLE  los_desnormalizados.BI_DIM_TIEMPO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MODELO')
DROP TABLE  los_desnormalizados.BI_DIM_MODELO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MARCA')
DROP TABLE  los_desnormalizados.BI_DIM_MARCA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TALLER')
DROP TABLE  los_desnormalizados.BI_DIM_TALLER

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_RECORRIDO')
DROP TABLE  los_desnormalizados.BI_DIM_RECORRIDO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TIPO_TAREA')
DROP TABLE  los_desnormalizados.BI_DIM_TIPO_TAREA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CHOFER')
DROP TABLE  los_desnormalizados.BI_DIM_CHOFER

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MECANICO')
DROP TABLE  los_desnormalizados.BI_DIM_MECANICO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_FACT_ARREGLO_CAMION')
DROP TABLE los_desnormalizados.BI_FACT_ARREGLO_CAMION

--CREACIÓN DE FUNCIONES AUXILIARES------------------------------------------------------------
GO
CREATE FUNCTION los_desnormalizados.getAgeRange (@dateofbirth datetime2(3)) --Recibe una fecha de nacimiento por parámetro y 
RETURNS varchar(10)												   --devuelve la edad actual de la persona		
AS
BEGIN
	DECLARE @age int;
	DECLARE @returnvalue varchar(10);

IF (MONTH(@dateofbirth)!=MONTH(GETDATE()))
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;
ELSE IF(DAY(@dateofbirth) > DAY(GETDATE()))
	SET @age = (DATEDIFF(MONTH, @dateofbirth, GETDATE())/12)-1;
ELSE 
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;

IF (@age > 17 AND @age <31)
BEGIN
	SET @returnvalue = '[18 - 30]';
END
ELSE IF (@age > 30 AND @age <51)
BEGIN
	SET @returnvalue = '[31 - 50]';
END
ELSE IF(@age > 50)
BEGIN
	SET @returnvalue = '+50';
END

	RETURN @returnvalue;
END

GO

--Creación y migración de las tablas de las dimensiones


--DIMENSION TIEMPO 
CREATE TABLE los_desnormalizados.BI_DIM_TIEMPO(
	tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
	anio SMALLDATETIME,
	cuatrimestre INT 
)

--DE DONDE SACAMOS LA FECHA? ~(°-°~) ~(°-°)~ (~°-°)~ 
INSERT INTO los_desnormalizados.BI_DIM_TIEMPO (anio, cuatrimestre)
	SELECT year(inicio_real), DATEPART(quarter,inicio_real) from los_desnormalizados.Tarea_x_orden
	UNION 
	SELECT year(fin_real), DATEPART(quarter,fin_real) from los_desnormalizados.Tarea_x_orden

--DIMENSION CAMION
CREATE TABLE los_desnormalizados.BI_DIM_CAMION (

	camion_id INT IDENTITY(1,1) PRIMARY KEY, 
	patente NVARCHAR(255) NOT NULL,
	chasis NVARCHAR(255) NOT NULL,
	motor NVARCHAR(255) NOT NULL,
	fecha_alta DATETIME2(3) NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_CAMION( patente, chasis, motor,fecha_alta)
	SELECT patente, chasis, motor, fecha_alta from los_desnormalizados.Camion


--DIMENSION MARCA
CREATE TABLE los_desnormalizados.BI_DIM_MARCA(
	marca_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_MARCA(nombre)
	SELECT nombre from los_desnormalizados.Marca

--DIMENSION MODELO
CREATE TABLE los_desnormalizados.BI_DIM_MODELO(
	modelo_id INT IDENTITY(1,1) PRIMARY KEY,
	modelo_descripcion NVARCHAR(255) NOT NULL,
	velocidad_max INT NOT NULL,
	capacidad_tanque INT NOT NULL,
	capacidad_carga INT NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_MODELO(modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga)
	SELECT modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga FROM los_desnormalizados.Modelo

--DIMENSION TALLER
CREATE TABLE los_desnormalizados.BI_DIM_TALLER(
	taller_id INT PRIMARY KEY, 
	nombre NVARCHAR(255) NOT NULL,
	telefono DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	mail NVARCHAR(255) NOT NULL,
)


INSERT INTO los_desnormalizados.BI_DIM_TALLER (taller_id, nombre, telefono, direccion, mail) 
	SELECT taller_id, nombre, telefono, direccion, mail FROM los_desnormalizados.Taller

--DIMENSION TIPO_TAREA
CREATE TABLE los_desnormalizados.BI_DIM_TIPO_TAREA(
	tipo_tarea_id INT PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)


INSERT INTO los_desnormalizados.BI_DIM_TIPO_TAREA (tipo_tarea_id, descripcion) 
	SELECT tipo_tarea_id, descripcion FROM los_desnormalizados.Tipo_tarea

--DIMENSION RECORRIDO
CREATE TABLE los_desnormalizados.BI_DIM_RECORRIDO (
	recorrido_id INT PRIMARY KEY,
	km_recorridos INT		NOT NULL,
	precio DECIMAL(18,2)	NOT NULL,
)

INSERT INTO los_desnormalizados.BI_DIM_RECORRIDO (recorrido_id, km_recorridos, precio) 
	SELECT recorrido_id, km_recorridos, precio FROM los_desnormalizados.Recorrido

--DIMENSION CHOFER
CREATE TABLE los_desnormalizados.BI_DIM_CHOFER(
	legajo	INT PRIMARY KEY,
	nombre NVARCHAR(255)	NOT NULL,
	apellido NVARCHAR(255)	NOT NULL,
	dni DECIMAL(18,0)		NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT			NOT NULL,
	mail NVARCHAR(255)		NOT NULL,
	fecha_nac DATETIME2(3)	NOT NULL,
	costo_hora INT			NOT NULL,
	rango_edad NVARCHAR(10) NOT NULL,
)

INSERT INTO los_desnormalizados.BI_DIM_CHOFER
	(legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nac, costo_hora, rango_edad) 
	SELECT  
	legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nac, costo_hora, los_desnormalizados.getAgeRange(fecha_nac) 
	FROM los_desnormalizados.Chofer

--DIMENSION MECANICO
CREATE TABLE los_desnormalizados.BI_DIM_MECANICO(
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
	apellido NVARCHAR(255) NOT NULL,
	dni DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	fecha_nacimiento DATETIME2(3) NOT NULL,
	costo_hora INT NOT NULL,
	rango_edad NVARCHAR(10) NOT NULL,
)

INSERT INTO los_desnormalizados.BI_DIM_MECANICO
	(legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nacimiento, costo_hora, rango_edad) 
	SELECT  
	legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nacimiento, costo_hora, los_desnormalizados.getAgeRange(fecha_nacimiento) 
	FROM los_desnormalizados.Mecanico

--DIMENSION MATERIAL (agregada)
CREATE TABLE los_desnormalizados.BI_DIM_MATERIAL (
    material_id INT PRIMARY KEY,
	material_cod NVARCHAR(100) NOT NULL,
    material_descripcion NVARCHAR(255) NOT NULL,
    precio DECIMAL(18, 2) NOT NULL,
)

INSERT INTO los_desnormalizados.BI_DIM_MATERIAL (material_id, material_cod, material_descripcion, precio)
	SELECT material_id, material_cod, material_descripcion, precio FROM los_desnormalizados.Material





--Creación y migración de las tablas de hechos
CREATE TABLE los_desnormalizados.BI_FACT_ARREGLO_CAMION (
	taller_id int,
	modelo_id int,
	tarea_id int,
	camion_id int,
	mecanico_legajo int,
	marca_id int,
	tiempo_id int,
	tiempo_arreglo int, 
	PRIMARY KEY (taller_id, modelo_id, tarea_id, camion_id, mecanico_legajo, marca_id, tiempo_id, tiempo_arreglo)
)

INSERT INTO los_desnormalizados.BI_FACT_ARREGLO_CAMION (taller_id, modelo_id, tarea_id, camion_id, mecanico_legajo, marca_id, tiempo_id, tiempo_arreglo)
	SELECT DISTINCT bt.taller_id, modelo.modelo_id, txo.tarea_id, cami.camion_id, bm.legajo, marca_id, bti.tiempo_id, tiempo_real
	FROM los_desnormalizados.Tarea_x_orden txo
	JOIN los_desnormalizados.BI_DIM_MECANICO bm on bm.legajo = txo.mecanico_id
	JOIN los_desnormalizados.Mecanico m on m.legajo = bm.legajo
	JOIN los_desnormalizados.BI_DIM_TALLER bt on m.taller_id = bt.taller_id
	JOIN los_desnormalizados.Orden_trabajo ot on ot.orden_id = txo.orden_id 
	JOIN los_desnormalizados.Camion cami on cami.camion_id = ot.camion_id
	JOIN los_desnormalizados.Modelo modelo on modelo.modelo_id = cami.modelo_id  
	JOIN los_desnormalizados.BI_DIM_TIEMPO bti on bti.anio = year(txo.inicio_real) and bti.cuatrimestre = DATEPART(quarter,txo.inicio_real)
	ORDER BY taller_id, modelo_id, tarea_id, camion_id, marca_id, tiempo_id

CREATE TABLE los_desnormalizados.BI_FACT_INFO_VIAJE (
	viaje_id INT,
	legajo INT, 
	camion_id INT,
	paquete_id INT,
	tipo_paquete_id INT,
	recorrido_id INT
	PRIMARY KEY (recorrido_id, tipo_paquete_id, viaje_id, camion_id, legajo, paquete_id)
)

INSERT INTO los_desnormalizados.BI_FACT_INFO_VIAJE (recorrido_id, tipo_paquete_id, viaje_id, camion_id, legajo, paquete_id)
	SELECT DISTINCT v.recorrido_id, tipo_paquete_id, v.viaje_id, v.camion_id, legajo, p.paquete_id
	FROM los_desnormalizados.Viaje_x_paquete vxp
	JOIN los_desnormalizados.Viaje v ON vxp.viaje_id = v.viaje_id
	JOIN los_desnormalizados.BI_DIM_CAMION bc ON v.camion_id = bc.camion_id
	JOIN los_desnormalizados.BI_DIM_CHOFER bcho ON v.chofer = bcho.legajo
	JOIN los_desnormalizados.BI_DIM_RECORRIDO brr ON v.recorrido_id = brr.recorrido_id
	JOIN los_desnormalizados.Paquete p ON vxp.paquete_id = p.paquete_id

