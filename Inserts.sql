-- Chofer
INSERT INTO gd_esquema.Chofer (legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nac, costo_hora)
	SELECT DISTINCT CHOFER_NRO_LEGAJO, CHOFER_NOMBRE, CHOFER_APELLIDO, CHOFER_DNI, CHOFER_DIRECCION, CHOFER_TELEFONO, 
	CHOFER_MAIL, CHOFER_FECHA_NAC, CHOFER_COSTO_HORA FROM gd_esquema.Maestra
	WHERE CHOFER_NRO_LEGAJO IS NOT NULL

-- Ciudad
INSERT INTO gd_esquema.Ciudad (nombre)
	SELECT DISTINCT RECORRIDO_CIUDAD_DESTINO FROM gd_esquema.Maestra
		WHERE RECORRIDO_CIUDAD_DESTINO IS NOT NULL
	UNION
	SELECT DISTINCT RECORRIDO_CIUDAD_ORIGEN FROM gd_esquema.Maestra
		WHERE RECORRIDO_CIUDAD_ORIGEN IS NOT NULL
	UNION
	SELECT DISTINCT TALLER_CIUDAD FROM gd_esquema.Maestra
		WHERE TALLER_CIUDAD IS NOT NULL

-- Recorrido
INSERT INTO gd_esquema.Recorrido (ciudad_origen_id, ciudad_destino_id, km_recorridos,
		precio)
	SELECT DISTINCT c1.ciudad_id, c2.ciudad_id, RECORRIDO_KM, RECORRIDO_PRECIO FROM gd_esquema.Maestra m
		JOIN gd_esquema.Ciudad c1 ON (c1.nombre = m.RECORRIDO_CIUDAD_ORIGEN)
		JOIN gd_esquema.Ciudad c2 ON (c2.nombre = m.RECORRIDO_CIUDAD_DESTINO)
	WHERE RECORRIDO_KM IS NOT NULL

-- Tipo Paquete
INSERT INTO gd_esquema.Tipo_paquete (paquete_descripcion, paquete_largo_max,
		paquete_peso_max, paquete_ancho_max, paquete_precio, paquete_alto_max)
	SELECT DISTINCT PAQUETE_DESCRIPCION, PAQUETE_LARGO_MAX, PAQUETE_PESO_MAX, PAQUETE_ANCHO_MAX, 
		PAQUETE_PRECIO, PAQUETE_ALTO_MAX FROM gd_esquema.Maestra
	WHERE PAQUETE_DESCRIPCION IS NOT NULL

-- Marca
INSERT INTO gd_esquema.Marca (nombre)
	SELECT DISTINCT MARCA_CAMION_MARCA FROM gd_esquema.Maestra
	WHERE MARCA_CAMION_MARCA IS NOT NULL

-- Modelo
INSERT INTO gd_esquema.Modelo (marca_id, modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga)
	SELECT DISTINCT marca.marca_id, MODELO_CAMION, MODELO_VELOCIDAD_MAX, MODELO_CAPACIDAD_TANQUE, 
	MODELO_CAPACIDAD_CARGA FROM gd_esquema.Maestra maestra
		JOIN gd_esquema.Marca marca ON (marca.nombre = maestra.MARCA_CAMION_MARCA)
	WHERE MODELO_CAMION IS NOT NULL

-- Taller
INSERT INTO gd_esquema.Taller (ciudad_id, nombre, telefono, direccion, mail)
	SELECT DISTINCT c.ciudad_id, TALLER_NOMBRE, TALLER_TELEFONO, TALLER_DIRECCION, 
	TALLER_MAIL
	FROM gd_esquema.Maestra m
		JOIN gd_esquema.Ciudad c on (c.nombre = m.TALLER_CIUDAD)
	WHERE TALLER_NOMBRE IS NOT NULL

-- Material
INSERT INTO gd_esquema.Material (material_descripcion, precio)
	SELECT DISTINCT MATERIAL_DESCRIPCION, MATERIAL_PRECIO FROM gd_esquema.Maestra
	WHERE MATERIAL_DESCRIPCION IS NOT NULL

-- Tipo_tarea
INSERT INTO gd_esquema.Tipo_tarea (descripcion)
	SELECT DISTINCT TIPO_TAREA FROM gd_esquema.Maestra
	WHERE TIPO_TAREA IS NOT NULL

-- Tarea
INSERT INTO gd_esquema.Tarea (tipo_tarea_id, tiempo_estimado, descripcion)
	SELECT DISTINCT tt.tipo_tarea_id, TAREA_TIEMPO_ESTIMADO, TAREA_DESCRIPCION
	FROM gd_esquema.Maestra m
	JOIN gd_esquema.Tipo_tarea tt ON (tt.descripcion = m.TIPO_TAREA)
	WHERE TAREA_TIEMPO_ESTIMADO IS NOT NULL

-- Camion
INSERT INTO gd_esquema.Camion (modelo_id, patente, chasis, motor, fecha_alta)
	SELECT DISTINCT modelo.modelo_id, CAMION_PATENTE, CAMION_NRO_CHASIS,
	CAMION_NRO_MOTOR, CAMION_FECHA_ALTA FROM gd_esquema.Maestra m
	JOIN gd_esquema.Modelo modelo ON (modelo.modelo_descripcion = m.MODELO_CAMION
		AND modelo.velocidad_max = m.MODELO_VELOCIDAD_MAX AND modelo.capacidad_tanque = m.MODELO_CAPACIDAD_TANQUE
		 AND modelo.capacidad_carga = m.MODELO_CAPACIDAD_CARGA)
	JOIN gd_esquema.Marca marca ON (marca.nombre = m.MARCA_CAMION_MARCA)
	WHERE CAMION_PATENTE IS NOT NULL
	ORDER BY CAMION_PATENTE

-- Viaje
INSERT INTO gd_esquema.Viaje (camion_id, recorrido_id, chofer, fecha_inicio,
	fecha_fin, lts_combustible)
	SELECT DISTINCT c.camion_id, r.recorrido_id, ch.legajo, VIAJE_FECHA_INICIO, 
		VIAJE_FECHA_FIN, VIAJE_CONSUMO_COMBUSTIBLE FROM gd_esquema.Maestra m
	JOIN gd_esquema.Camion c ON (m.CAMION_PATENTE = c.patente)
	JOIN gd_esquema.Ciudad c1 ON (c1.nombre = m.RECORRIDO_CIUDAD_ORIGEN)
	JOIN gd_esquema.Ciudad c2 ON (c2.nombre = m.RECORRIDO_CIUDAD_DESTINO)
	JOIN gd_esquema.Recorrido r ON (c1.ciudad_id = r.ciudad_origen_id AND
		c2.ciudad_id = r.ciudad_destino_id)
	JOIN gd_esquema.Chofer ch ON (ch.legajo = m.CHOFER_NRO_LEGAJO)
	WHERE VIAJE_FECHA_INICIO IS NOT NULL

-- Paquete
INSERT INTO gd_esquema.Paquete (tipo_paquete_id)
	SELECT tipo_paquete_id FROM gd_esquema.Tipo_paquete

-- Viaje_x_paquete
INSERT INTO gd_esquema.Viaje_x_paquete (paquete_id, viaje_id, cantidad)
	SELECT DISTINCT paquete_id, viaje_id, SUM(PAQUETE_CANTIDAD) FROM gd_esquema.Maestra m
		JOIN gd_esquema.Camion c ON (m.CAMION_PATENTE = c.patente)
		JOIN gd_esquema.Viaje v ON (v.fecha_inicio = m.VIAJE_FECHA_INICIO AND
			v.camion_id = c.camion_id)
		JOIN gd_esquema.Tipo_paquete tp ON (tp.paquete_descripcion = m.PAQUETE_DESCRIPCION)
		JOIN gd_esquema.Paquete p ON (p.tipo_paquete_id = tp.tipo_paquete_id)
		group by viaje_id, paquete_id

-- Estado
INSERT INTO gd_esquema.Estado (descripcion)
	SELECT DISTINCT ORDEN_TRABAJO_ESTADO FROM gd_esquema.Maestra
	WHERE ORDEN_TRABAJO_ESTADO IS NOT NULL

-- Oden_trabajo
INSERT INTO gd_esquema.Orden_trabajo (fecha_generacion, camion_id, estado_id)
	SELECT DISTINCT ORDEN_TRABAJO_FECHA, camion_id, estado_id FROM gd_esquema.Maestra m
	JOIN gd_esquema.Camion c ON (c.patente = m.CAMION_PATENTE)
	JOIN gd_esquema.Estado e ON (e.descripcion = m.ORDEN_TRABAJO_ESTADO)

--Mecanico
INSERT INTO gd_esquema.Mecanico (legajo, nombre, apellido, dni, direccion, telefono, mail, 
	fecha_nacimiento, costo_hora, taller_id)
	SELECT DISTINCT MECANICO_NRO_LEGAJO, MECANICO_NOMBRE, MECANICO_APELLIDO, MECANICO_DNI,
		MECANICO_DIRECCION, MECANICO_TELEFONO, MECANICO_MAIL, MECANICO_FECHA_NAC, MECANICO_COSTO_HORA,
		t.taller_id FROM gd_esquema.Maestra m
	JOIN gd_esquema.taller t ON (t.nombre = TALLER_NOMBRE)
	WHERE MECANICO_NRO_LEGAJO IS NOT NULL

-- Tarea_x_orden TODOOOOOOOO
INSERT INTO gd_esquema.Tarea_x_orden (orden_id, tarea_id, mecanico_id, inicio_planificado, inicio_real,
		fin_real)
	SELECT DISTINCT orden_id, tarea_id, legajo, TAREA_FECHA_INICIO_PLANIFICADO, TAREA_FECHA_INICIO,
	TAREA_FECHA_FIN FROM gd_esquema.Maestra m
	JOIN gd_esquema.Camion c ON (c.patente = m.CAMION_PATENTE)
	JOIN gd_esquema.Orden_trabajo ot ON (ot.fecha_generacion = m.ORDEN_TRABAJO_FECHA AND 
		ot.camion_id = c.camion_id)
	JOIN gd_esquema.Tipo_tarea tt ON (tt.descripcion = m.TIPO_TAREA)
	JOIN gd_esquema.Tarea t ON (t.tipo_tarea_id = tt.tipo_tarea_id)
	JOIN gd_esquema.Mecanico mec ON (mec.legajo = m.MECANICO_NRO_LEGAJO)
	ORDER BY orden_id, tarea_id

-- Material_x_tarea TODO
INSERT INTO gd_esquema.Material_x_tarea (material_id, tarea_id)
	SELECT DISTINCT material_id, tarea_id FROM gd_esquema.Maestra m
	JOIN gd_esquema.Material mate ON (m.MATERIAL_DESCRIPCION = mate.material_descripcion)
	JOIN gd_esquema.Tarea