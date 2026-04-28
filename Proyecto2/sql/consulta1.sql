-- Métricas descriptivas generales
SELECT
  ROUND(AVG(trip_distance), 2)        AS distancia_promedio_millas,
  ROUND(AVG(fare_amount), 2)          AS tarifa_promedio,
  ROUND(AVG(tip_amount), 2)           AS propina_promedio,
  ROUND(AVG(passenger_count), 2)      AS pasajeros_promedio,
  ROUND(MAX(fare_amount), 2)          AS tarifa_maxima,
  ROUND(MIN(fare_amount), 2)          AS tarifa_minima
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
  AND passenger_count > 0;