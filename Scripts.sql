BEGIN TRANSACTION

CREATE TABLE gd_esquema.Chofer (
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

CREATE TABLE gd_esquema.Ciudad (
	ciudad_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE gd_esquema.Recorrido (
	recorrido_id INT IDENTITY(1,1) PRIMARY KEY,
	ciudad_origen_id INT	NOT NULL,
	ciudad_destino_id INT	NOT NULL,
	km_recorridos INT		NOT NULL,
	precio DECIMAL(18,2)	NOT NULL,
	FOREIGN KEY (ciudad_destino_id) REFERENCES gd_esquema.Ciudad (ciudad_id),
	FOREIGN KEY (ciudad_destino_id) REFERENCES gd_esquema.Ciudad (ciudad_id)
)

CREATE TABLE gd_esquema.Tipo_paquete (
	tipo_paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	paquete_descripcion NVARCHAR(255)	NOT NULL,
	paquete_largo_max DECIMAL(18,2)		NOT NULL,
	paquete_peso_max DECIMAL(18,2)		NOT NULL,
	paquete_ancho_max DECIMAL(18,2)		NOT NULL,
	paquete_precio DECIMAL(18,2)		NOT NULL,
	paquete_alto_max DECIMAL(18,2)		NOT NULL
)

CREATE TABLE gd_esquema.Marca (
	marca_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE gd_esquema.Modelo(
	modelo_id INT IDENTITY(1,1) PRIMARY KEY,
	marca_id INT NOT NULL,
	modelo_descripcion NVARCHAR(255) NOT NULL,
	velocidad_max INT NOT NULL,
	capacidad_tanque INT NOT NULL,
	capacidad_carga INT NOT NULL,
	FOREIGN KEY (marca_id) REFERENCES gd_esquema.Marca (marca_id)
)

CREATE TABLE gd_esquema.Taller(
	taller_id INT IDENTITY(1,1) PRIMARY KEY, 
	ciudad_id INT NOT NULL,
	nombre NVARCHAR(255) NOT NULL,
	teléfono DECIMAL(18,0) NOT NULL,
	dirección NVARCHAR(255) NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	FOREIGN KEY (ciudad_id) REFERENCES gd_esquema.Ciudad (ciudad_id)
)

CREATE TABLE  gd_esquema.Material (
    material_id INT IDENTITY(1,1) PRIMARY KEY, 
    material_detalle NVARCHAR(255) NOT NULL,
    precio DECIMAL(18, 2) NOT NULL,
)

CREATE TABLE gd_esquema.Tipo_tarea (
	tipo_tarea_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

CREATE TABLE  gd_esquema.Tarea (
    tarea_id INT IDENTITY(1,1) PRIMARY KEY,
    tipo_tarea_id INT NOT NULL,
    tiempo_estimado INT NOT NULL, 
    descripcion NVARCHAR(255) NOT NULL,
	FOREIGN KEY (tipo_tarea_id) REFERENCES gd_esquema.Tipo_tarea (tipo_tarea_id)
)

CREATE TABLE gd_esquema.Camion(
	camion_id INT IDENTITY(1,1) PRIMARY KEY, 
	modelo_id INT NOT NULL,
	patente NVARCHAR(255) NOT NULL,
	chasis NVARCHAR(255) NOT NULL,
	motor NVARCHAR(255) NOT NULL,
	fecha_alta DATETIME2(3) NOT NULL,
	FOREIGN KEY (modelo_id) REFERENCES gd_esquema.Modelo (modelo_id)
)

CREATE TABLE gd_esquema.Viaje (
	viaje_id INT IDENTITY(1,1) PRIMARY KEY,
	camion_id INT NOT NULL,
	recorrido_id INT NOT NULL,
	chofer INT NOT NULL,
	fecha_inicio DATETIME2(7) NOT NULL,
	fecha_fin DATETIME2(3) NOT NULL,
	lts_combustible DECIMAL(18,2) NOT NULL,
	FOREIGN KEY (camion_id)	REFERENCES gd_esquema.Camion (camion_id),
	FOREIGN KEY (chofer)	REFERENCES gd_esquema.Chofer (legajo),
	FOREIGN KEY (recorrido_id) REFERENCES gd_esquema.Recorrido (recorrido_id)
)

CREATE TABLE gd_esquema.Paquete (
	paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	tipo_paquete_id INT NOT NULL,
	FOREIGN KEY (tipo_paquete_id) REFERENCES gd_esquema.Tipo_paquete(tipo_paquete_id)
)

CREATE TABLE gd_esquema.Viaje_x_paquete (
	paquete_id INT NOT NULL,
	viaje_id INT NOT NULL,
	cantidad INT NOT NULL,
	PRIMARY KEY (paquete_id, viaje_id),
	FOREIGN KEY (paquete_id) REFERENCES gd_esquema.Paquete(paquete_id),
	FOREIGN KEY (viaje_id) REFERENCES gd_esquema.Viaje(viaje_id)
)

CREATE TABLE gd_esquema.Estado (
	estado_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

CREATE TABLE gd_esquema.Orden_trabajo (
	orden_id INT IDENTITY(1,1) PRIMARY KEY,
	fecha_generacion NVARCHAR(255) NOT NULL,
	camion_id INT NOT NULL,
	estado_id INT NOT NULL,
	FOREIGN KEY (camion_id) REFERENCES gd_esquema.Camion(camion_id),
	FOREIGN KEY (estado_id) REFERENCES gd_esquema.Estado(estado_id)
)

CREATE TABLE gd_esquema.Mecanico(
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
	apellido NVARCHAR(255) NOT NULL,
	dni DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	teléfono INT NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	fecha_nacimiento DATETIME2(3) NOT NULL,
	costo_hora INT NOT NULL,
	taller_id INT NOT NULL,
	FOREIGN KEY (taller_id) REFERENCES gd_esquema.Taller (taller_id)
)

CREATE TABLE gd_esquema.Tarea_x_orden(
    orden_id INT,
    tarea_id INT,
    mecanico_id INT NOT NULL,
    inicio_planificado DATETIME2 NOT NULL,
    inicio_real DATETIME2 NOT NULL,
    fin_real DATETIME2 NOT NULL,
    PRIMARY KEY (orden_id, tarea_id),
    FOREIGN KEY (tarea_id) references gd_esquema.Tarea (tarea_id),
    FOREIGN KEY (mecanico_id) references gd_esquema.Mecanico (legajo),
    FOREIGN KEY (orden_id) references  gd_esquema.Orden_trabajo (orden_id)
)

CREATE TABLE  gd_esquema.Material_x_tarea(
    material_id INT NOT NULL,
    tarea_id INT NOT NULL, 
    FOREIGN KEY (material_id) REFERENCES  gd_esquema.Material (material_id),
    FOREIGN KEY (tarea_id) REFERENCES  gd_esquema.Tarea (tarea_id)
)

COMMIT TRANSACTION
