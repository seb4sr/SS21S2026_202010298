-- Validación del volumen total del dataset
SELECT
  COUNT(*) AS total_registros,
  MIN(pickup_datetime) AS fecha_inicio,
  MAX(pickup_datetime) AS fecha_fin
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;