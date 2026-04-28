-- Patrones temporales: viajes por hora del día
SELECT
  EXTRACT(HOUR FROM tpep_pickup_datetime)  AS hora,
  COUNT(*)                                  AS total_viajes,
  ROUND(AVG(fare_amount), 2)               AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY hora
ORDER BY hora;