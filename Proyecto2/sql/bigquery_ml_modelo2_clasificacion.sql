-- MODELO 2: CLASIFICACIÓN - Predecir método de pago (payment_type)
-- ============================================================================
-- Objetivo: Entrenar un modelo de clasificación para predecir si el pago es 
--           tarjeta (1) o efectivo (2) basado en características del viaje.
-- Técnica: LINEAR_CLASSIFICATION (Regresión Logística)
-- Variable objetivo: payment_type (reformulada como binaria: 1=tarjeta, 0=otro)
-- Data split: 80% entrenamiento, 20% evaluación
-- ============================================================================

CREATE OR REPLACE MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
OPTIONS(
  model_type='linear_classification',
  input_label_cols=['metodo_pago_binario'],
  data_split_method='auto',
  data_split_eval_fraction=0.2,
  class_weights=[('0', 1.0), ('1', 1.2)],  -- Peso ligeramente mayor para clase 1 (tarjeta)
  l1_reg=0.05,
  l2_reg=0.05,
  max_iterations=100
) AS
SELECT
  CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS metodo_pago_binario,
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
WHERE payment_type IN (1, 2)
  AND fare_amount > 0
  AND trip_distance > 0
-- Límite opcional para acelerar entrenamiento en dev (remover en producción)
-- LIMIT 100000
;

-- Verificar que el modelo fue creado exitosamente
SELECT 
  'Modelo de Clasificación' AS tipo_modelo,
  'payment_type (binario)' AS variable_objetivo,
  'linear_classification' AS algoritmo,
  '1=Tarjeta, 0=Efectivo' AS clase_codificacion,
  CURRENT_TIMESTAMP() AS timestamp_creacion
;
