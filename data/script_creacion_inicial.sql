USE GD2C2022
GO
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ CREACION DE SCHEMA ---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
--DROP SCHEMA DREAM_TEAM
CREATE SCHEMA DREAM_TEAM;
GO

--DROP FUNCTION DREAM_TEAM.calcular_envio_gratis
CREATE FUNCTION
DREAM_TEAM.calcular_envio_gratis
(@total_venta AS DECIMAL(18,2))
RETURNS BIT
AS
BEGIN
DECLARE @monto_minimo DECIMAL(18,2), @envio_gratis BIT;
	SET @monto_minimo = 10000000.00; /* Este es el monto que definimos, podria ser cualquiera */

	IF @total_venta >= @monto_minimo
		SET @envio_gratis = 1;
	ELSE
		SET @envio_gratis = 0;
	RETURN @envio_gratis;
END;
GO

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ CREACION DE TABLAS ---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE DREAM_TEAM.medio_de_envios(
	id_medio INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.provincia(
	id_provincia INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

 CREATE TABLE DREAM_TEAM.localidad(
 	id_localidad INTEGER IDENTITY(1,1) PRIMARY KEY,
 	descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.codigo_postal_localidad(
	id_cp_localidad INTEGER IDENTITY(1,1) PRIMARY KEY,
	provincia_id INTEGER,
	FOREIGN KEY(provincia_id) REFERENCES DREAM_TEAM.provincia(id_provincia),
	codigo_postal DECIMAL(18,0),
	localidad_id INTEGER,
	FOREIGN KEY(localidad_id) REFERENCES DREAM_TEAM.localidad(id_localidad)
);

CREATE TABLE DREAM_TEAM.medio_de_envios_cp(
	id_medio_de_envios_cp INTEGER IDENTITY(1,1) PRIMARY KEY,
	cp_localidad_id INTEGER,
	FOREIGN KEY(cp_localidad_id) REFERENCES DREAM_TEAM.codigo_postal_localidad(id_cp_localidad),
	medio_id INTEGER,
	FOREIGN KEY(medio_id) REFERENCES DREAM_TEAM.medio_de_envios(id_medio),
);

CREATE TABLE DREAM_TEAM.canal_de_venta(
	id_canal INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255),
	costo DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.cliente(
	id_cliente INTEGER IDENTITY(1,1) PRIMARY KEY,
	provincia VARCHAR(255),
	cp_localidad_id INTEGER,
	FOREIGN KEY(cp_localidad_id) REFERENCES DREAM_TEAM.codigo_postal_localidad(id_cp_localidad),
	nombre VARCHAR(255),
	apellido VARCHAR(255),
	dni INTEGER,
	direccion VARCHAR(255),
	telefono DECIMAL(18,0),
	mail VARCHAR(255),
	nacimiento DATE
);

CREATE TABLE DREAM_TEAM.medio_pago_venta(
	id_medio_pago_v INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255),
	descuento DECIMAL(18,2),
	recargo DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.tipo_descuento(
	id_tipo_descuento INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255),
);

CREATE TABLE DREAM_TEAM.venta(
	id_venta DECIMAL(19,0) PRIMARY KEY,
	cliente_id INTEGER,
	FOREIGN KEY(cliente_id) REFERENCES DREAM_TEAM.cliente(id_cliente),
	canal_de_venta_id INTEGER,
	FOREIGN KEY(canal_de_venta_id) REFERENCES DREAM_TEAM.canal_de_venta(id_canal),
	medio_pago_id INTEGER,
	FOREIGN KEY(medio_pago_id) REFERENCES DREAM_TEAM.medio_pago_venta(id_medio_pago_v),
	fecha DATE,
	total_venta DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.entrega(
	id_entrega INTEGER IDENTITY(1,1) PRIMARY KEY,
	medio_envio_cp_id INTEGER,
	FOREIGN KEY(medio_envio_cp_id) REFERENCES DREAM_TEAM.medio_de_envios_cp(id_medio_de_envios_cp),
	venta_id DECIMAL(19,0),
	FOREIGN KEY(venta_id) REFERENCES DREAM_TEAM.venta(id_venta),
	costo_envio DECIMAL(18, 2),
	envio_gratis BIT
);

CREATE TABLE DREAM_TEAM.marca(
	id_marca INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.categoria(
	id_categoria INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.material(
	id_material INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.producto(
	id_producto VARCHAR(50) PRIMARY KEY,
	nombre VARCHAR(50),
	descripcion VARCHAR(50),
	material_id INTEGER,
	FOREIGN KEY(material_id) REFERENCES DREAM_TEAM.material(id_material),
	marca_id INTEGER,
	FOREIGN KEY(marca_id) REFERENCES DREAM_TEAM.marca(id_marca),
	categoria_id INTEGER,
	FOREIGN KEY(categoria_id) REFERENCES DREAM_TEAM.categoria(id_categoria)
);

CREATE TABLE DREAM_TEAM.tipo_variante(
    id_tipo_variante INTEGER IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50)
);

CREATE TABLE DREAM_TEAM.variante(
    id_variante INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_variante_id INTEGER,
    FOREIGN KEY(tipo_variante_id) REFERENCES DREAM_TEAM.tipo_variante(id_tipo_variante),
    descripcion VARCHAR(50)
);

CREATE TABLE DREAM_TEAM.producto_variante(
    id_producto_variante VARCHAR(50) PRIMARY KEY,
	producto_id VARCHAR(50),
    FOREIGN KEY(producto_id) REFERENCES DREAM_TEAM.producto(id_producto),
	variante_id INTEGER,
    FOREIGN KEY(variante_id) REFERENCES DREAM_TEAM.variante(id_variante),
    precio_unitario DECIMAL(18,2),
    stock INTEGER
);

CREATE TABLE DREAM_TEAM.item_venta(
	id_item_venta INTEGER IDENTITY(1,1) PRIMARY KEY,
	producto_variante_id VARCHAR(50),
	FOREIGN KEY(producto_variante_id) REFERENCES DREAM_TEAM.producto_variante(id_producto_variante),
	venta_id DECIMAL(19,0),
	FOREIGN KEY(venta_id) REFERENCES DREAM_TEAM.venta(id_venta),
	cantidad DECIMAL(18,0),
	precio_unitario DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.descuento_venta(
	id_descuento_venta  INTEGER IDENTITY(1,1) PRIMARY KEY,
	venta_id DECIMAL(19,0),
	FOREIGN KEY(venta_id) REFERENCES DREAM_TEAM.venta(id_venta),
	tipo_descuento_id INTEGER,
	FOREIGN KEY(tipo_descuento_id) REFERENCES DREAM_TEAM.tipo_descuento(id_tipo_descuento),
	importe DECIMAL(18,2)
);

----- Compra -----
CREATE TABLE DREAM_TEAM.medio_pago_compra(
    id_medio_pago_c INTEGER IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(255)
);

CREATE TABLE DREAM_TEAM.proveedor(
	cuit VARCHAR(50) PRIMARY KEY,
	provincia VARCHAR(255),
	cp_localidad_id INTEGER,
	FOREIGN KEY(cp_localidad_id) REFERENCES DREAM_TEAM.codigo_postal_localidad(id_cp_localidad),
	razon_social VARCHAR(50),
	domicilio VARCHAR(50),
	mail VARCHAR(50)
);

CREATE TABLE DREAM_TEAM.compra(
    id_compra DECIMAL(19,0) PRIMARY KEY,
    proveedor_id VARCHAR(50),
    FOREIGN KEY(proveedor_id) REFERENCES  DREAM_TEAM.proveedor(cuit),
    medio_pago_id INTEGER,
    FOREIGN KEY(medio_pago_id) REFERENCES DREAM_TEAM.medio_pago_compra(id_medio_pago_c),
    fecha DATE,
    total_compra DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.descuento_compra(
    id_descuento DECIMAL(19,0) PRIMARY KEY,
    compra_id DECIMAL(19,0),
	FOREIGN KEY(compra_id) REFERENCES DREAM_TEAM.compra(id_compra),
    valor DECIMAL(18,2)
);

CREATE TABLE DREAM_TEAM.item_compra(
	id_item_compra INTEGER IDENTITY(1,1) PRIMARY KEY,
	producto_variante_id VARCHAR(50),
	FOREIGN KEY(producto_variante_id) REFERENCES DREAM_TEAM.producto_variante(id_producto_variante),
	compra_id DECIMAL(19,0),
	FOREIGN KEY(compra_id) REFERENCES DREAM_TEAM.compra(id_compra),
	cantidad DECIMAL(18,0),
	precio_unitario DECIMAL(18,2)
);

--CUPONES
CREATE TABLE DREAM_TEAM.cupon(
	id_cupon VARCHAR(255) PRIMARY KEY,
	fecha_desde DATE,
	fecha_hasta DATE,
	valor DECIMAL(18,2),
	tipo VARCHAR(50)
);

CREATE TABLE DREAM_TEAM.descuento_cupon_venta(
	id_descuento_cupon_venta INTEGER PRIMARY KEY IDENTITY(1,1),
	venta_id DECIMAL(19,0),
	FOREIGN KEY(venta_id) REFERENCES DREAM_TEAM.venta(id_venta),
	cupon_id VARCHAR(255),
	FOREIGN KEY(cupon_id) REFERENCES DREAM_TEAM.cupon(id_cupon),
	importe DECIMAL(18,2)
);

GO
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------ CREACIÓN DE STORED PROCEDURES PARA MIGRACIÓN -------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE DREAM_TEAM.migrar_marca
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.marca (descripcion)
	SELECT DISTINCT PRODUCTO_MARCA
	FROM gd_esquema.Maestra
	WHERE PRODUCTO_MARCA IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_categoria
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.categoria (descripcion)
	SELECT DISTINCT PRODUCTO_CATEGORIA
	FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_material
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.material (descripcion)
	SELECT DISTINCT PRODUCTO_MATERIAL
	FROM gd_esquema.Maestra
	WHERE PRODUCTO_MATERIAL IS NOT NULL
  END
GO
-- 
CREATE PROCEDURE DREAM_TEAM.migrar_tipo_variante
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.tipo_variante (descripcion)
	SELECT DISTINCT PRODUCTO_TIPO_VARIANTE
	FROM gd_esquema.Maestra
	WHERE PRODUCTO_TIPO_VARIANTE IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_medio_de_envios
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.medio_de_envios (descripcion)
	SELECT DISTINCT VENTA_MEDIO_ENVIO
	FROM gd_esquema.Maestra
	WHERE VENTA_MEDIO_ENVIO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_provincia
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.provincia (descripcion)
	SELECT DISTINCT CLIENTE_PROVINCIA
	FROM gd_esquema.Maestra
	WHERE CLIENTE_PROVINCIA IS NOT NULL
	UNION
	SELECT DISTINCT PROVEEDOR_PROVINCIA
	FROM gd_esquema.Maestra
	WHERE PROVEEDOR_PROVINCIA IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_localidad
 AS
  BEGIN
	INSERT INTO DREAM_TEAM.localidad (descripcion)
	SELECT DISTINCT CLIENTE_LOCALIDAD
	FROM gd_esquema.Maestra
	WHERE CLIENTE_LOCALIDAD IS NOT NULL
	UNION
	SELECT DISTINCT PROVEEDOR_LOCALIDAD
	FROM gd_esquema.Maestra
	WHERE PROVEEDOR_LOCALIDAD IS NOT NULL 
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_codigo_postal_localidad --MARMO: hay que hacer una especie de gorup by porque el distinct esta MALMO hahaha xd
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.codigo_postal_localidad(provincia_id, codigo_postal, localidad_id)
	SELECT DISTINCT id_provincia, CLIENTE_CODIGO_POSTAL, id_localidad
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.provincia p ON (gd.CLIENTE_PROVINCIA = p.descripcion)
	JOIN DREAM_TEAM.localidad l ON (gd.CLIENTE_LOCALIDAD = l.descripcion)
	WHERE CLIENTE_CODIGO_POSTAL IS NOT NULL AND CLIENTE_LOCALIDAD IS NOT NULL
	GROUP BY id_provincia, CLIENTE_CODIGO_POSTAL, id_localidad
	UNION -- GUARDA!!!!! si tarda mucho la migracion volamos lo de abajo
	SELECT DISTINCT id_provincia, PROVEEDOR_CODIGO_POSTAL, id_localidad
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.provincia p ON (gd.PROVEEDOR_PROVINCIA = p.descripcion)
	JOIN DREAM_TEAM.localidad l ON (gd.PROVEEDOR_LOCALIDAD = l.descripcion)
	WHERE PROVEEDOR_CODIGO_POSTAL IS NOT NULL AND PROVEEDOR_LOCALIDAD IS NOT NULL
	GROUP BY id_provincia, PROVEEDOR_CODIGO_POSTAL, id_localidad
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_medio_de_envios_cp
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.medio_de_envios_cp(medio_id, cp_localidad_id)
	SELECT DISTINCT id_medio, id_cp_localidad
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.medio_de_envios mde ON(mde.descripcion = gd.VENTA_MEDIO_ENVIO)
	JOIN DREAM_TEAM.localidad l ON(l.descripcion = gd.CLIENTE_LOCALIDAD)
	JOIN DREAM_TEAM.codigo_postal_localidad cpl ON(cpl.localidad_id = l.id_localidad AND cpl.codigo_postal = gd.CLIENTE_CODIGO_POSTAL)
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_canal_de_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.canal_de_venta (descripcion, costo)
	SELECT DISTINCT VENTA_CANAL, VENTA_CANAL_COSTO
	FROM gd_esquema.Maestra gd
	WHERE VENTA_CANAL IS NOT NULL
  END
GO
-- 
CREATE PROCEDURE DREAM_TEAM.migrar_tipo_descuento
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.tipo_descuento (descripcion)
	SELECT DISTINCT VENTA_DESCUENTO_CONCEPTO
	FROM gd_esquema.Maestra
	WHERE VENTA_DESCUENTO_CONCEPTO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_cupon
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.cupon (id_cupon, fecha_desde, fecha_hasta, valor, tipo)
	SELECT DISTINCT VENTA_CUPON_CODIGO, VENTA_CUPON_FECHA_DESDE, VENTA_CUPON_FECHA_HASTA, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO
	FROM gd_esquema.Maestra
	WHERE VENTA_CUPON_CODIGO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_medio_pago_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.medio_pago_venta (descripcion, recargo) -- no pasamos descuento
	SELECT DISTINCT VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO 
	FROM gd_esquema.Maestra
	WHERE VENTA_MEDIO_PAGO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_medio_pago_compra
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.medio_pago_compra (descripcion)
	SELECT DISTINCT COMPRA_MEDIO_PAGO
	FROM gd_esquema.Maestra
	WHERE COMPRA_MEDIO_PAGO IS NOT NULL
  END
GO
-- ACA ARRANCAN LAS QUE TIENEN FK
CREATE PROCEDURE DREAM_TEAM.migrar_producto
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.producto (id_producto, nombre, descripcion, material_id, marca_id, categoria_id)
	SELECT DISTINCT PRODUCTO_CODIGO, PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION, id_material, id_marca, id_categoria
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.marca m ON (gd.PRODUCTO_MARCA = m.descripcion)
	JOIN DREAM_TEAM.categoria c ON (gd.PRODUCTO_CATEGORIA = c.descripcion)
	JOIN DREAM_TEAM.material mat ON (gd.PRODUCTO_MATERIAL = mat.descripcion)
	WHERE PRODUCTO_CODIGO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_variante
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.variante (descripcion, tipo_variante_id)
	SELECT DISTINCT PRODUCTO_VARIANTE, id_tipo_variante 
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.tipo_variante tv ON (gd.PRODUCTO_TIPO_VARIANTE = tv.descripcion)
	WHERE PRODUCTO_VARIANTE IS NOT NULL
  END
GO
-- 
CREATE PROCEDURE DREAM_TEAM.migrar_entrega
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.entrega (medio_envio_cp_id, venta_id, costo_envio, envio_gratis)
	SELECT DISTINCT id_medio_de_envios_cp, id_venta, VENTA_ENVIO_PRECIO, DREAM_TEAM.calcular_envio_gratis(total_venta)
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.medio_de_envios mde ON (gd.VENTA_MEDIO_ENVIO = mde.descripcion)
	JOIN DREAM_TEAM.provincia p ON(gd.CLIENTE_PROVINCIA = p.descripcion)
	JOIN DREAM_TEAM.localidad l ON(gd.CLIENTE_LOCALIDAD = l.descripcion)
	JOIN DREAM_TEAM.codigo_postal_localidad cpl ON(cpl.provincia_id = p.id_provincia AND l.id_localidad = cpl.localidad_id AND gd.CLIENTE_CODIGO_POSTAL = cpl.codigo_postal)
	JOIN DREAM_TEAM.medio_de_envios_cp mec ON(mec.medio_id = mde.id_medio AND mec.cp_localidad_id = cpl.id_cp_localidad)
	JOIN DREAM_TEAM.venta v ON (gd.VENTA_CODIGO = v.id_venta)
	WHERE VENTA_ENVIO_PRECIO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_cliente
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.cliente (dni, provincia, cp_localidad_id, nombre, apellido, direccion, telefono, mail, nacimiento)
	SELECT DISTINCT CLIENTE_DNI, p.descripcion, id_cp_localidad, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_TELEFONO, CLIENTE_MAIL, CLIENTE_FECHA_NAC
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.provincia p ON(gd.CLIENTE_PROVINCIA = p.descripcion)
	JOIN DREAM_TEAM.localidad l ON(gd.CLIENTE_LOCALIDAD = l.descripcion)
	JOIN DREAM_TEAM.codigo_postal_localidad cpl ON(cpl.provincia_id = p.id_provincia AND l.id_localidad = cpl.localidad_id AND gd.CLIENTE_CODIGO_POSTAL = cpl.codigo_postal)
	WHERE CLIENTE_DNI IS NOT NULL
	GROUP BY CLIENTE_DNI, p.descripcion, id_cp_localidad, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_TELEFONO, CLIENTE_MAIL, CLIENTE_FECHA_NAC
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_proveedor
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.proveedor (cuit, provincia, cp_localidad_id, razon_social, domicilio, mail)
	SELECT DISTINCT PROVEEDOR_CUIT, p.descripcion, id_cp_localidad, PROVEEDOR_RAZON_SOCIAL, PROVEEDOR_DOMICILIO, PROVEEDOR_MAIL
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.provincia p ON(gd.PROVEEDOR_PROVINCIA = p.descripcion)
	JOIN DREAM_TEAM.localidad l ON(gd.PROVEEDOR_LOCALIDAD = l.descripcion)
	JOIN DREAM_TEAM.codigo_postal_localidad cpl ON(cpl.provincia_id = p.id_provincia AND l.id_localidad = cpl.localidad_id AND gd.PROVEEDOR_CODIGO_POSTAL = cpl.codigo_postal)
	WHERE PROVEEDOR_CUIT IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.venta (id_venta, cliente_id, canal_de_venta_id, medio_pago_id, fecha, total_venta)
	SELECT DISTINCT VENTA_CODIGO, id_cliente, id_canal, id_medio_pago_v, VENTA_FECHA, VENTA_TOTAL
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.canal_de_venta ca ON (gd.VENTA_CANAL = ca.descripcion)
	JOIN DREAM_TEAM.medio_pago_venta mpv ON (gd.VENTA_MEDIO_PAGO = mpv.descripcion)
	JOIN DREAM_TEAM.cliente c ON (gd.CLIENTE_DNI = c.dni AND gd.CLIENTE_APELLIDO = c.apellido)
	WHERE VENTA_CODIGO IS NOT NULL
  END
GO
--
CREATE PROCEDURE DREAM_TEAM.migrar_compra
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.compra (id_compra, proveedor_id, medio_pago_id, fecha, total_compra)
	SELECT DISTINCT COMPRA_NUMERO, cuit, id_medio_pago_c, COMPRA_FECHA, COMPRA_TOTAL
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.proveedor p ON (gd.PROVEEDOR_CUIT = p.cuit )
	JOIN DREAM_TEAM.medio_pago_compra mpc ON (gd.COMPRA_MEDIO_PAGO = mpc.descripcion)
	WHERE COMPRA_NUMERO IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_item_compra
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.item_compra (producto_variante_id, compra_id, cantidad, precio_unitario) /* FALTA CANTIDAD */
	SELECT id_producto_variante, id_compra, COMPRA_PRODUCTO_CANTIDAD, COMPRA_PRODUCTO_PRECIO
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.producto_variante pv ON (gd.PRODUCTO_VARIANTE_CODIGO = pv.id_producto_variante)
	JOIN DREAM_TEAM.compra c ON (gd.COMPRA_NUMERO = c.id_compra)
	WHERE COMPRA_PRODUCTO_CANTIDAD IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_item_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.item_venta (producto_variante_id, venta_id, cantidad, precio_unitario)
	SELECT DISTINCT id_producto_variante, id_venta, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.producto_variante pv ON (gd.PRODUCTO_VARIANTE_CODIGO = pv.id_producto_variante)
	JOIN DREAM_TEAM.venta v ON (gd.VENTA_CODIGO = v.id_venta)
	WHERE VENTA_PRODUCTO_CANTIDAD IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_descuento_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.descuento_venta (venta_id, tipo_descuento_id, importe)
	SELECT DISTINCT id_venta, id_tipo_descuento, VENTA_DESCUENTO_IMPORTE
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.venta v ON(gd.VENTA_CODIGO = v.id_venta)
	JOIN DREAM_TEAM.tipo_descuento td ON(gd.VENTA_DESCUENTO_CONCEPTO = td.descripcion)
	WHERE VENTA_DESCUENTO_CONCEPTO IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_descuento_compra
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.descuento_compra (id_descuento, compra_id, valor)
	SELECT DISTINCT DESCUENTO_COMPRA_CODIGO, id_compra, DESCUENTO_COMPRA_VALOR
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.compra c ON(gd.COMPRA_NUMERO = c.id_compra)
	WHERE DESCUENTO_COMPRA_CODIGO IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_descuento_cupon_venta
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.descuento_cupon_venta (venta_id, cupon_id, importe)
	SELECT DISTINCT id_venta, id_cupon, VENTA_CUPON_IMPORTE
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.venta v ON(gd.VENTA_CODIGO = v.id_venta)
	JOIN DREAM_TEAM.cupon c ON(gd.VENTA_CUPON_CODIGO = c.id_cupon)
	WHERE VENTA_CUPON_CODIGO IS NOT NULL
  END
GO
--

CREATE PROCEDURE DREAM_TEAM.migrar_producto_variante
 AS
  BEGIN
    INSERT INTO DREAM_TEAM.producto_variante (id_producto_variante, producto_id, variante_id)
	SELECT DISTINCT PRODUCTO_VARIANTE_CODIGO, p.id_producto, v.id_variante
	FROM gd_esquema.Maestra gd
	JOIN DREAM_TEAM.producto p ON (gd.PRODUCTO_CODIGO = p.id_producto)
	JOIN DREAM_TEAM.variante v ON (gd.PRODUCTO_VARIANTE = v.descripcion)
	WHERE PRODUCTO_VARIANTE_CODIGO IS NOT NULL
	GROUP BY PRODUCTO_VARIANTE_CODIGO, p.id_producto, v.id_variante
  END
GO

-----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- PROCEDURES DE COLUMNAS CALCULABLES -------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE DREAM_TEAM.insert_stock_producto_variante
AS
  BEGIN
    DECLARE item_cursor CURSOR FOR
    SELECT id_producto_variante
    FROM DREAM_TEAM.producto_variante

    DECLARE @producto_variante_id VARCHAR(50), @total_cantidad_c INTEGER, @total_cantidad_v INTEGER, @stock INTEGER
	OPEN item_cursor
    FETCH NEXT FROM item_cursor INTO @producto_variante_id

    WHILE (@@FETCH_STATUS = 0)
        BEGIN
            SELECT @total_cantidad_c = SUM(cantidad)
            FROM DREAM_TEAM.item_compra
            WHERE producto_variante_id = @producto_variante_id

            SELECT @total_cantidad_v = SUM(cantidad)
            FROM DREAM_TEAM.item_venta
            WHERE producto_variante_id = @producto_variante_id

            SET @stock = @total_cantidad_c - @total_cantidad_v

			UPDATE DREAM_TEAM.producto_variante
			SET stock = @stock
			WHERE id_producto_variante = @producto_variante_id

            FETCH NEXT FROM item_cursor INTO @producto_variante_id
        END

        CLOSE item_cursor
        DEALLOCATE item_cursor
    END
GO
--
CREATE PROCEDURE DREAM_TEAM.insert_precio_unitario_producto_variante
AS
  BEGIN
	DECLARE producto_variante_cursor CURSOR FOR
	SELECT id_producto_variante
	FROM DREAM_TEAM.producto_variante

	DECLARE @producto_variante_id VARCHAR(50), @precio_unitario DECIMAL(18,2)
	OPEN producto_variante_cursor
	FETCH NEXT FROM producto_variante_cursor INTO @producto_variante_id

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @precio_unitario = (SELECT TOP 1 precio_unitario
									FROM DREAM_TEAM.item_venta iv
									JOIN DREAM_TEAM.venta v ON(iv.venta_id = v.id_venta)
									WHERE producto_variante_id = @producto_variante_id
									ORDER by fecha DESC
									)
			UPDATE DREAM_TEAM.producto_variante
			SET precio_unitario = @precio_unitario
			WHERE id_producto_variante = @producto_variante_id

			FETCH NEXT FROM producto_variante_cursor INTO @producto_variante_id
		END

		CLOSE producto_variante_cursor
		DEALLOCATE producto_variante_cursor
	END
GO

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------ EJECUCIÓN DE STORED PROCEDURES PARA MIGRACIÓN ------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
BEGIN TRY
	-- Migracion de tablas
	EXECUTE DREAM_TEAM.migrar_tipo_variante
	PRINT N'Tipo variante';  
	EXECUTE DREAM_TEAM.migrar_marca
	PRINT N'Marca';  
	EXECUTE DREAM_TEAM.migrar_categoria
	PRINT N'Categoria';  
	EXECUTE DREAM_TEAM.migrar_material
	PRINT N'Material'; 
	EXECUTE DREAM_TEAM.migrar_medio_de_envios
	PRINT N'Medio de envios'; 
	EXECUTE DREAM_TEAM.migrar_provincia
	PRINT N'Provincia'; 
	EXECUTE DREAM_TEAM.migrar_localidad
	PRINT N'Localidad'; 
	EXECUTE DREAM_TEAM.migrar_canal_de_venta
	PRINT N'Canal de venta'; 
	EXECUTE DREAM_TEAM.migrar_cupon
	PRINT N'Cupon'; 
	EXECUTE DREAM_TEAM.migrar_tipo_descuento
	PRINT N'Tipo descuento'; 
	EXECUTE DREAM_TEAM.migrar_medio_pago_venta
	PRINT N'Medio pago venta'; 
	EXECUTE DREAM_TEAM.migrar_medio_pago_compra
	PRINT N'Medio pago compra'; 
	EXECUTE DREAM_TEAM.migrar_codigo_postal_localidad
	PRINT N'Codigo postal';
	EXECUTE DREAM_TEAM.migrar_medio_de_envios_cp
	PRINT N'Medio de envios por CP'; 
	EXECUTE DREAM_TEAM.migrar_producto
	PRINT N'Producto'; 
	EXECUTE DREAM_TEAM.migrar_variante
	PRINT N'Variante'; 
	EXECUTE DREAM_TEAM.migrar_producto_variante
	PRINT N'Producto variante'; 
	EXECUTE DREAM_TEAM.migrar_proveedor
	PRINT N'Proveedor'; 
	EXECUTE DREAM_TEAM.migrar_cliente
	PRINT N'Cliente'; 
	EXECUTE DREAM_TEAM.migrar_compra
	PRINT N'Compra'; 
	EXECUTE DREAM_TEAM.migrar_venta
	PRINT N'Venta'; 
	EXECUTE DREAM_TEAM.migrar_entrega
	PRINT N'Entrega'; 
	EXECUTE DREAM_TEAM.migrar_item_compra
	PRINT N'Item compra'; 
	EXECUTE DREAM_TEAM.migrar_item_venta
	PRINT N'Item venta'; 
	EXECUTE DREAM_TEAM.migrar_descuento_venta
	PRINT N'Descuento venta'; 
	EXECUTE DREAM_TEAM.migrar_descuento_cupon_venta
	PRINT N'Descuento cupon venta'; 
	EXECUTE DREAM_TEAM.migrar_descuento_compra
	PRINT N'Descuento compra'; 
	-- Columnas calculables
	PRINT N'Comienzo migracion columnas calculables'
	EXECUTE DREAM_TEAM.insert_stock_producto_variante
	PRINT N'---- Stock producto variante'; 
	EXECUTE DREAM_TEAM.insert_precio_unitario_producto_variante
	PRINT N'---- Precio unitario producto variante'; 
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
		THROW 50001, 'Error al migrar las tablas.', 1;
END CATCH
IF (
	EXISTS (SELECT 1 FROM DREAM_TEAM.tipo_variante)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.variante)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.marca)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.categoria)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.material)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.producto)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.producto_variante)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.medio_de_envios)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.provincia)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.entrega)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.canal_de_venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.item_venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.item_compra)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.compra)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.proveedor)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.descuento_cupon_venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.descuento_venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.medio_pago_venta)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.medio_pago_compra)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.descuento_compra)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.cliente)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.tipo_descuento)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.cupon)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.codigo_postal_localidad)
	AND EXISTS (SELECT 1 FROM DREAM_TEAM.medio_de_envios_cp)
	)
	BEGIN
		PRINT 'Tablas migradas correctamente.';
		COMMIT TRANSACTION;
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50002, 'Error al migrar las tablas. Ningún cambio fue realizado.',1;
	END   
GO

--------------------- DROPS ---------------------
--DROP SCHEMA DREAM_TEAM
--DROP FUNCTION DREAM_TEAM.calcular_envio_gratis

--DROP TABLE DREAM_TEAM.tipo_variante
--DROP TABLE DREAM_TEAM.variante
--DROP TABLE DREAM_TEAM.marca
--DROP TABLE DREAM_TEAM.categoria
--DROP TABLE DREAM_TEAM.material
--DROP TABLE DREAM_TEAM.producto
--DROP TABLE DREAM_TEAM.producto_variante
--DROP TABLE DREAM_TEAM.medio_de_envios
--DROP TABLE DREAM_TEAM.medio_de_envios_cp
--DROP TABLE DREAM_TEAM.provincia
--DROP TABLE DREAM_TEAM.codigo_postal_localidad
--DROP TABLE DREAM_TEAM.item_compra
--DROP TABLE DREAM_TEAM.item_venta
--DROP TABLE DREAM_TEAM.canal_de_venta
--DROP TABLE DREAM_TEAM.entrega
--DROP TABLE DREAM_TEAM.proveedor
--DROP TABLE DREAM_TEAM.compra
--DROP TABLE DREAM_TEAM.venta
--DROP TABLE DREAM_TEAM.descuento_compra
--DROP TABLE DREAM_TEAM.medio_pago_compra
--DROP TABLE DREAM_TEAM.medio_pago_venta
--DROP TABLE DREAM_TEAM.descuento_venta
--DROP TABLE DREAM_TEAM.descuento_cupon_venta
--DROP TABLE DREAM_TEAM.localidad
--DROP TABLE DREAM_TEAM.cliente
--DROP TABLE DREAM_TEAM.tipo_descuento
--DROP TABLE DREAM_TEAM.cupon

--DROP PROCEDURE DREAM_TEAM.migrar_tipo_variante
--DROP PROCEDURE DREAM_TEAM.migrar_marca
--DROP PROCEDURE DREAM_TEAM.migrar_categoria
--DROP PROCEDURE DREAM_TEAM.migrar_material
--DROP PROCEDURE DREAM_TEAM.migrar_medio_de_envios
--DROP PROCEDURE DREAM_TEAM.migrar_provincia
--DROP PROCEDURE DREAM_TEAM.migrar_codigo_postal_localidad
--DROP PROCEDURE DREAM_TEAM.migrar_canal_de_venta
--DROP PROCEDURE DREAM_TEAM.migrar_cupon
--DROP PROCEDURE DREAM_TEAM.migrar_tipo_descuento
--DROP PROCEDURE DREAM_TEAM.migrar_medio_pago_venta
--DROP PROCEDURE DREAM_TEAM.migrar_medio_pago_compra
--DROP PROCEDURE DREAM_TEAM.migrar_localidad
--DROP PROCEDURE DREAM_TEAM.migrar_producto
--DROP PROCEDURE DREAM_TEAM.migrar_variante
--DROP PROCEDURE DREAM_TEAM.migrar_producto_variante
--DROP PROCEDURE DREAM_TEAM.migrar_proveedor
--DROP PROCEDURE DREAM_TEAM.migrar_cliente
--DROP PROCEDURE DREAM_TEAM.migrar_compra
--DROP PROCEDURE DREAM_TEAM.migrar_venta
--DROP PROCEDURE DREAM_TEAM.migrar_entrega
--DROP PROCEDURE DREAM_TEAM.migrar_item_compra
--DROP PROCEDURE DREAM_TEAM.migrar_item_venta
--DROP PROCEDURE DREAM_TEAM.migrar_descuento_venta
--DROP PROCEDURE DREAM_TEAM.migrar_descuento_cupon_venta
--DROP PROCEDURE DREAM_TEAM.migrar_descuento_compra
--DROP PROCEDURE DREAM_TEAM.migrar_medio_de_envios_cp
--DROP PROCEDURE DREAM_TEAM.insert_stock_producto_variante
--DROP PROCEDURE DREAM_TEAM.insert_precio_unitario_producto_variante

--SELECTS DE PRUEBA
--SELECT * FROM DREAM_TEAM.cliente
--SELECT * FROM DREAM_TEAM.tipo_variante
--SELECT * FROM DREAM_TEAM.variante
--SELECT * FROM DREAM_TEAM.marca
--SELECT * FROM DREAM_TEAM.categoria
--SELECT * FROM DREAM_TEAM.material
--SELECT * FROM DREAM_TEAM.producto
--SELECT * FROM DREAM_TEAM.producto_variante
--SELECT * FROM DREAM_TEAM.medio_de_envios
--SELECT * FROM DREAM_TEAM.provincia
--SELECT * FROM DREAM_TEAM.entrega
--SELECT * FROM DREAM_TEAM.canal_de_venta
--SELECT * FROM DREAM_TEAM.item_venta
--SELECT * FROM DREAM_TEAM.item_compra
--SELECT * FROM DREAM_TEAM.venta
--SELECT * FROM DREAM_TEAM.compra
--SELECT * FROM DREAM_TEAM.proveedor
--SELECT * FROM DREAM_TEAM.descuento_cupon_venta
--SELECT * FROM DREAM_TEAM.descuento_venta
--SELECT * FROM DREAM_TEAM.medio_pago_venta
--SELECT * FROM DREAM_TEAM.medio_pago_compra
--SELECT * FROM DREAM_TEAM.descuento_compra
--SELECT * FROM DREAM_TEAM.cliente
--SELECT * FROM DREAM_TEAM.tipo_descuento
--SELECT * FROM DREAM_TEAM.cupon
--SELECT * FROM DREAM_TEAM.codigo_postal_localidad
--SELECT * FROM DREAM_TEAM.medio_de_envios_cp
