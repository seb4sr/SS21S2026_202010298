USE Vuelos_Practica1;
GO

-- Ver todos los registros de la tabla de hechos para validar la carga

SELECT 'Dim_Aerolinea' AS Tabla, COUNT(*) AS Total_Registros FROM Dim_Aerolinea
UNION ALL
SELECT 'Dim_Aeropuerto', COUNT(*) FROM Dim_Aeropuerto
UNION ALL
SELECT 'Dim_Pasajero', COUNT(*) FROM Dim_Pasajero
UNION ALL
SELECT 'Dim_Tiempo', COUNT(*) FROM Dim_Tiempo
UNION ALL
SELECT 'Fact_Vuelos', COUNT(*) FROM Fact_Vuelos;
GO


-- Indicarores de rendimiento general proporcionados en el enunciado

SELECT 
    SUM(cantidad_vuelos) AS Numero_Total_Vuelos,
    SUM(maletas_documentadas) AS Total_Maletas_Documentadas,
    SUM(precio_boleto_usd) AS Ingresos_Totales_USD,
    AVG(retraso_minutos) AS Promedio_Retraso_Minutos
FROM 
    Fact_Vuelos;
GO

-- Destinos mas frecuentes


SELECT TOP 5
    A.codigo_iata AS Destino, 
    SUM(F.cantidad_vuelos) AS Total_Vuelos
FROM Fact_Vuelos F
JOIN Dim_Aeropuerto A ON F.id_destino = A.id_aeropuerto
GROUP BY A.codigo_iata
ORDER BY Total_Vuelos DESC;

-- Aerolineas mas utilizadas
SELECT TOP 5 
    AL.nombre_aerolinea AS Aerolinea, 
    SUM(F.cantidad_vuelos) AS Total_Vuelos
FROM Fact_Vuelos F
JOIN Dim_Aerolinea AL ON F.id_aerolinea = AL.id_aerolinea
GROUP BY AL.nombre_aerolinea
ORDER BY Total_Vuelos DESC;


-- Vuelos por aerolinea
SELECT 
    AL.nombre_aerolinea AS Aerolinea, 
    SUM(F.cantidad_vuelos) AS Total_Vuelos
FROM Fact_Vuelos F
JOIN Dim_Aerolinea AL ON F.id_aerolinea = AL.id_aerolinea
GROUP BY AL.nombre_aerolinea
ORDER BY Total_Vuelos DESC;
