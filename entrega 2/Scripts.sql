BEGIN TRANSACTION

IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'los_desnormalizados'))
  BEGIN
      exec ('CREATE SCHEMA [los_desnormalizados]');
   END

CREATE TABLE los_desnormalizados.Chofer (
	legajo	INT PRIMARY KEY,
	nombre NVARCHAR(255)	NOT NULL,
	apellido NVARCHAR(255)	NOT NULL,
	dni DECIMAL(18,0)		NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT			NOT NULL,
	mail NVARCHAR(255)		NOT NULL,
	fecha_nac DATETIME2(3)	NOT NULL,
	costo_hora INT			NOT NULL,
)

CREATE TABLE los_desnormalizados.Ciudad (
	ciudad_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Recorrido (
	recorrido_id INT IDENTITY(1,1) PRIMARY KEY,
	ciudad_origen_id INT	NOT NULL,
	ciudad_destino_id INT	NOT NULL,
	km_recorridos INT		NOT NULL,
	precio DECIMAL(18,2)	NOT NULL,
	FOREIGN KEY (ciudad_destino_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id),
	FOREIGN KEY (ciudad_destino_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id)
)

CREATE TABLE los_desnormalizados.Tipo_paquete (
	tipo_paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	paquete_descripcion NVARCHAR(255)	NOT NULL,
	paquete_largo_max DECIMAL(18,2)		NOT NULL,
	paquete_peso_max DECIMAL(18,2)		NOT NULL,
	paquete_ancho_max DECIMAL(18,2)		NOT NULL,
	paquete_precio DECIMAL(18,2)		NOT NULL,
	paquete_alto_max DECIMAL(18,2)		NOT NULL
)

CREATE TABLE los_desnormalizados.Marca (
	marca_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Modelo(
	modelo_id INT IDENTITY(1,1) PRIMARY KEY,
	marca_id INT NOT NULL,
	modelo_descripcion NVARCHAR(255) NOT NULL,
	velocidad_max INT NOT NULL,
	capacidad_tanque INT NOT NULL,
	capacidad_carga INT NOT NULL,
	FOREIGN KEY (marca_id) REFERENCES los_desnormalizados.Marca (marca_id)
)

CREATE TABLE los_desnormalizados.Taller(
	taller_id INT IDENTITY(1,1) PRIMARY KEY, 
	ciudad_id INT NOT NULL,
	nombre NVARCHAR(255) NOT NULL,
	telefono DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	FOREIGN KEY (ciudad_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id)
)
-- TODO: Saco que se autogenere el id pq ya tiene el codigo
CREATE TABLE  los_desnormalizados.Material (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
	material_cod NVARCHAR(100) NOT NULL,
    material_descripcion NVARCHAR(255) NOT NULL,
    precio DECIMAL(18, 2) NOT NULL,
)

CREATE TABLE los_desnormalizados.Tipo_tarea (
	tipo_tarea_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

-- TODO: Ver que hacer con la cantidad de materiales por tarea
CREATE TABLE  los_desnormalizados.Tarea (
    tarea_id INT PRIMARY KEY,
    tipo_tarea_id INT NOT NULL,
    tiempo_estimado INT NOT NULL, 
    descripcion NVARCHAR(255) NOT NULL,
	FOREIGN KEY (tipo_tarea_id) REFERENCES los_desnormalizados.Tipo_tarea (tipo_tarea_id)
)

CREATE TABLE los_desnormalizados.Camion(
	camion_id INT IDENTITY(1,1) PRIMARY KEY, 
	modelo_id INT NOT NULL,
	patente NVARCHAR(255) NOT NULL,
	chasis NVARCHAR(255) NOT NULL,
	motor NVARCHAR(255) NOT NULL,
	fecha_alta DATETIME2(3) NOT NULL,
	FOREIGN KEY (modelo_id) REFERENCES los_desnormalizados.Modelo (modelo_id)
)

CREATE TABLE los_desnormalizados.Viaje (
	viaje_id INT IDENTITY(1,1) PRIMARY KEY,
	camion_id INT NOT NULL,
	recorrido_id INT NOT NULL,
	chofer INT NOT NULL,
	fecha_inicio DATETIME2(7) NOT NULL,
	fecha_fin DATETIME2(3) NULL,
	lts_combustible DECIMAL(18,2) NULL, 
	FOREIGN KEY (camion_id)	REFERENCES los_desnormalizados.Camion (camion_id),
	FOREIGN KEY (chofer)	REFERENCES los_desnormalizados.Chofer (legajo),
	FOREIGN KEY (recorrido_id) REFERENCES los_desnormalizados.Recorrido (recorrido_id)
)

CREATE TABLE los_desnormalizados.Paquete (
	paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	tipo_paquete_id INT NOT NULL,
	FOREIGN KEY (tipo_paquete_id) REFERENCES los_desnormalizados.Tipo_paquete(tipo_paquete_id)
)

CREATE TABLE los_desnormalizados.Viaje_x_paquete (
	paquete_id INT NOT NULL,
	viaje_id INT NOT NULL,
	cantidad INT NOT NULL,
	PRIMARY KEY (paquete_id, viaje_id),
	FOREIGN KEY (paquete_id) REFERENCES los_desnormalizados.Paquete(paquete_id),
	FOREIGN KEY (viaje_id) REFERENCES los_desnormalizados.Viaje(viaje_id)
)

CREATE TABLE los_desnormalizados.Estado (
	estado_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Orden_trabajo (
	orden_id INT IDENTITY(1,1) PRIMARY KEY,
	fecha_generacion NVARCHAR(255) NOT NULL,
	camion_id INT NOT NULL,
	estado_id INT NOT NULL,
	FOREIGN KEY (camion_id) REFERENCES los_desnormalizados.Camion(camion_id),
	FOREIGN KEY (estado_id) REFERENCES los_desnormalizados.Estado(estado_id)
)

CREATE TABLE los_desnormalizados.Mecanico(
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
	apellido NVARCHAR(255) NOT NULL,
	dni DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	fecha_nacimiento DATETIME2(3) NOT NULL,
	costo_hora INT NOT NULL,
	taller_id INT NOT NULL,
	FOREIGN KEY (taller_id) REFERENCES los_desnormalizados.Taller (taller_id)
)

CREATE TABLE los_desnormalizados.Tarea_x_orden(
	tarea_x_orden_id INT IDENTITY(1,1) PRIMARY KEY,
    orden_id INT,
    tarea_id INT,
    mecanico_id INT NOT NULL,
    inicio_planificado DATETIME2 NOT NULL,
    inicio_real DATETIME2 NOT NULL,
    fin_real DATETIME2 NOT NULL,
	tiempo_real INT NOT NULL,
    FOREIGN KEY (tarea_id) references los_desnormalizados.Tarea (tarea_id),
    FOREIGN KEY (mecanico_id) references los_desnormalizados.Mecanico (legajo),
    FOREIGN KEY (orden_id) references  los_desnormalizados.Orden_trabajo (orden_id)
)

CREATE TABLE  los_desnormalizados.Material_x_tarea(
    material_id INT NOT NULL,
    tarea_id INT NOT NULL, 
	cant_material INT NOT NULL,
	PRIMARY KEY (material_id, tarea_id),
    FOREIGN KEY (material_id) REFERENCES  los_desnormalizados.Material (material_id),
    FOREIGN KEY (tarea_id) REFERENCES  los_desnormalizados.Tarea (tarea_id)
)

COMMIT TRANSACTION

