USE GD2C2022
GO

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ CREACION DE SCHEMA ---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

--DROP SCHEMA BI_DREAM_TEAM
CREATE SCHEMA BI_DREAM_TEAM;
GO

-----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- CREACION DE DIMENSIONES -------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE BI_DREAM_TEAM.BI_tiempo(
	id_tiempo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tiempo_anio INTEGER,
	tiempo_mes INTEGER
);

CREATE TABLE BI_DREAM_TEAM.BI_canal_de_venta(
	id_canal_venta INTEGER PRIMARY KEY,
	costo DECIMAL(18,2),
	nombre VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_tipo_descuento(
	id_tipo_descuento INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_medio_pago(
	id_medio_pago INTEGER PRIMARY KEY,
	recargo DECIMAL(18,2),
	descripcion VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_categoria_producto(
	id_categoria INTEGER PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_rango_etario(
	id_rango_etario INTEGER PRIMARY KEY,
	rango VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_producto(
	id_producto VARCHAR(50) PRIMARY KEY,
	categoria_id INTEGER,
	FOREIGN KEY(categoria_id) REFERENCES BI_DREAM_TEAM.BI_categoria_producto(id_categoria),
	nombre VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_tipo_envio(
	id_tipo_envio INTEGER PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_provincia(
	id_provincia INTEGER PRIMARY KEY,
	nombre VARCHAR(255)
);

CREATE TABLE BI_DREAM_TEAM.BI_proveedor(
	cuit VARCHAR(50) PRIMARY KEY,
	razon_social VARCHAR(50)
);

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ CREACION DE HECHOS ---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE BI_DREAM_TEAM.BI_hechos_ventas(
	id_hecho_venta INTEGER IDENTITY(1,1) PRIMARY KEY,
	tiempo_id INTEGER
	FOREIGN KEY(tiempo_id) REFERENCES BI_DREAM_TEAM.BI_tiempo(id_tiempo),
	canal_id INTEGER
	FOREIGN KEY(canal_id) REFERENCES BI_DREAM_TEAM.BI_canal_de_venta(id_canal_venta),
	medio_pago_id INTEGER
	FOREIGN KEY(medio_pago_id) REFERENCES BI_DREAM_TEAM.BI_medio_pago(id_medio_pago),
	monto_total_ventas DECIMAL(18,2),
	costo_medio_pago DECIMAL(18,2)
); 

CREATE TABLE BI_DREAM_TEAM.BI_hechos_descuentos(
	id_hecho_descuento INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_descuento_id INTEGER
	FOREIGN KEY(tipo_descuento_id) REFERENCES BI_DREAM_TEAM.BI_tipo_descuento(id_tipo_descuento),
	id_hecho_venta INTEGER
	FOREIGN KEY(id_hecho_venta) REFERENCES BI_DREAM_TEAM.BI_hechos_ventas(id_hecho_venta),
	monto_total DECIMAL(18,2)
); 

CREATE TABLE BI_DREAM_TEAM.BI_hechos_compras(
	id_hecho_compra INTEGER IDENTITY(1,1) PRIMARY KEY,
	tiempo_id INTEGER
	FOREIGN KEY(tiempo_id) REFERENCES BI_DREAM_TEAM.BI_tiempo(id_tiempo),
	proveedor_id VARCHAR(50)
	FOREIGN KEY(proveedor_id) REFERENCES BI_DREAM_TEAM.BI_proveedor(cuit),
	monto_total_compras DECIMAL(18,2)
);

CREATE TABLE BI_DREAM_TEAM.BI_hechos_compras_productos(
	id_hecho_compra_producto INTEGER IDENTITY(1,1) PRIMARY KEY,
	producto_id VARCHAR(50)
	FOREIGN KEY(producto_id) REFERENCES BI_DREAM_TEAM.BI_producto(id_producto),
	tiempo_id INTEGER
	FOREIGN KEY(tiempo_id) REFERENCES BI_DREAM_TEAM.BI_tiempo(id_tiempo),
	proveedor_id VARCHAR(50)
	FOREIGN KEY(proveedor_id) REFERENCES BI_DREAM_TEAM.BI_proveedor(cuit),
	monto_total_producto DECIMAL(18,2),
	cantidad INTEGER
);

CREATE TABLE BI_DREAM_TEAM.BI_hechos_ventas_productos(
	id_hechos_venta_producto INTEGER IDENTITY(1,1) PRIMARY KEY,
	tiempo_id INTEGER
	FOREIGN KEY(tiempo_id) REFERENCES BI_DREAM_TEAM.BI_tiempo(id_tiempo),
	rango_etario_id INTEGER
	FOREIGN KEY(rango_etario_id) REFERENCES BI_DREAM_TEAM.BI_rango_etario(id_rango_etario),
	producto_id VARCHAR(50)
	FOREIGN KEY(producto_id) REFERENCES BI_DREAM_TEAM.BI_producto(id_producto),
	categoria_id INTEGER
	FOREIGN KEY(categoria_id ) REFERENCES BI_DREAM_TEAM.BI_categoria_producto(id_categoria),
	monto_total_producto DECIMAL(18,2),
	cantidad INTEGER
);

CREATE TABLE BI_DREAM_TEAM.BI_hechos_envios(
	id_hecho_envio INTEGER IDENTITY(1,1) PRIMARY KEY,
	tiempo_id INTEGER
	FOREIGN KEY(tiempo_id) REFERENCES BI_DREAM_TEAM.BI_tiempo(id_tiempo),
	provincia_id INTEGER
	FOREIGN KEY(provincia_id) REFERENCES BI_DREAM_TEAM.BI_provincia(id_provincia),
	id_tipo_envio INTEGER
	FOREIGN KEY(id_tipo_envio) REFERENCES BI_DREAM_TEAM.BI_tipo_envio(id_tipo_envio),
	monto_total_envios DECIMAL(18,2),
	cantidad INTEGER
);

-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- MIGRACION DE DIMENSIONES ------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
GO
--DROP FUNCTION BI_DREAM_TEAM.calcular_rango_etario


GO
CREATE FUNCTION
BI_DREAM_TEAM.calcular_rango_etario(@fecha AS DATE)
RETURNS INTEGER
AS
BEGIN 
DECLARE @edad INTEGER;
DECLARE @rango_etario_id INTEGER;
	SET @edad = YEAR(getDate()) - YEAR(@fecha);
	IF (@edad < 25)
		SET @rango_etario_id = 1;
	IF (@edad >= 25 AND @edad <= 35) --cambiar por between
		SET @rango_etario_id = 2;
	IF (@edad > 35 AND @edad <= 55)
		SET @rango_etario_id = 3;
	IF (@edad > 55)
		SET @rango_etario_id = 4;
	
	RETURN @rango_etario_id;
END;

GO
CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_tiempo
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_tiempo (tiempo_anio, tiempo_mes)
		SELECT DISTINCT YEAR(fecha), MONTH(fecha) 
		FROM DREAM_TEAM.venta
		UNION
		SELECT DISTINCT YEAR(fecha), MONTH(fecha)
		FROM DREAM_TEAM.compra
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_canal_de_venta
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_canal_de_venta(id_canal_venta, nombre, costo)
		SELECT DISTINCT id_canal, descripcion, costo  
		FROM DREAM_TEAM.canal_de_venta
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_tipo_envio
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_tipo_envio(id_tipo_envio, descripcion)
		SELECT DISTINCT id_medio, descripcion 
		FROM DREAM_TEAM.medio_de_envios
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_tipo_descuento
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_tipo_descuento(descripcion)
		SELECT DISTINCT descripcion 
		FROM DREAM_TEAM.tipo_descuento;

		INSERT INTO BI_DREAM_TEAM.BI_tipo_descuento(descripcion)
		VALUES('Cupon');
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_medio_pago
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_medio_pago(id_medio_pago, descripcion, recargo)
		SELECT DISTINCT id_medio_pago_v, descripcion, recargo 
		FROM DREAM_TEAM.medio_pago_venta;
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_rango_etario
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_rango_etario(id_rango_etario, rango)
		VALUES(1,'<25'),(2,'25-35'),(3,'35-55'),(4,'>55')

END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_categoria_producto
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_categoria_producto(id_categoria, descripcion)
		SELECT DISTINCT id_categoria, descripcion
		FROM DREAM_TEAM.categoria;
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_proveedor
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_proveedor(cuit, razon_social)
		SELECT DISTINCT cuit, razon_social
		FROM DREAM_TEAM.proveedor
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_provincia
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_provincia(id_provincia, nombre)
		SELECT DISTINCT id_provincia, descripcion
		FROM DREAM_TEAM.provincia
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_producto
AS
BEGIN
		INSERT INTO BI_DREAM_TEAM.BI_producto(id_producto, categoria_id, nombre)
		SELECT DISTINCT id_producto_variante, cp.id_categoria, p.nombre+' '+tv.descripcion+' '+v.descripcion -- Buzo + Color + Rojo
		FROM DREAM_TEAM.producto_variante pv
		JOIN DREAM_TEAM.producto p ON(p.id_producto = pv.producto_id)
		JOIN DREAM_TEAM.variante v ON(v.id_variante = pv.variante_id)
		JOIN DREAM_TEAM.tipo_variante tv ON(tv.id_tipo_variante = v.tipo_variante_id)
		JOIN DREAM_TEAM.categoria cat ON(p.categoria_id = cat.id_categoria)
		JOIN BI_DREAM_TEAM.BI_categoria_producto cp ON(cp.descripcion = cat.descripcion)
END
GO

-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- MIGRACION DE HECHOS ---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_ventas
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_ventas(tiempo_id, canal_id, medio_pago_id, monto_total_ventas, costo_medio_pago)
	SELECT DISTINCT tb.id_tiempo, cvb.id_canal_venta, mpb.id_medio_pago, SUM(v.total_venta), SUM(mpv.recargo)
	FROM DREAM_TEAM.venta v
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(v.fecha) AND tb.tiempo_mes = MONTH(v.fecha))
	JOIN DREAM_TEAM.canal_de_venta cv ON(v.canal_de_venta_id = cv.id_canal)
	JOIN BI_DREAM_TEAM.BI_canal_de_venta cvb ON(cv.descripcion = cvb.nombre)
	JOIN DREAM_TEAM.medio_pago_venta mpv ON(v.medio_pago_id = mpv.id_medio_pago_v)
	JOIN BI_DREAM_TEAM.BI_medio_pago mpb ON(mpv.descripcion = mpb.descripcion)
	GROUP BY tb.id_tiempo, cvb.id_canal_venta, mpb.id_medio_pago
END		
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_descuentos -- FALTA JOINEAR CON CUPONES
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_descuentos(tipo_descuento_id, id_hecho_venta, monto_total)
	SELECT DISTINCT tdb.id_tipo_descuento, id_hecho_venta, SUM(dv.importe)
	FROM DREAM_TEAM.descuento_venta dv

	JOIN DREAM_TEAM.venta v ON(dv.venta_id = v.id_venta) -- hecho venta

	JOIN DREAM_TEAM.canal_de_venta cdv ON(v.canal_de_venta_id = cdv.id_canal) -- hecho venta
	JOIN DREAM_TEAM.medio_pago_venta mpv ON(v.medio_pago_id = mpv.id_medio_pago_v) -- hecho venta

	JOIN BI_DREAM_TEAM.BI_canal_de_venta cvb ON(cdv.descripcion = cvb.nombre) -- hecho venta
	JOIN BI_DREAM_TEAM.BI_medio_pago mpb ON(mpv.descripcion = mpb.descripcion) -- hecho venta
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(v.fecha) AND tb.tiempo_mes = MONTH(v.fecha)) -- hecho venta

	JOIN BI_DREAM_TEAM.BI_hechos_ventas hvb ON
		 (mpb.id_medio_pago = hvb.medio_pago_id AND cvb.id_canal_venta = hvb.canal_id AND tb.id_tiempo = hvb.tiempo_id) -- hecho venta
	
	JOIN DREAM_TEAM.tipo_descuento td ON(dv.tipo_descuento_id = td.id_tipo_descuento) --tipo descuento
	JOIN BI_DREAM_TEAM.BI_tipo_descuento tdb ON(td.descripcion = tdb.descripcion) --tipo descuento
	GROUP BY tdb.id_tipo_descuento, hvb.id_hecho_venta
	UNION
	SELECT DISTINCT tdb.id_tipo_descuento, id_hecho_venta, SUM(dcv.importe)
	FROM DREAM_TEAM.descuento_cupon_venta dcv

	JOIN DREAM_TEAM.venta v ON(dcv.venta_id = v.id_venta) -- hecho venta

	JOIN DREAM_TEAM.canal_de_venta cdv ON(v.canal_de_venta_id = cdv.id_canal) -- hecho venta
	JOIN DREAM_TEAM.medio_pago_venta mpv ON(v.medio_pago_id = mpv.id_medio_pago_v) -- hecho venta

	JOIN BI_DREAM_TEAM.BI_canal_de_venta cvb ON(cdv.descripcion = cvb.nombre) -- hecho venta
	JOIN BI_DREAM_TEAM.BI_medio_pago mpb ON(mpv.descripcion = mpb.descripcion) -- hecho venta
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(v.fecha) AND tb.tiempo_mes = MONTH(v.fecha)) -- hecho venta

	JOIN BI_DREAM_TEAM.BI_hechos_ventas hvb ON
		 (mpb.id_medio_pago = hvb.medio_pago_id AND cvb.id_canal_venta = hvb.canal_id AND tb.id_tiempo = hvb.tiempo_id) -- hecho venta

	JOIN BI_DREAM_TEAM.BI_tipo_descuento tdb ON(tdb.descripcion = 'Cupon') --tipo descuento
	GROUP BY tdb.id_tipo_descuento, hvb.id_hecho_venta
END
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_compras
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_compras(tiempo_id, proveedor_id, monto_total_compras)
	SELECT DISTINCT tb.id_tiempo, pb.cuit, SUM(c.total_compra)
	FROM DREAM_TEAM.compra c
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(c.fecha) AND tb.tiempo_mes = MONTH(c.fecha))
	JOIN BI_DREAM_TEAM.BI_proveedor pb ON(c.proveedor_id = pb.cuit)
	GROUP BY tb.id_tiempo, pb.cuit
END		
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_envios
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_envios(tiempo_id, provincia_id, id_tipo_envio, monto_total_envios, cantidad)
	SELECT DISTINCT tb.id_tiempo, pb.id_provincia, teb.id_tipo_envio, SUM(e.costo_envio), COUNT(DISTINCT e.id_entrega)
	FROM DREAM_TEAM.venta v
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(v.fecha) AND tb.tiempo_mes = MONTH(v.fecha)) -- tiempo
	JOIN DREAM_TEAM.entrega e ON(v.id_venta = e.venta_id) -- provincia
	JOIN DREAM_TEAM.medio_de_envios_cp mec ON(mec.id_medio_de_envios_cp = e.medio_envio_cp_id) -- provincia
	JOIN DREAM_TEAM.codigo_postal_localidad cpl ON(cpl.id_cp_localidad = mec.cp_localidad_id) -- provincia
	JOIN DREAM_TEAM.provincia p ON(p.id_provincia = cpl.provincia_id) -- provincia
	JOIN BI_DREAM_TEAM.BI_provincia pb ON(pb.id_provincia = p.id_provincia) -- provincia
	JOIN DREAM_TEAM.medio_de_envios mde ON(mde.id_medio = mec.medio_id) -- tipo envio
	JOIN BI_DREAM_TEAM.BI_tipo_envio teb ON(teb.descripcion = mde.descripcion) -- tipo envio
	GROUP BY tb.id_tiempo, pb.id_provincia, teb.id_tipo_envio
END		
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_compras_productos
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_compras_productos(producto_id, tiempo_id, proveedor_id, monto_total_producto, cantidad)
	SELECT DISTINCT pb.id_producto, tb.id_tiempo, prb.cuit, SUM(ic.precio_unitario * ic.cantidad), SUM(ic.cantidad)
	FROM DREAM_TEAM.item_compra ic
	JOIN BI_DREAM_TEAM.BI_producto pb ON(pb.id_producto = ic.producto_variante_id) -- producto
	JOIN DREAM_TEAM.compra c ON(c.id_compra = ic.compra_id) -- tiempo y proveedor
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(c.fecha) AND tb.tiempo_mes = MONTH(c.fecha)) --tiempo
	JOIN BI_DREAM_TEAM.BI_proveedor prb ON(prb.cuit = c.proveedor_id)
	GROUP BY pb.id_producto, tb.id_tiempo, prb.cuit
END		
GO

CREATE PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_ventas_productos
AS
BEGIN
	INSERT INTO BI_DREAM_TEAM.BI_hechos_ventas_productos(tiempo_id, rango_etario_id, producto_id, categoria_id, monto_total_producto, cantidad)
	SELECT DISTINCT tb.id_tiempo, reb.id_rango_etario, pb.id_producto, pb.categoria_id, SUM(iv.precio_unitario*iv.cantidad), SUM(iv.cantidad)
	FROM DREAM_TEAM.item_venta iv
	JOIN DREAM_TEAM.venta v ON(iv.venta_id = v.id_venta)
	JOIN BI_DREAM_TEAM.BI_tiempo tb ON(tb.tiempo_anio = YEAR(v.fecha) AND tb.tiempo_mes = MONTH(v.fecha)) -- tiempo
	JOIN BI_DREAM_TEAM.BI_producto pb ON(pb.id_producto = iv.producto_variante_id) -- producto
	JOIN BI_DREAM_TEAM.BI_categoria_producto cpb ON(cpb.id_categoria = pb.categoria_id) -- categoria
	JOIN DREAM_TEAM.cliente c ON(c.id_cliente = v.cliente_id)
	JOIN BI_DREAM_TEAM.BI_rango_etario reb ON(reb.id_rango_etario = BI_DREAM_TEAM.calcular_rango_etario(c.nacimiento))
	GROUP BY tb.id_tiempo, reb.id_rango_etario, pb.id_producto, pb.categoria_id
END		
GO
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------- VIEWS ---------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
--VISTA 1
CREATE VIEW BI_DREAM_TEAM.BI_1_ganancias_mes_canal_venta AS
    SELECT cv.nombre AS 'Canal de venta', CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Mes',
        SUM(hv.monto_total_ventas) - SUM(hv.costo_medio_pago) - cm.total_compra_mes AS 'Ganancias'
    FROM BI_DREAM_TEAM.BI_hechos_ventas hv
    JOIN BI_DREAM_TEAM.BI_canal_de_venta cv ON (hv.canal_id = cv.id_canal_venta)
    JOIN BI_DREAM_TEAM.BI_tiempo t ON (hv.tiempo_id = t.id_tiempo)
    JOIN (SELECT SUM(monto_total_compras) total_compra_mes, tiempo_id FROM BI_DREAM_TEAM.BI_hechos_compras
            GROUP BY tiempo_id) AS cm
        ON cm.tiempo_id = hv.tiempo_id
    GROUP BY cv.nombre, t.tiempo_mes, t.tiempo_anio, cm.total_compra_mes
GO

----VISTA 2
CREATE VIEW BI_DREAM_TEAM.BI_2_productos_mayor_rentabilidad_anio
	AS
	WITH ordenamiento_p AS(
	SELECT
	ROW_NUMBER() OVER(PARTITION BY tiempo_anio
					  ORDER BY tiempo_anio, (SUM(vp.monto_total_producto)-SUM(cp.monto_total_producto)) / SUM(vp.monto_total_producto) DESC)
	id,
	t.tiempo_anio, p1.nombre, ((CAST(SUM(vp.monto_total_producto) AS DECIMAL) - CAST(SUM(cp.monto_total_producto) AS DECIMAL))
							  /CAST(SUM(vp.monto_total_producto) AS DECIMAL)) * 100 rentabilidad
	FROM BI_DREAM_TEAM.BI_producto p1
	JOIN BI_DREAM_TEAM.BI_hechos_compras_productos cp ON(p1.id_producto = cp.producto_id)
	JOIN BI_DREAM_TEAM.BI_hechos_ventas_productos vp ON(p1.id_producto = vp.producto_id)
	JOIN BI_DREAM_TEAM.BI_tiempo t ON(t.id_tiempo = vp.tiempo_id AND t.id_tiempo = cp.tiempo_id)
	GROUP BY t.tiempo_anio, p1.nombre
	)
	SELECT nombre AS 'Producto', CAST(rentabilidad AS DECIMAL(10,2)) AS 'Porcentaje', tiempo_anio AS 'Anio'
	FROM ordenamiento_p
	WHERE id <= 5
GO

----VISTA 3 
CREATE VIEW BI_DREAM_TEAM.BI_3_categorias_mas_vendidas_edad_mes AS
	SELECT cp.descripcion AS 'Categoria producto',
		   re.rango AS 'Rango etario', 
		   CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Fecha',
		   SUM(vp.cantidad) AS 'Cantidad vendida'
	FROM BI_DREAM_TEAM.BI_hechos_ventas_productos vp
	JOIN BI_DREAM_TEAM.BI_categoria_producto cp ON(cp.id_categoria = vp.categoria_id)
	JOIN BI_DREAM_TEAM.BI_rango_etario re ON(re.id_rango_etario = vp.rango_etario_id)
	JOIN BI_DREAM_TEAM.BI_tiempo t ON(t.id_tiempo = vp.tiempo_id)
	WHERE cp.id_categoria IN (SELECT TOP 5 vp1.categoria_id
							  FROM BI_DREAM_TEAM.BI_hechos_ventas_productos vp1
							  WHERE vp1.tiempo_id = vp.tiempo_id
							  GROUP BY vp1.categoria_id
							  ORDER BY SUM(vp1.cantidad) DESC)
	GROUP BY cp.descripcion, re.rango, t.tiempo_mes, t.tiempo_anio
GO

----VISTA 4
CREATE VIEW BI_DREAM_TEAM.BI_4_ingresos_netos_medio_pago_mes AS
   SELECT mp.descripcion AS 'Medio de pago', CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Mes', 
        SUM(hv.monto_total_ventas) - SUM(hv.costo_medio_pago) - ISNULL(descuentos.total,0) AS 'Ingresos'
    FROM BI_DREAM_TEAM.BI_hechos_ventas hv
    JOIN BI_DREAM_TEAM.BI_medio_pago mp ON (hv.medio_pago_id = mp.id_medio_pago)
    JOIN BI_DREAM_TEAM.BI_tiempo t ON (hv.tiempo_id = t.id_tiempo) 
    --Left para considerar tambien los medios de pago que no tienen descuentos asociados
    LEFT JOIN (SELECT t2.id_tiempo tiempo, SUM(hd.monto_total) total, td.descripcion tipo_descuento
        FROM BI_DREAM_TEAM.BI_hechos_descuentos hd
        JOIN BI_DREAM_TEAM.BI_tipo_descuento td ON (hd.tipo_descuento_id = td.id_tipo_descuento)
        JOIN BI_DREAM_TEAM.BI_hechos_ventas hv2 ON (hv2.id_hecho_venta = hd.id_hecho_venta)
        JOIN BI_DREAM_TEAM.BI_tiempo t2 ON (hv2.tiempo_id = t2.id_tiempo) 
        GROUP BY td.descripcion, t2.id_tiempo, t2.tiempo_mes, t2.tiempo_anio) AS descuentos
    ON (descuentos.tiempo = hv.tiempo_id AND descuentos.tipo_descuento = mp.descripcion)
    GROUP BY mp.descripcion, t.tiempo_mes, t.tiempo_anio, descuentos.total
GO

----VISTA 5
CREATE VIEW BI_DREAM_TEAM.BI_5_total_descuento_tipo_canal_venta_mes AS 
    SELECT td.descripcion AS 'Tipo descuento', cv.nombre AS 'Canal venta', 
        CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Fecha',
        SUM(monto_total) AS 'Total'
    FROM BI_DREAM_TEAM.BI_hechos_descuentos hd
    JOIN BI_DREAM_TEAM.BI_hechos_ventas hv ON (hd.id_hecho_venta = hv.id_hecho_venta)
    JOIN BI_DREAM_TEAM.BI_tipo_descuento td ON (hd.tipo_descuento_id = td.id_tipo_descuento)
    JOIN BI_DREAM_TEAM.BI_canal_de_venta cv ON (hv.canal_id = cv.id_canal_venta)
    JOIN BI_DREAM_TEAM.BI_tiempo t ON (hv.tiempo_id = t.id_tiempo)
    GROUP BY td.descripcion, cv.nombre, t.tiempo_mes, t.tiempo_anio
GO

--VISTA 6
CREATE VIEW BI_DREAM_TEAM.BI_6_porcentaje_envios_provincia_mes AS
    SELECT p.nombre AS 'Provincia', CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Fecha',
		   CAST(SUM(he.cantidad) AS DECIMAL)/(CAST(aux.cantidadTotalEnvios AS DECIMAL)) * 100 AS 'Porcentaje'
	FROM BI_DREAM_TEAM.BI_hechos_envios he
	JOIN BI_DREAM_TEAM.BI_tiempo t ON(t.id_tiempo = he.tiempo_id)
	JOIN BI_DREAM_TEAM.BI_provincia p ON(p.id_provincia = he.provincia_id)
	JOIN (SELECT SUM(he1.cantidad) cantidadTotalEnvios, he1.tiempo_id tiempo
		  FROM BI_DREAM_TEAM.BI_hechos_envios he1
		  GROUP BY he1.tiempo_id) aux ON(aux.tiempo = he.tiempo_id)
	GROUP BY p.nombre, t.tiempo_anio, t.tiempo_mes, aux.cantidadTotalEnvios
GO

----VISTA 7
CREATE VIEW BI_DREAM_TEAM.BI_7_promedio_envio_provincia_medio_envio AS
    SELECT p.nombre AS 'Provincia', te.descripcion AS 'Tipo Envio', t.tiempo_anio AS 'Anio',
            SUM(he.monto_total_envios)/SUM(he.cantidad) AS 'Valor Promedio'
    FROM BI_DREAM_TEAM.BI_hechos_envios he
    JOIN BI_DREAM_TEAM.BI_provincia p ON(he.provincia_id = p.id_provincia)
    JOIN BI_DREAM_TEAM.BI_tiempo t ON(he.tiempo_id = t.id_tiempo)
    JOIN BI_DREAM_TEAM.BI_tipo_envio te ON(he.id_tipo_envio = te.id_tipo_envio)
    GROUP BY p.nombre, te.descripcion, t.tiempo_anio
GO

----VISTA 8
CREATE VIEW BI_DREAM_TEAM.BI_8_aumento_promedio_proveedor_anio AS
    SELECT DISTINCT pr.razon_social AS 'Proveedor', pr.cuit AS 'Cuit proveedor', t.tiempo_anio AS 'Anio', AVG(productos.aumento) AS 'Promedio' 
    FROM BI_DREAM_TEAM.BI_hechos_compras_productos hcp
    JOIN BI_DREAM_TEAM.BI_proveedor pr ON(pr.cuit = hcp.proveedor_id)
    JOIN BI_DREAM_TEAM.BI_tiempo t ON(t.id_tiempo = hcp.tiempo_id)
    JOIN (SELECT (MAX(monto_total_producto/cantidad)-MIN(monto_total_producto/cantidad))/MIN(monto_total_producto/cantidad) AS aumento,
            hcp2.proveedor_id AS proveedor, t2.tiempo_anio AS anio, hcp2.producto_id
        FROM BI_DREAM_TEAM.BI_hechos_compras_productos hcp2
        JOIN BI_DREAM_TEAM.BI_tiempo t2 ON (hcp2.tiempo_id = t2.id_tiempo)
        GROUP BY hcp2.producto_id, hcp2.proveedor_id, t2.tiempo_anio) AS productos
    ON (productos.proveedor = hcp.proveedor_id AND productos.anio = t.tiempo_anio)
    GROUP BY pr.razon_social, pr.cuit, t.tiempo_anio
GO

----VISTA 9 (Tarda de 45 segundos a 2 minutos en ejecutarse)
CREATE VIEW BI_DREAM_TEAM.BI_9_productos_mayor_reposicion_mes AS
	SELECT p.nombre AS 'Producto',
		   CAST(t.tiempo_mes AS VARCHAR(20))+'/'+CAST(t.tiempo_anio AS VARCHAR(20)) AS 'Fecha',
		   SUM(cp.cantidad) AS 'Cantidad reposicion'
	FROM BI_DREAM_TEAM.BI_hechos_compras_productos cp
	JOIN BI_DREAM_TEAM.BI_tiempo t ON(t.id_tiempo = cp.tiempo_id)
	JOIN BI_DREAM_TEAM.BI_producto p ON(p.id_producto = cp.producto_id)
	WHERE cp.producto_id IN (SELECT TOP 3 cp1.producto_id
							 FROM BI_DREAM_TEAM.BI_hechos_compras_productos cp1
							 WHERE cp1.tiempo_id = cp.tiempo_id
							 GROUP BY cp1.producto_id
							 ORDER BY SUM(cp1.cantidad) DESC)
	GROUP BY p.nombre, t.tiempo_mes, t.tiempo_anio
GO
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------- COMANDOS ------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
EXECUTE BI_DREAM_TEAM.migrar_BI_rango_etario
	PRINT N'Rango etario';  
EXECUTE BI_DREAM_TEAM.migrar_BI_tiempo
	PRINT N'Tiempo';
EXECUTE BI_DREAM_TEAM.migrar_BI_canal_de_venta
	PRINT N'Canal de venta';
EXECUTE BI_DREAM_TEAM.migrar_BI_categoria_producto
	PRINT N'Categoria producto';
EXECUTE BI_DREAM_TEAM.migrar_BI_tipo_descuento
	PRINT N'Tipo descuento';
EXECUTE BI_DREAM_TEAM.migrar_BI_medio_pago
	PRINT N'Medio pago';
EXECUTE BI_DREAM_TEAM.migrar_BI_provincia
	PRINT N'Provincia';
EXECUTE BI_DREAM_TEAM.migrar_BI_tipo_envio
	PRINT N'Tipo envio';
EXECUTE BI_DREAM_TEAM.migrar_BI_proveedor
	PRINT N'Proveedor';
EXECUTE BI_DREAM_TEAM.migrar_BI_producto
	PRINT N'Producto';

---- Empiezan HECHOS
PRINT N'Empiezan los HECHOS!';

EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_ventas
	PRINT N'Hechos ventas';
EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_compras
	PRINT N'Hechos compras';
EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_envios
	PRINT N'Hechos envios';
EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_ventas_productos
	PRINT N'Hechos ventas productos';
EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_compras_productos
	PRINT N'Hechos compras productos';
EXECUTE BI_DREAM_TEAM.migrar_BI_hechos_descuentos
	PRINT N'Hechos descuentos';

---- SCHEMA, FUNCTIONS, TABLES, VIEWS
--DROP SCHEMA BI_DREAM_TEAM
--DROP FUNCTION BI_DREAM_TEAM.calcular_rango_etario

--DROP TABLE BI_DREAM_TEAM.BI_rango_etario
--DROP TABLE BI_DREAM_TEAM.BI_tiempo
--DROP TABLE BI_DREAM_TEAM.BI_canal_de_venta
--DROP TABLE BI_DREAM_TEAM.BI_categoria_producto
--DROP TABLE BI_DREAM_TEAM.BI_tipo_descuento
--DROP TABLE BI_DREAM_TEAM.BI_medio_pago
--DROP TABLE BI_DREAM_TEAM.BI_provincia
--DROP TABLE BI_DREAM_TEAM.BI_tipo_envio
--DROP TABLE BI_DREAM_TEAM.BI_proveedor
--DROP TABLE BI_DREAM_TEAM.BI_producto

--DROP TABLE BI_DREAM_TEAM.BI_hechos_ventas
--DROP TABLE BI_DREAM_TEAM.BI_hechos_compras
--DROP TABLE BI_DREAM_TEAM.BI_hechos_envios
--DROP TABLE BI_DREAM_TEAM.BI_hechos_ventas_productos
--DROP TABLE BI_DREAM_TEAM.BI_hechos_compras_productos
--DROP TABLE BI_DREAM_TEAM.BI_hechos_descuentos

--DROP VIEW BI_DREAM_TEAM.BI_1_ganancias_mes_canal_venta
--DROP VIEW BI_DREAM_TEAM.BI_2_productos_mayor_rentabilidad_anio
--DROP VIEW BI_DREAM_TEAM.BI_3_categorias_mas_venddias_edad_mes
--DROP VIEW BI_DREAM_TEAM.BI_4_ingresos_netos_medio_pago_mes
--DROP VIEW BI_DREAM_TEAM.BI_5_total_descuento_tipo_canal_venta_mes
--DROP VIEW BI_DREAM_TEAM.BI_6_porcentaje_envios_provincia_mes
--DROP VIEW BI_DREAM_TEAM.BI_7_promedio_envio_provincia_medio_envio
--DROP VIEW BI_DREAM_TEAM.BI_8_aumento_promedio_proveedor_anio
--DROP VIEW BI_DREAM_TEAM.BI_9_productos_mayor_reposicion_mes

----PROCEDURES

--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_rango_etario
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_tiempo
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_canal_de_venta
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_categoria_producto
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_tipo_descuento
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_medio_pago
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_provincia
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_tipo_envio
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_proveedor
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_producto

--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_ventas
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_compras
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_envios
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_ventas_productos
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_compras_productos
--DROP PROCEDURE BI_DREAM_TEAM.migrar_BI_hechos_descuentos







