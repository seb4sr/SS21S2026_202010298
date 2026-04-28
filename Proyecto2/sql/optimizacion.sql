-- Tabla OPTIMIZADA con partición por fecha y clustering por zonas
CREATE OR REPLACE TABLE `TU_PROYECTO.proyecto2_taxi.viajes_optimizados`
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY PULocationID, DOLocationID
AS
SELECT * FROM `TU_PROYECTO.proyecto2_taxi.viajes_limpios`;