-- Tabla derivada con datos limpios y variables útiles
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios` AS
SELECT
  pickup_datetime,
  dropoff_datetime,
  passenger_count,
  trip_distance,
  pickup_location_id,
  dropoff_location_id,
  payment_type,
  fare_amount,
  tip_amount,
  total_amount,

  -- Variables derivadas (ingeniería de características)
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) AS duracion_minutos,
  EXTRACT(HOUR FROM pickup_datetime)                              AS hora_recogida,
  EXTRACT(DAYOFWEEK FROM pickup_datetime)                        AS dia_semana,
  EXTRACT(MONTH FROM pickup_datetime)                            AS mes,
  CASE
    WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 6 AND 11  THEN 'manana'
    WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 12 AND 17 THEN 'tarde'
    WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 18 AND 22 THEN 'noche'
    ELSE 'madrugada'
  END AS periodo_dia,
  ROUND(tip_amount / NULLIF(fare_amount, 0) * 100, 2)                AS porcentaje_propina

FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  fare_amount BETWEEN 1 AND 500
  AND trip_distance BETWEEN 0.1 AND 100
  AND passenger_count BETWEEN 1 AND 6
  AND pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) BETWEEN 1 AND 180;