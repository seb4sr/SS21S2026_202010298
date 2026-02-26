-- 1. Crear la base de datos
CREATE DATABASE Vuelos_Practica1;
GO

USE Vuelos_Practica1;
GO

-- ==========================================
-- 2. CREACIÓN DE TABLAS DE DIMENSIONES (Se mantienen igual)
-- ==========================================
CREATE TABLE Dim_Tiempo (
    id_tiempo INT PRIMARY KEY IDENTITY(1,1),
    fecha DATE NOT NULL,
    anio INT, mes INT, nombre_mes VARCHAR(20), dia INT, trimestre INT
);
GO

CREATE TABLE Dim_Pasajero (
    id_pasajero INT PRIMARY KEY IDENTITY(1,1),
    codigo_pasajero VARCHAR(100) NOT NULL,
    genero VARCHAR(20),
    nacionalidad VARCHAR(50),
    edad INT
);
GO

CREATE TABLE Dim_Aeropuerto (
    id_aeropuerto INT PRIMARY KEY IDENTITY(1,1),
    codigo_iata VARCHAR(10) NOT NULL,
    nombre_aeropuerto VARCHAR(150),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);
GO

CREATE TABLE Dim_Aerolinea (
    id_aerolinea INT PRIMARY KEY IDENTITY(1,1),
    codigo_aerolinea VARCHAR(20),
    nombre_aerolinea VARCHAR(100)
);
GO

-- ==========================================
-- 3. TABLA DE HECHOS (¡Mejorada para tu dataset!)
-- ==========================================
CREATE TABLE Fact_Vuelos (
    id_hecho_vuelo INT PRIMARY KEY IDENTITY(1,1),
    
    -- Llaves foráneas
    id_tiempo INT NOT NULL,
    id_pasajero INT NOT NULL,
    id_origen INT NOT NULL,
    id_destino INT NOT NULL,
    id_aerolinea INT NOT NULL,
    
    -- Dimensiones Degeneradas (Detalles directos del vuelo)
    numero_vuelo VARCHAR(20),
    clase_cabina VARCHAR(50),
    canal_venta VARCHAR(50),
    metodo_pago VARCHAR(50),
    estado_vuelo VARCHAR(50),
    
    -- Métricas / Hechos Reales del CSV
    duracion_minutos FLOAT,
    retraso_minutos FLOAT,
    precio_boleto_usd FLOAT,
    total_maletas INT,
    maletas_documentadas INT,
    
    -- Métrica base para conteos
    cantidad_vuelos INT DEFAULT 1,
    
    -- Relaciones
    CONSTRAINT FK_Fact_Tiempo FOREIGN KEY (id_tiempo) REFERENCES Dim_Tiempo(id_tiempo),
    CONSTRAINT FK_Fact_Pasajero FOREIGN KEY (id_pasajero) REFERENCES Dim_Pasajero(id_pasajero),
    CONSTRAINT FK_Fact_Origen FOREIGN KEY (id_origen) REFERENCES Dim_Aeropuerto(id_aeropuerto),
    CONSTRAINT FK_Fact_Destino FOREIGN KEY (id_destino) REFERENCES Dim_Aeropuerto(id_aeropuerto),
    CONSTRAINT FK_Fact_Aerolinea FOREIGN KEY (id_aerolinea) REFERENCES Dim_Aerolinea(id_aerolinea)
);
GO

UPDATE Dim_Pasajero SET genero = 'Masculino' WHERE genero IN ('M', 'MASCULINO');
UPDATE Dim_Pasajero SET genero = 'Femenino' WHERE genero IN ('F', 'FEMENINO');