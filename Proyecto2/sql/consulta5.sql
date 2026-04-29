-- Top 10 zonas de recogida más frecuentes
SELECT
  pickup_location_id AS zona_recogida,
  COUNT(*) AS total_viajes,
  ROUND(AVG(fare_amount), 2) AS tarifa_promedio,
  ROUND(AVG(trip_distance), 2) AS distancia_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY zona_recogida
ORDER BY total_viajes DESC
LIMIT 10;