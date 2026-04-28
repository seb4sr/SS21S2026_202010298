-- Distribución por método de pago
SELECT
  payment_type,
  COUNT(*)                             AS cantidad_viajes,
  ROUND(AVG(fare_amount), 2)          AS tarifa_promedio,
  ROUND(AVG(tip_amount), 2)           AS propina_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
GROUP BY payment_type
ORDER BY cantidad_viajes DESC;