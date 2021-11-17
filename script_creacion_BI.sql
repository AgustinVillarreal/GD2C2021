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

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TAREA')
DROP TABLE  los_desnormalizados.BI_DIM_TAREA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CHOFER')
DROP TABLE  los_desnormalizados.BI_DIM_CHOFER

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MECANICO')
DROP TABLE  los_desnormalizados.BI_DIM_MECANICO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MATERIAL')
DROP TABLE  los_desnormalizados.BI_DIM_MATERIAL

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_VIAJE_X_PAQUETE')
DROP TABLE los_desnormalizados.BI_DIM_VIAJE_X_PAQUETE

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_FACT_ARREGLO_CAMION')
DROP TABLE los_desnormalizados.BI_FACT_ARREGLO_CAMION

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_FACT_INFO_VIAJE')
DROP TABLE los_desnormalizados.BI_FACT_INFO_VIAJE

--CREACI�N DE FUNCIONES AUXILIARES------------------------------------------------------------
GO
CREATE FUNCTION los_desnormalizados.getAgeRange (@dateofbirth datetime2(3)) --Recibe una fecha de nacimiento por par�metro y 
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

--Creaci�n y migraci�n de las tablas de las dimensiones


--DIMENSION TIEMPO 
CREATE TABLE los_desnormalizados.BI_DIM_TIEMPO(
	tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
	anio SMALLDATETIME,
	cuatrimestre INT 
)

--DE DONDE SACAMOS LA FECHA? ~(�-�~) ~(�-�)~ (~�-�)~ 
INSERT INTO los_desnormalizados.BI_DIM_TIEMPO (anio, cuatrimestre)
	SELECT year(inicio_real), DATEPART(quarter,inicio_real) from los_desnormalizados.Tarea_x_orden
	UNION 
	SELECT year(fin_real), DATEPART(quarter,fin_real) from los_desnormalizados.Tarea_x_orden

--DIMENSION CAMION
CREATE TABLE los_desnormalizados.BI_DIM_CAMION (

	camion_id INT PRIMARY KEY, 
	patente NVARCHAR(255) NOT NULL,
	chasis NVARCHAR(255) NOT NULL,
	motor NVARCHAR(255) NOT NULL,
	fecha_alta DATETIME2(3) NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_CAMION(camion_id, patente, chasis, motor,fecha_alta)
	SELECT camion_id, patente, chasis, motor, fecha_alta from los_desnormalizados.Camion

--DIMENSION MARCA
CREATE TABLE los_desnormalizados.BI_DIM_MARCA(
	marca_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_MARCA(nombre)
	SELECT nombre from los_desnormalizados.Marca

--DIMENSION MODELO
CREATE TABLE los_desnormalizados.BI_DIM_MODELO(
	modelo_id INT PRIMARY KEY,
	modelo_descripcion NVARCHAR(255) NOT NULL,
	velocidad_max INT NOT NULL,
	capacidad_tanque INT NOT NULL,
	capacidad_carga INT NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_MODELO(modelo_id, modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga)
	SELECT modelo_id, modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga FROM los_desnormalizados.Modelo

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
	ciudad_origen NVARCHAR(100) NOT NULL,
	ciudad_destino NVARCHAR(100) NOT NULL,
)

INSERT INTO los_desnormalizados.BI_DIM_RECORRIDO (recorrido_id, km_recorridos, precio, ciudad_origen, ciudad_destino) 
	SELECT recorrido_id, km_recorridos, precio, 
		(SELECT nombre FROM los_desnormalizados.Ciudad c WHERE r.ciudad_origen_id = c.ciudad_id), 
		(SELECT nombre FROM los_desnormalizados.Ciudad c WHERE r.ciudad_destino_id = c.ciudad_id)
	FROM los_desnormalizados.Recorrido r

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

--DIMENSION VIAJE_X_PAQUETE (Agregada)
CREATE TABLE los_desnormalizados.BI_DIM_VIAJE_X_PAQUETE (
    viaje_id INT,
	paquete_id INT,
    cantidad INT NOT NULL,
    precioTotal DECIMAL(18, 2) NOT NULL,
	PRIMARY KEY (viaje_id, paquete_id)
)

INSERT INTO los_desnormalizados.BI_DIM_VIAJE_X_PAQUETE (viaje_id, paquete_id, cantidad, precioTotal)
	SELECT viaje_id, paquete_id, cantidad, precioTotal FROM los_desnormalizados.Viaje_x_paquete


--DIMENSION TAREA 
CREATE TABLE los_desnormalizados.BI_DIM_TAREA (
	tarea_id INT PRIMARY KEY,
	descripcion NVARCHAR(100) NOT NULL
)

INSERT INTO los_desnormalizados.BI_DIM_TAREA (tarea_id, descripcion)
	SELECT tarea_id, t.descripcion
	FROM los_desnormalizados.Tarea t
	

--Creaci�n y migraci�n de las tablas de hechos
CREATE TABLE los_desnormalizados.BI_FACT_ARREGLO_CAMION (
	taller_id int,
	modelo_id int,
	tarea_id int,
	tipo_tarea_id int, 
	camion_id int,
	mecanico_legajo int,
	marca_id int,
	tiempo_id int,
	tiempo_plani int,
	tiempo_arreglo int, 
	cant_materiales int,
	material_id int,
	costo_mantenimiento DECIMAL (18,2)
	PRIMARY KEY (taller_id, modelo_id, tarea_id, tipo_tarea_id, camion_id, mecanico_legajo, marca_id, tiempo_id, material_id)
)

INSERT INTO los_desnormalizados.BI_FACT_ARREGLO_CAMION (taller_id, modelo_id, tarea_id, tipo_tarea_id, camion_id, mecanico_legajo, 
				marca_id, tiempo_id, tiempo_plani, tiempo_arreglo, cant_materiales, material_id, costo_mantenimiento)
	SELECT DISTINCT bt.taller_id, modelo.modelo_id, txo.tarea_id, tar.tipo_tarea_id, cami.camion_id, bm.legajo, marca_id, 
			bti.tiempo_id, tar.tiempo_estimado, tiempo_real, mate.cant_material, ma.material_id, 
				(SELECT SUM(bdm.precio) + SUM(bm.costo_hora)*tiempo_real*8  FROM los_desnormalizados.BI_DIM_MATERIAL bdm 
					where bdm.material_id = ma.material_id)
	FROM los_desnormalizados.Tarea_x_orden txo
	JOIN los_desnormalizados.BI_DIM_MECANICO bm on bm.legajo = txo.mecanico_id
	JOIN los_desnormalizados.Mecanico m on m.legajo = bm.legajo
	JOIN los_desnormalizados.BI_DIM_TALLER bt on m.taller_id = bt.taller_id
	JOIN los_desnormalizados.Orden_trabajo ot on ot.orden_id = txo.orden_id 
	JOIN los_desnormalizados.Camion cami on cami.camion_id = ot.camion_id
	JOIN los_desnormalizados.Modelo modelo on modelo.modelo_id = cami.modelo_id  
	JOIN los_desnormalizados.BI_DIM_TIEMPO bti on bti.anio = year(txo.inicio_real) and bti.cuatrimestre = DATEPART(quarter,txo.inicio_real)
	JOIN los_desnormalizados.BI_DIM_TAREA dt on txo.tarea_id = dt.tarea_id 
	JOIN los_desnormalizados.Tarea tar ON tar.tarea_id = dt.tarea_id
	JOIN los_desnormalizados.Material_x_tarea mate on mate.tarea_id = dt.tarea_id  
	JOIN los_desnormalizados.Material ma on ma.material_id = mate.material_id
	GROUP BY bt.taller_id, modelo.modelo_id, txo.tarea_id, tar.tipo_tarea_id, cami.camion_id, bm.legajo, marca_id, 
			bti.tiempo_id, tar.tiempo_estimado, tiempo_real, mate.cant_material, ma.material_id

CREATE TABLE los_desnormalizados.BI_FACT_INFO_VIAJE (
	viaje_id INT,
	legajo INT, 
	camion_id INT,
	paquete_id INT,
	tipo_paquete_id INT,
	recorrido_id INT, 
	tiempo_id INT,
	duracion_viaje INT,
	ingresos DECIMAL(18,2),
	costo DECIMAL(18,2)
	PRIMARY KEY (recorrido_id, tipo_paquete_id, viaje_id, camion_id, legajo, paquete_id, tiempo_id)
)


INSERT INTO los_desnormalizados.BI_FACT_INFO_VIAJE (recorrido_id, tipo_paquete_id, viaje_id, camion_id, legajo, paquete_id, 
		tiempo_id, duracion_viaje, ingresos, costo)
	SELECT DISTINCT v.recorrido_id, tipo_paquete_id, v.viaje_id, v.camion_id, legajo, p.paquete_id, bti.tiempo_id, 
		DATEDIFF(D, v.fecha_fin, v.fecha_fin), 

		(SELECT SUM(precioTotal)*vxp.cantidad + SUM(brr.precio) FROM los_desnormalizados.BI_DIM_VIAJE_X_PAQUETE bdvxp 
			WHERE bdvxp.paquete_id = p.paquete_id AND bdvxp.viaje_id = v.viaje_id), 

		(SELECT SUM(costo_hora)*DATEDIFF(D, v.fecha_fin, v.fecha_fin)*8 + SUM(v.lts_combustible)*100
				FROM los_desnormalizados.BI_DIM_CHOFER bdc WHERE bdc.legajo = bcho.legajo)
	FROM los_desnormalizados.Viaje_x_paquete vxp
	JOIN los_desnormalizados.Viaje v ON vxp.viaje_id = v.viaje_id
	JOIN los_desnormalizados.BI_DIM_CAMION bc ON v.camion_id = bc.camion_id
	JOIN los_desnormalizados.BI_DIM_CHOFER bcho ON v.chofer = bcho.legajo
	JOIN los_desnormalizados.BI_DIM_RECORRIDO brr ON v.recorrido_id = brr.recorrido_id
	JOIN los_desnormalizados.BI_DIM_TIEMPO bti on bti.anio = year(v.fecha_inicio) and bti.cuatrimestre = DATEPART(quarter,v.fecha_inicio)
	JOIN los_desnormalizados.Paquete p ON vxp.paquete_id = p.paquete_id
	GROUP BY v.recorrido_id, tipo_paquete_id, v.viaje_id, v.camion_id, legajo, p.paquete_id, bti.tiempo_id, 
		DATEDIFF(D, v.fecha_fin, v.fecha_fin), vxp.cantidad


-- VISTAS 
/*M�ximo tiempo fuera de servicio de cada cami�n por cuatrimestre 
Se entiende por fuera de servicio cuando el cami�n est� en el taller (tiene 
una OT) y no se encuentra disponible para un viaje. */

CREATE VIEW los_desnormalizados.BI_TIEMPO_FUERA_SERVICIO
AS 
	SELECT bc.patente, bti.cuatrimestre, max(bac.tiempo_arreglo) as tiempo_fuera_de_servicio
	FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION bac
	join los_desnormalizados.BI_DIM_TIEMPO bti on bti.tiempo_id = bac.tiempo_id
	JOIN los_desnormalizados.BI_DIM_CAMION bc ON bc.camion_id = bac.camion_id
	group by  bti.cuatrimestre, bac.camion_id, bc.patente
GO

--Desv�o promedio de cada tarea x taller (dif entre planificacion y ejecucion)

CREATE VIEW los_desnormalizados.BI_DESVIO_TAREA
AS
	SELECT taller_id, tarea_id, AVG(ABS(tiempo_arreglo-tiempo_plani)) as desvio_promedio
	FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION 
	group by taller_id, tarea_id
GO

-- Los 10 materiales m�s utilizados por taller 
CREATE VIEW los_desnormalizados.BI_10_MAS_USADOS
AS
	SELECT cami.material_id, cami.taller_id
	FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION cami
	WHERE material_id in (SELECT TOP 10 material_id
							FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION
							where cami.taller_id = taller_id
							group by material_id
							order by sum(cant_materiales) desc)
	group by taller_id, material_id
GO

--Costo promedio x rango etario de choferes. 

CREATE VIEW los_desnormalizados.BI_COSTO_CHOFERES
AS
	SELECT (SELECT SUM(costo_hora)
				from los_desnormalizados.BI_DIM_CHOFER
				where rango_edad = bcho.rango_edad)/ count(distinct bcho.legajo) as costo_promedio, bcho.rango_edad
	FROM los_desnormalizados.BI_FACT_INFO_VIAJE bvi
	JOIN los_desnormalizados.BI_DIM_CHOFER bcho on bcho.legajo = bvi.legajo 
	group by bcho.rango_edad
GO

/*Costo total de mantenimiento por cami�n, por taller, por cuatrimestre.
Se entiende por costo de mantenimiento el costo de materiales + el costo
de mano de obra insumido en cada tarea (correctivas y preventivas)*/
CREATE VIEW los_desnormalizados.BI_COSTO_MANTENIMIENTO
AS
	SELECT bc.patente, bt.nombre, bdt.cuatrimestre, (SELECT SUM(precio) 
				FROM los_desnormalizados.BI_DIM_MATERIAL bm WHERE bm.material_id = bac.material_id) 
				+ (SELECT SUM(costo_hora)*tiempo_arreglo FROM los_desnormalizados.BI_DIM_MECANICO bm 
				WHERE bm.legajo = bac.mecanico_legajo GROUP BY legajo) as costo_total
	FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION bac
	JOIN los_desnormalizados.BI_DIM_CAMION bc ON bac.camion_id = bc.camion_id
	JOIN los_desnormalizados.BI_DIM_TALLER bt ON bt.taller_id = bac.taller_id
	JOIN los_desnormalizados.BI_DIM_TIEMPO bdt ON bdt.tiempo_id = bac.tiempo_id
	GROUP BY bc.camion_id, bt.taller_id, material_id, mecanico_legajo, tiempo_arreglo, bc.patente, bt.nombre, bdt.cuatrimestre
GO



/*Las 5 tareas que m�s se realizan por modelo de cami�n.*/

CREATE VIEW los_desnormalizados.BI_TAREAS_MAS_REALIZADAS_X_MODELO
AS
	--SELECT modelo_id, (SELECT TOP 5 descripcion FROM los_desnormalizados.BI_DIM_TAREA dt WHERE dt.tarea_id = bac.tarea_id) 
	SELECT bm.modelo_descripcion, dt.descripcion 
	FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION bac
	JOIN los_desnormalizados.BI_DIM_TAREA dt ON dt.tarea_id = bac.tarea_id
	JOIN los_desnormalizados.BI_DIM_MODELO bm ON bm.modelo_id = bac.modelo_id
	WHERE bac.tarea_id IN (SELECT TOP 5 bac2.tarea_id FROM los_desnormalizados.BI_FACT_ARREGLO_CAMION bac2 
								WHERE bac.modelo_id = bac2.modelo_id
								GROUP BY bac2.tarea_id
								ORDER BY SUM(bac2.tarea_id) DESC)
	GROUP BY bm.modelo_descripcion, dt.descripcion 
GO

/*Facturaci�n total por recorrido por cuatrimestre. (En funci�n de la cantidad
y tipo de paquetes que transporta el cami�n y el recorrido)*/

CREATE VIEW los_desnormalizados.BI_FACTURACION_X_RECORRIDO
AS
	SELECT bdr.ciudad_origen, bdr.ciudad_destino, bdt.cuatrimestre ,(
		SELECT SUM(precioTotal) FROM los_desnormalizados.BI_DIM_VIAJE_X_PAQUETE vxp 
		WHERE vxp.viaje_id = biv.viaje_id AND vxp.paquete_id = biv.paquete_id) as facturacion_total
		FROM los_desnormalizados.BI_FACT_INFO_VIAJE biv 
		JOIN los_desnormalizados.BI_DIM_RECORRIDO bdr ON bdr.recorrido_id = biv.recorrido_id
		JOIN los_desnormalizados.BI_DIM_TIEMPO bdt ON bdt.tiempo_id = biv.tiempo_id
GO

/*Ganancia por cami�n (Ingresos � Costo de viaje � Costo de mantenimiento)
o Ingresos: en funci�n de la cantidad y tipo de paquetes que
transporta el cami�n y el recorrido.
o Costo de viaje: costo del chofer + el costo de combustible.
Tomar precio por lt de combustible $100.-
o Costo de mantenimiento: costo de materiales + costo de mano de
obra.*/

--TODO: Le agregue al subselect de ingresos SUM(precioTotal)*CANTIDAD (nos faltaba multiplicar con cantidad) si no lo haces queda todo negativo xd
--Revisar pq me parece que esta mal
CREATE VIEW los_desnormalizados.BI_GANANCIA_X_CAMION
AS
	SELECT bc.patente, SUM(bip.ingresos - bip.costo - bac.costo_mantenimiento)
	FROM los_desnormalizados.BI_FACT_INFO_VIAJE bip
	JOIN los_desnormalizados.BI_FACT_ARREGLO_CAMION bac ON bip.camion_id = bac.camion_id
	JOIN los_desnormalizados.BI_DIM_CAMION bc ON bc.camion_id = bip.camion_id
	JOIN los_desnormalizados.BI_DIM_RECORRIDO bdr ON bdr.recorrido_id = bip.recorrido_id
	GROUP BY bc.patente
GO