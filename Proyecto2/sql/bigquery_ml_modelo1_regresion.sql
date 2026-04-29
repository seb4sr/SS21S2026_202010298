-- MODELO 1: REGRESIÓN LINEAL - Predecir tarifa (fare_amount)
-- ============================================================================
-- Objetivo: Entrenar un modelo de regresión para predecir la tarifa de un viaje
--           en función de variables como distancia, hora, zona, número de pasajeros.
-- Técnica: LINEAR_REG (Regresión Lineal)
-- Variable objetivo: fare_amount
-- Data split: 80% entrenamiento, 20% evaluación
-- ============================================================================

CREATE OR REPLACE MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`
OPTIONS(
  model_type='linear_reg',
  input_label_cols=['fare_amount'],
  data_split_method='auto',
  data_split_eval_fraction=0.2,
  l1_reg=0.1,          -- Regularización L1 (Lasso) para evitar overfitting
  l2_reg=0.1,          -- Regularización L2 (Ridge) para penalizar coeficientes grandes
  max_iterations=100   -- Número máximo de iteraciones de entrenamiento
) AS
SELECT
  fare_amount,
  trip_distance,
  passenger_count,
  hora_recogida,
  dia_semana,
  mes,
  CASE 
    WHEN periodo_dia = 'manana' THEN 1
    WHEN periodo_dia = 'tarde' THEN 2
    WHEN periodo_dia = 'noche' THEN 3
    ELSE 0  -- madrugada
  END AS periodo_dia_encoded,
  payment_type,
  duracion_minutos,
  porcentaje_propina
FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
WHERE fare_amount IS NOT NULL
  AND trip_distance > 0
  AND passenger_count > 0
-- Límite opcional para acelerar entrenamiento en dev (remover en producción)
-- LIMIT 100000
;

-- Verificar que el modelo fue creado exitosamente
SELECT 
  'Modelo de Regresión' AS tipo_modelo,
  'fare_amount' AS variable_objetivo,
  'linear_reg' AS algoritmo,
  CURRENT_TIMESTAMP() AS timestamp_creacion
;
