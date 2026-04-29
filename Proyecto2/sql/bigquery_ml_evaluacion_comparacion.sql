-- EVALUACIÓN Y COMPARACIÓN DE MODELOS
-- ============================================================================
-- Este script extrae las métricas de evaluación de ambos modelos y crea una
-- tabla de comparación para justificar la selección final.
-- ============================================================================

-- 1. EVALUACIÓN DEL MODELO DE REGRESIÓN
-- ============================================================================
-- Obtener métricas del modelo de regresión: RMSE, MAE, R-squared
SELECT
  'RESUMEN: MODELO REGRESIÓN (fare_amount)' AS seccion,
  '' AS metrica,
  '' AS valor
UNION ALL
SELECT 
  'Modelo de Regresión',
  'RMSE (Error Cuadrático Medio)',
  CAST(ROUND(SQRT(MEAN_SQUARED_ERROR), 4) AS STRING) AS valor
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`
  )
UNION ALL
SELECT
  'Modelo de Regresión',
  'MAE (Error Absoluto Medio)',
  CAST(ROUND(MEAN_ABSOLUTE_ERROR, 4) AS STRING)
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`
  )
UNION ALL
SELECT
  'Modelo de Regresión',
  'R-Squared',
  CAST(ROUND(R2_SCORE, 4) AS STRING)
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`
  )

-- 2. EVALUACIÓN DEL MODELO DE CLASIFICACIÓN
-- ============================================================================
-- Obtener métricas del modelo de clasificación: ROC-AUC, Precisión, Recall, F1
UNION ALL
SELECT
  'RESUMEN: MODELO CLASIFICACIÓN (payment_type)' AS seccion,
  '' AS metrica,
  '' AS valor
UNION ALL
SELECT
  'Modelo de Clasificación',
  'ROC-AUC',
  CAST(ROUND(ROUNDING(roc_auc), 4) AS STRING)
FROM (
  SELECT
    roc_auc
  FROM
    ML.EVALUATE(
      MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
    )
)
UNION ALL
SELECT
  'Modelo de Clasificación',
  'Accuracy (Precisión Global)',
  CAST(ROUND(accuracy, 4) AS STRING)
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
  )
UNION ALL
SELECT
  'Modelo de Clasificación',
  'Precision (Clase Positiva)',
  CAST(ROUND(precision, 4) AS STRING)
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
  )
UNION ALL
SELECT
  'Modelo de Clasificación',
  'Recall (Sensibilidad)',
  CAST(ROUND(recall, 4) AS STRING)
FROM
  ML.EVALUATE(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
  )

-- 3. MATRIZ DE CONFUSIÓN DEL MODELO DE CLASIFICACIÓN
-- ============================================================================
UNION ALL
SELECT
  'MATRIZ DE CONFUSIÓN: Clasificación' AS seccion,
  '' AS metrica,
  '' AS valor
UNION ALL
SELECT
  'Clasificación',
  'Verdaderos Positivos (TP)',
  CAST(CAST(SUM(CASE WHEN predicted_metodo_pago_binario = 1 
                       AND metodo_pago_binario = 1 THEN 1 ELSE 0 END) AS INT64) AS STRING)
FROM (
  SELECT
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS metodo_pago_binario,
    CASE WHEN predicted_metodo_pago_binario = 1 THEN 1 ELSE 0 END AS predicted_metodo_pago_binario
  FROM
    ML.PREDICT(
      MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`,
      (
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
        WHERE payment_type IN (1, 2) AND fare_amount > 0
        LIMIT 10000
      )
    )
)
UNION ALL
SELECT
  'Clasificación',
  'Falsos Positivos (FP)',
  CAST(CAST(SUM(CASE WHEN predicted_metodo_pago_binario = 1 
                       AND metodo_pago_binario = 0 THEN 1 ELSE 0 END) AS INT64) AS STRING)
FROM (
  SELECT
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS metodo_pago_binario,
    CASE WHEN predicted_metodo_pago_binario = 1 THEN 1 ELSE 0 END AS predicted_metodo_pago_binario
  FROM
    ML.PREDICT(
      MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`,
      (
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
        WHERE payment_type IN (1, 2) AND fare_amount > 0
        LIMIT 10000
      )
    )
)
UNION ALL
SELECT
  'Clasificación',
  'Verdaderos Negativos (TN)',
  CAST(CAST(SUM(CASE WHEN predicted_metodo_pago_binario = 0 
                       AND metodo_pago_binario = 0 THEN 1 ELSE 0 END) AS INT64) AS STRING)
FROM (
  SELECT
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS metodo_pago_binario,
    CASE WHEN predicted_metodo_pago_binario = 1 THEN 1 ELSE 0 END AS predicted_metodo_pago_binario
  FROM
    ML.PREDICT(
      MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`,
      (
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
        WHERE payment_type IN (1, 2) AND fare_amount > 0
        LIMIT 10000
      )
    )
)
UNION ALL
SELECT
  'Clasificación',
  'Falsos Negativos (FN)',
  CAST(CAST(SUM(CASE WHEN predicted_metodo_pago_binario = 0 
                       AND metodo_pago_binario = 1 THEN 1 ELSE 0 END) AS INT64) AS STRING)
FROM (
  SELECT
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS metodo_pago_binario,
    CASE WHEN predicted_metodo_pago_binario = 1 THEN 1 ELSE 0 END AS predicted_metodo_pago_binario
  FROM
    ML.PREDICT(
      MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`,
      (
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
        WHERE payment_type IN (1, 2) AND fare_amount > 0
        LIMIT 10000
      )
    )
)
ORDER BY seccion, metrica;
