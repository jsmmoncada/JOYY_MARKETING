CREATE DATABASE marketing;

USE marketing;

CREATE TABLE clientes (
id_cliente CHAR(10) PRIMARY KEY,
nombre VARCHAR(50),
apellido VARCHAR(50),
industria VARCHAR(50),
escolaridad VARCHAR(50),
estado_civil VARCHAR(50),
correo VARCHAR(100),
telefono VARCHAR(20),
direccion VARCHAR(200)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM Clientes;

UPDATE Clientes
SET telefono = REPLACE(telefono, '.', '-');
									
CREATE TABLE Campanas (
id_campana CHAR(10) PRIMARY KEY,
id_cliente CHAR(10), FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
nombre VARCHAR(50),
fecha_inicio DATE,
fecha_fin DATE,
estado_campaña TINYINT,
objetivo VARCHAR(100),
descripcion VARCHAR(100),
presupuesto_usd FLOAT(10),
publico_objetivo VARCHAR(200)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM Campanas;

CREATE TABLE Empleados(
	id_empleado CHAR(5) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    cargo VARCHAR(50),
    rol_profesional VARCHAR(50),
    fecha_ingreso DATE,
    activo TINYINT
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM Empleados;



CREATE TABLE metricas (
    id_metricas CHAR(10) PRIMARY KEY,
    id_campana CHAR(10),  FOREIGN KEY (id_campana) REFERENCES Campanas(id_campana),
    numero_conversion INT,
    alcance INT,
    tasa_conversion_porcentaje FLOAT,
    clics INT,
    ingreso FLOAT,
    roi FLOAT,
    fecha_reporte DATE
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM metricas;


CREATE TABLE Servicios(
	id_Servicio CHAR(10) PRIMARY KEY,
    Tipo_Servicio VARCHAR(100),
    Nombre_Servicio VARCHAR(100),
    Descripcion VARCHAR(200),
    Tarifa_USD FLOAT
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM Servicios;

CREATE TABLE DT_campanas_servicios (
	id_servicio CHAR(10) NOT NULL,
    id_campana CHAR(10) NOT NULL,
    PRIMARY KEY (id_campana, id_servicio),
    FOREIGN KEY (id_campana) REFERENCES Campanas(id_campana),
    FOREIGN KEY (id_servicio) REFERENCES Servicios(id_servicio)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;



SELECT * FROM DT_campanas_servicios;

CREATE TABLE DT_campanas_empleados (
    id_campana CHAR(10) NOT NULL,
    id_empleado CHAR(10) NOT NULL,
    PRIMARY KEY (id_campana, id_empleado),
    FOREIGN KEY (id_campana) REFERENCES Campanas(id_campana),
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM DT_campanas_empleados;



CREATE TABLE Plataformas(
	id_plataforma CHAR(10) PRIMARY KEY,
    Nombre VARCHAR(50),
    Engagement_promedio_porcentaje DECIMAL (6,3),
    Demografico VARCHAR(50)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;


SELECT * FROM Plataformas;

CREATE TABLE Aliados(
	id_aliado CHAR(10) PRIMARY KEY, 
    id_plataforma CHAR(10), FOREIGN KEY(id_plataforma) REFERENCES plataformas(id_plataforma),
    Nombre VARCHAR(50),
    Seguidores INT,
    Tipo VARCHAR(50),
    Correo VARCHAR(50),
    Usuario CHAR(50),
    Activo TINYINT
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;



SELECT * FROM Aliados;

CREATE TABLE DT_campanas_plataformas (
    id_campana CHAR(10) NOT NULL,
    id_plataforma CHAR(10) NOT NULL,
    PRIMARY KEY (id_campana, id_plataforma),
    FOREIGN KEY (id_campana) REFERENCES Campanas(id_campana),
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas (id_plataforma)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM DT_campanas_plataformas;

CREATE TABLE DT_campanas_aliados (
    id_campana CHAR(10) NOT NULL,
    id_aliado CHAR(10) NOT NULL,
    PRIMARY KEY (id_campana, id_aliado),
    FOREIGN KEY (id_campana) REFERENCES Campanas(id_campana),
    FOREIGN KEY (id_aliado) REFERENCES Aliados(id_aliado)
)
CHARACTER SET = latin1 
COLLATE = latin1_swedish_ci;

SELECT * FROM DT_campanas_aliados;











