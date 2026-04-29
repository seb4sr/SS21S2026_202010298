-- PREDICCIONES SOBRE NUEVOS DATOS
-- ============================================================================
-- Este script demuestra cómo usar ambos modelos para hacer predicciones
-- sobre nuevos registros de viajes. Se crean escenarios hipotéticos y se
-- generan predicciones de tarifa y método de pago.
-- ============================================================================

-- 1. PREDICCIONES DEL MODELO DE REGRESIÓN (tarifa esperada)
-- ============================================================================
-- Crear tabla con datos nuevos hipotéticos y predecir tarifa
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.predicciones_tarifa` AS
SELECT
  viaje_id,
  trip_distance,
  passenger_count,
  hora_recogida,
  dia_semana,
  mes,
  periodo_dia_encoded,
  payment_type,
  duracion_minutos,
  porcentaje_propina,
  predicted_fare_amount,
  ROUND(predicted_fare_amount, 2) AS tarifa_predicha_usd
FROM
  ML.PREDICT(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`,
    (
      -- Datos nuevos: muestra de 1000 viajes recientes del dataset
      SELECT
        CAST(ROW_NUMBER() OVER (ORDER BY RAND()) AS STRING) AS viaje_id,
        trip_distance,
        passenger_count,
        hora_recogida,
        dia_semana,
        mes,
        CASE 
          WHEN periodo_dia = 'manana' THEN 1
          WHEN periodo_dia = 'tarde' THEN 2
          WHEN periodo_dia = 'noche' THEN 3
          ELSE 0
        END AS periodo_dia_encoded,
        payment_type,
        duracion_minutos,
        porcentaje_propina
      FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
      WHERE fare_amount > 0
      LIMIT 1000
    )
  );

-- 2. PREDICCIONES DEL MODELO DE CLASIFICACIÓN (método de pago)
-- ============================================================================
-- Predecir método de pago para los mismos viajes
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.predicciones_metodo_pago` AS
SELECT
  viaje_id,
  trip_distance,
  passenger_count,
  hora_recogida,
  dia_semana,
  mes,
  periodo_dia_encoded,
  fare_amount,
  duracion_minutos,
  porcentaje_propina,
  tip_amount,
  predicted_metodo_pago_binario,
  CASE 
    WHEN predicted_metodo_pago_binario = 1 THEN 'Tarjeta de Crédito'
    ELSE 'Efectivo'
  END AS metodo_pago_predicho,
  ROUND(predicted_metodo_pago_binario_probs[OFFSET(0)].prob * 100, 2) AS probabilidad_negativo,
  ROUND(predicted_metodo_pago_binario_probs[OFFSET(1)].prob * 100, 2) AS probabilidad_tarjeta
FROM
  ML.PREDICT(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`,
    (
      -- Datos nuevos: muestra de 1000 viajes recientes del dataset
      SELECT
        CAST(ROW_NUMBER() OVER (ORDER BY RAND()) AS STRING) AS viaje_id,
        trip_distance,
        passenger_count,
        hora_recogida,
        dia_semana,
        mes,
        CASE 
          WHEN periodo_dia = 'manana' THEN 1
          WHEN periodo_dia = 'tarde' THEN 2
          WHEN periodo_dia = 'noche' THEN 3
          ELSE 0
        END AS periodo_dia_encoded,
        fare_amount,
        duracion_minutos,
        porcentaje_propina,
        tip_amount
      FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
      WHERE payment_type IN (1, 2) AND fare_amount > 0
      LIMIT 1000
    )
  );

-- 3. TABLA CONSOLIDADA: PREDICCIONES DE AMBOS MODELOS
-- ============================================================================
-- Combinar predicciones de tarifa y método de pago en una sola vista
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.predicciones_consolidadas` AS
SELECT
  t.viaje_id,
  t.trip_distance,
  t.passenger_count,
  t.hora_recogida,
  t.dia_semana,
  t.mes,
  t.tarifa_predicha_usd AS tarifa_predicha,
  p.metodo_pago_predicho,
  p.probabilidad_tarjeta AS confianza_metodo_pago_pct,
  CASE 
    WHEN p.probabilidad_tarjeta >= 70 THEN 'Alta'
    WHEN p.probabilidad_tarjeta >= 50 THEN 'Media'
    ELSE 'Baja'
  END AS confianza_prediccion
FROM `corded-evening-493205-n7.proyecto2_taxi.predicciones_tarifa` t
JOIN `corded-evening-493205-n7.proyecto2_taxi.predicciones_metodo_pago` p
  ON t.viaje_id = p.viaje_id;

-- 4. RESUMEN ESTADÍSTICO DE PREDICCIONES
-- ============================================================================
-- Realizar un resumen de las predicciones realizadas
SELECT
  'RESUMEN DE PREDICCIONES GENERADAS' AS seccion,
  COUNT(*) AS cantidad_predicciones_totales,
  ROUND(AVG(tarifa_predicha), 2) AS tarifa_promedio_predicha,
  ROUND(MIN(tarifa_predicha), 2) AS tarifa_minima_predicha,
  ROUND(MAX(tarifa_predicha), 2) AS tarifa_maxima_predicha,
  COUNTIF(metodo_pago_predicho = 'Tarjeta de Crédito') AS predicciones_tarjeta,
  COUNTIF(metodo_pago_predicho = 'Efectivo') AS predicciones_efectivo,
  ROUND(COUNTIF(confianza_prediccion = 'Alta') / COUNT(*) * 100, 2) AS pct_alta_confianza
FROM `corded-evening-493205-n7.proyecto2_taxi.predicciones_consolidadas`;

-- 5. MUESTRA DE PREDICCIONES (primeros 20 registros)
-- ============================================================================
SELECT
  'MUESTRA: Primeras 20 predicciones consolidadas' AS titulo
UNION ALL
SELECT
  CAST(ROW_NUMBER() OVER () AS STRING) AS titulo
FROM `corded-evening-493205-n7.proyecto2_taxi.predicciones_consolidadas`
LIMIT 20;

-- Mostrar las primeras 20 predicciones
SELECT
  viaje_id,
  trip_distance,
  passenger_count,
  tarifa_predicha,
  metodo_pago_predicho,
  confianza_prediccion
FROM `corded-evening-493205-n7.proyecto2_taxi.predicciones_consolidadas`
LIMIT 20;
