-- Validación del volumen total del dataset
SELECT
  COUNT(*) AS total_registros,
  MIN(tpep_pickup_datetime) AS fecha_inicio,
  MAX(tpep_pickup_datetime) AS fecha_fin
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;