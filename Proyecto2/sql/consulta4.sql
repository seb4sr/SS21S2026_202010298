-- Patrones por día de la semana
SELECT
  FORMAT_DATE('%A', DATE(pickup_datetime)) AS dia_semana,
  COUNT(*) AS total_viajes,
  ROUND(AVG(fare_amount), 2) AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY dia_semana
ORDER BY total_viajes DESC;