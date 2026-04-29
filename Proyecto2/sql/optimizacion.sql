-- Tabla OPTIMIZADA con partición por fecha y clustering por zonas
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.viajes_optimizados`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id
AS
SELECT * FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`;