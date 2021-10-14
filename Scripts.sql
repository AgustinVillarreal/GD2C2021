BEGIN TRANSACTION

CREATE TABLE gd_esquema.Chofer (
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255),
	apellido NVARCHAR(255),
	dni DECIMAL(18,0),
	direccion NVARCHAR(255),
	telefono INT,
	mail NVARCHAR(255),
	fecha_nac DATETIME2(3),
	costo_hora INT,
)

CREATE TABLE gd_esquema.Recorrido (
	recorrido_id INT PRIMARY KEY,
	ciudad_origen NVARCHAR(255),
	ciudad_destino NVARCHAR(255),
	km_recorridos INT,
	precio DECIMAL(18,2),
)

CREATE TABLE gd_esquema.Tipo_paquete (
	paquete_descripcion NVARCHAR(255) PRIMARY KEY,
	paquete_largo_max DECIMAL(18,2),
	paquete_peso_max DECIMAL(18,2),
	paquete_ancho_max DECIMAL(18,2),
	paquete_precio DECIMAL(18,2),
	paquete_alto_max DECIMAL(18,2)
)

CREATE TABLE gd_esquema.Modelo(
	modelo_id INT PRIMARY KEY,
	modelo_descripcion NVARCHAR(255),
	velocidad_max INT,
	capacidad_tanque INT,
	capacidad_carga INT,
	marca NVARCHAR(255)
)

CREATE TABLE gd_esquema.Taller(
	nombre NVARCHAR(255) PRIMARY KEY,
	teléfono DECIMAL(18,0),
	ciudad NVARCHAR(255),
	dirección NVARCHAR(255),
	mail NVARCHAR(255)
)

CREATE TABLE  gd_esquema.Material(
    material_id INT PRIMARY KEY, 
    material_detalle NVARCHAR(255),
    precio DECIMAL(18, 2)
)

CREATE TABLE  gd_esquema.Tarea (
    tarea_id INT PRIMARY KEY,
    tipo NVARCHAR(255),
    tiempo_estimado INT, 
    descripcion NVARCHAR(255),
)

--FOREIGN KEYS

CREATE TABLE gd_esquema.Camion(
	patente NVARCHAR(255) PRIMARY KEY,
	chasis NVARCHAR(255),
	motor NVARCHAR(255),
	fecha_alta DATETIME2(3),
	modelo_id INT,
	FOREIGN KEY (modelo_id) REFERENCES gd_esquema.Modelo (modelo_id)
)

CREATE TABLE gd_esquema.Viaje (
	viaje_id INT PRIMARY KEY,
	camion NVARCHAR(255),
	chofer INT,
	recorrido INT,
	fecha_inicio DATETIME2(7),
	fecha_fin DATETIME2(3),
	lts_combustible DECIMAL(18,2),
	FOREIGN KEY (camion)	REFERENCES gd_esquema.Camion		(patente),
	FOREIGN KEY (chofer)	REFERENCES gd_esquema.Chofer		(legajo),
	FOREIGN KEY (recorrido) REFERENCES gd_esquema.Recorrido		(recorrido_id)
)

CREATE TABLE gd_esquema.Paquete (
	id_paquete INT PRIMARY KEY,
	tipo_paquete NVARCHAR(255)
	FOREIGN KEY (tipo_paquete) REFERENCES gd_esquema.Tipo_paquete(paquete_descripcion)
)

CREATE TABLE gd_esquema.Viaje_x_paquete (
	id_paquete INT,
	viaje INT,
	cantidad INT,
	PRIMARY KEY (id_paquete, viaje),
	FOREIGN KEY (id_paquete) REFERENCES gd_esquema.Paquete(id_paquete),
	FOREIGN KEY (viaje) REFERENCES gd_esquema.Viaje(viaje_id)
)

CREATE TABLE gd_esquema.Orden_trabajo (
	orden_id INT PRIMARY KEY,
	fecha_generacion NVARCHAR(255),
	camion NVARCHAR(255),
	estado NVARCHAR(255),
	FOREIGN KEY (camion) REFERENCES gd_esquema.Camion(patente)
)

CREATE TABLE gd_esquema.Mecanico(
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255),
	apellido NVARCHAR(255),
	dni DECIMAL(18,0),
	direccion NVARCHAR(255),
	teléfono INT,
	mail NVARCHAR(255),
	fecha_nacimiento DATETIME2(3),
	costo_hora INT,
	nombre_taller NVARCHAR(255),
	FOREIGN KEY (nombre_taller) REFERENCES gd_esquema.Taller (nombre)
)

CREATE TABLE gd_esquema.Tarea_x_orden(
    orden_id INT,
    codigo_tarea INT,
    inicio_planificado datetime2,
    inicio_real datetime2,
    fin_real datetime2,
    mecanico INT
    PRIMARY KEY (orden_id, codigo_tarea),
    FOREIGN KEY (mecanico) references gd_esquema.Mecanico (legajo),
    FOREIGN KEY (orden_id) references  gd_esquema.Orden_trabajo (orden_id)
)

CREATE TABLE  gd_esquema.Material_x_tarea(
    material_id INT,
    tarea_id INT, 
    FOREIGN KEY (material_id) REFERENCES  gd_esquema.Material (material_id),
    FOREIGN KEY (tarea_id) REFERENCES  gd_esquema.Tarea (tarea_id)
)

COMMIT TRANSACTION