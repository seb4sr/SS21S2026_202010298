# Instrucciones de Ejecución — Proyecto 2: BigQuery ML

**Fecha:** Abril 28, 2026  
**Proyecto GCP:** `corded-evening-493205-n7`  
**Dataset:** `proyecto2_taxi`

---

## Prerequisites

Antes de ejecutar los scripts:
1. Tener acceso a una cuenta de Google Cloud Platform (GCP) activa
2. Tener habilitada la API de BigQuery
3. Haber creado un proyecto GCP (o usar uno existente)
4. Contar con permisos para crear tablas y modelos en BigQuery

---

## Paso 0: Crear el Dataset

Ejecutar esta consulta una sola vez en BigQuery Console (ajustar `corded-evening-493205-n7` con tu proyecto real):

```sql
CREATE SCHEMA IF NOT EXISTS `corded-evening-493205-n7.proyecto2_taxi`
OPTIONS (location = 'US', description = 'Dataset para Proyecto 2 - Análisis NYC Taxi');
```

**Resultado esperado:** Mensaje "Query executed successfully" y el dataset aparece en la lista del panel izquierdo de BigQuery.

---

## Paso 1: Exploración Inicial del Dataset Público

**Archivo:** `sql/exploracion.sql`

```sql
-- Copiar y ejecutar en BigQuery Console:
SELECT
  COUNT(*) AS total_registros,
  MIN(pickup_datetime) AS fecha_inicio,
  MAX(pickup_datetime) AS fecha_fin
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

**¿Qué mira?**
- Total de registros en el dataset público (≈36 millones)
- Rango real de fechas (discovery de que hay datos desde 2001 hasta 2023)

**Captura de evidencia:** Copiar el resultado y adjuntar screenshot en carpeta `images/` como `01_exploracion_resultado.png`.

**Tiempo estimado:** < 10 segundos

---

## Paso 2: Consultas Analíticas sobre Dataset Público

Ejecutar en orden. Cada una tarda 30-60 segundos:

### 2.1 Métricas Descriptivas Generales

**Archivo:** `sql/consulta1.sql`

```sql
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
```

**Captura:** Screenshot de resultado como `02_consulta1_metricas.png`

---

### 2.2 Distribución por Método de Pago

**Archivo:** `sql/consulta2.sql`

```sql
SELECT
  payment_type,
  COUNT(*)                             AS cantidad_viajes,
  ROUND(AVG(fare_amount), 2)          AS tarifa_promedio,
  ROUND(AVG(tip_amount), 2)           AS propina_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
GROUP BY payment_type
ORDER BY cantidad_viajes DESC;
```

**Captura:** `03_consulta2_pago.png`

---

### 2.3 Patrones Temporales por Hora

**Archivo:** `sql/consulta3.sql`

```sql
SELECT
  EXTRACT(HOUR FROM pickup_datetime)  AS hora,
  COUNT(*)                                  AS total_viajes,
  ROUND(AVG(fare_amount), 2)               AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY hora
ORDER BY hora;
```

**Captura:** `04_consulta3_hora.png`

---

### 2.4 Patrones por Día de la Semana

**Archivo:** `sql/consulta4.sql`

```sql
SELECT
  FORMAT_DATE('%A', DATE(pickup_datetime)) AS dia_semana,
  COUNT(*)                                        AS total_viajes,
  ROUND(AVG(fare_amount), 2)                     AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY dia_semana
ORDER BY total_viajes DESC;
```

**Captura:** `05_consulta4_dia_semana.png`

---

### 2.5 Top 10 Zonas de Recogida

**Archivo:** `sql/consulta5.sql`

```sql
SELECT
  pickup_location_id                         AS zona_recogida,
  COUNT(*)                             AS total_viajes,
  ROUND(AVG(fare_amount), 2)          AS tarifa_promedio,
  ROUND(AVG(trip_distance), 2)        AS distancia_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE fare_amount > 0
  AND trip_distance > 0
GROUP BY zona_recogida
ORDER BY total_viajes DESC
LIMIT 10;
```

**Captura:** `06_consulta5_zonas.png`

---

## Paso 3: Crear Tabla Derivada con Ingeniería de Características

**Archivo:** `sql/tabla_derivada.sql`

```sql
-- ADVERTENCIA: Esta consulta procesa 3.39 GB y tarda ~3-5 minutos
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
```

**¿Qué ocurre?**
- Se crea la tabla `viajes_limpios` con datos limpios y variables derivadas
- Tarda 3-5 minutos (procesa 3.39 GB)
- Resultado: tabla con millones de viajes ya procesados

**Captura:** Un screenshot mostrando en BigQuery Console el mensaje "Table created successfully" y el nombre de la tabla en la lista. Guardar como `07_tabla_derivada_creada.png`.

**Verificación:**
```sql
-- Ejecutar para verificar:
SELECT COUNT(*) as total_registros FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`;
```

Resultado esperado: ≈30-35 millones de registros (después de filtros de calidad).

---

## Paso 4: Crear Tabla Optimizada (Particiones + Clustering)

**Archivo:** `sql/optimizacion.sql`

```sql
-- Crear tabla con particiones por fecha y clustering por zonas
CREATE OR REPLACE TABLE `corded-evening-493205-n7.proyecto2_taxi.viajes_optimizados`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id
AS
SELECT * FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`;
```

**¿Qué ocurre?**
- Se crea `viajes_optimizados` como copia de `viajes_limpios` pero con particionado y clustering
- Tarda 1-2 minutos (solo reorganiza datos existentes, no procesa desde el dataset público)

**Captura:** Screenshot como `08_tabla_optimizada_creada.png`.

---

## Paso 5: Comparar Rendimiento (Sin vs Con Optimización)

Ejecutar las mismas consultas sobre ambas tablas para comparar bytes procesados.

### 5.1 Consulta sobre `viajes_limpios` (SIN optimización)

```sql
SELECT
  AVG(fare_amount) as tarifa_promedio,
  AVG(tip_amount) as propina_promedio,
  COUNT(*) as total
FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-01' AND '2022-03-31';
```

**Captura:** Screenshot mostrando bytes procesados. Buscar en BigQuery Console:
- Abrir "Execution Details" 
- Ver "Bytes processed" (debería ser ≈1000 MB o más)
- Guardar como `09_comparacion_sin_optimizacion_bytes.png`

### 5.2 Misma consulta sobre `viajes_optimizados` (CON optimización)

```sql
SELECT
  AVG(fare_amount) as tarifa_promedio,
  AVG(tip_amount) as propina_promedio,
  COUNT(*) as total
FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_optimizados`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-01' AND '2022-03-31';
```

**Captura:** Screenshot de bytes procesados. Debería ser 0 B (por caché) o muy bajo. Guardar como `10_comparacion_con_optimizacion_bytes.png`.

---

## Paso 6: Entrenar Modelo 1 — Regresión Lineal (Predecir Tarifa)

**Archivo:** `sql/bigquery_ml_modelo1_regresion.sql`

```sql
-- ADVERTENCIA: Tarda 5-10 minutos en crear y entrenar el modelo
CREATE OR REPLACE MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`
OPTIONS(
  model_type='linear_reg',
  input_label_cols=['fare_amount'],
  data_split_method='auto',
  data_split_eval_fraction=0.2,
  l1_reg=0.1,
  l2_reg=0.1,
  max_iterations=100
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
    ELSE 0
  END AS periodo_dia_encoded,
  payment_type,
  duracion_minutos,
  porcentaje_propina
FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
WHERE fare_amount IS NOT NULL
  AND trip_distance > 0
  AND passenger_count > 0
LIMIT 500000;  -- Limitar para entrenamiento rápido (remover en producción)
```

**¿Qué ocurre?**
- BigQuery ML entrena automáticamente un modelo de regresión lineal
- Divide datos en 80% entrenamiento, 20% evaluación
- Aplica regularización L1+L2 para evitar overfitting

**Captura:** Screenshot diciendo "Model created successfully" como `11_modelo_regresion_creado.png`.

**Verificación:**
```sql
SELECT * FROM `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`;
```

---

## Paso 7: Entrenar Modelo 2 — Clasificación (Predecir Método de Pago)

**Archivo:** `sql/bigquery_ml_modelo2_clasificacion.sql`

```sql
-- ADVERTENCIA: Tarda 5-10 minutos
CREATE OR REPLACE MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`
OPTIONS(
  model_type='linear_classification',
  input_label_cols=['metodo_pago_binario'],
  data_split_method='auto',
  data_split_eval_fraction=0.2,
  class_weights=[('0', 1.0), ('1', 1.2)],
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
LIMIT 500000;  -- Limitar para entrenamiento rápido
```

**Captura:** `12_modelo_clasificacion_creado.png`.

---

## Paso 8: Evaluar Ambos Modelos

**Archivo:** `sql/bigquery_ml_evaluacion_comparacion.sql`

### 8.1 Evaluar Regresión

```sql
-- Métricas del modelo de regresión
SELECT 
  'RMSE' AS metrica,
  CAST(ROUND(SQRT(mean_squared_error), 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`)
UNION ALL
SELECT 
  'MAE' AS metrica,
  CAST(ROUND(mean_absolute_error, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`)
UNION ALL
SELECT 
  'R2_SCORE' AS metrica,
  CAST(ROUND(r2_score, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`);
```

**Resultado esperado:**
```
RMSE:      ≈5.20
MAE:       ≈3.80
R2_SCORE:  ≈0.65
```

**Captura:** `13_evaluacion_regresion_metricas.png`.

### 8.2 Evaluar Clasificación

```sql
-- Métricas del modelo de clasificación
SELECT 
  'ROC_AUC' AS metrica,
  CAST(ROUND(roc_auc, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`)
UNION ALL
SELECT 
  'ACCURACY' AS metrica,
  CAST(ROUND(accuracy, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`)
UNION ALL
SELECT 
  'PRECISION' AS metrica,
  CAST(ROUND(precision, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`)
UNION ALL
SELECT 
  'RECALL' AS metrica,
  CAST(ROUND(recall, 4) AS STRING) AS valor
FROM ML.EVALUATE(MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_clasificacion_pago`);
```

**Resultado esperado:**
```
ROC_AUC:   ≈0.82
ACCURACY:  ≈0.80
PRECISION: ≈0.85
RECALL:    ≈0.70
```

**Captura:** `14_evaluacion_clasificacion_metricas.png`.

---

## Paso 9: Hacer Predicciones sobre Nuevos Datos

**Archivo:** `sql/bigquery_ml_predicciones.sql`

### 9.1 Predicciones de Tarifa

```sql
-- Predecir tarifa para una muestra de 100 viajes
SELECT
  viaje_id,
  trip_distance,
  passenger_count,
  tarifa_predicha_usd,
  ROUND(tarifa_predicha_usd, 2) AS tarifa_predicha
FROM (
  SELECT
    CAST(ROW_NUMBER() OVER (ORDER BY RAND()) AS STRING) AS viaje_id,
    trip_distance,
    passenger_count,
    predicted_fare_amount AS tarifa_predicha_usd
  FROM ML.PREDICT(
    MODEL `corded-evening-493205-n7.proyecto2_taxi.modelo_regresion_tarifa`,
    (
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
          ELSE 0
        END AS periodo_dia_encoded,
        payment_type,
        duracion_minutos,
        porcentaje_propina
      FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_limpios`
      WHERE fare_amount > 0 LIMIT 100
    )
  )
)
LIMIT 10;
```

**Captura:** `15_predicciones_tarifa_muestra.png`.

### 9.2 Predicciones de Método de Pago

```sql
-- Predecir método de pago para una muestra de 100 viajes
SELECT
  viaje_id,
  trip_distance,
  metodo_pago_predicho,
  ROUND(probabilidad_tarjeta, 2) AS prob_tarjeta_pct,
  confianza
FROM (
  SELECT
    CAST(ROW_NUMBER() OVER (ORDER BY RAND()) AS STRING) AS viaje_id,
    trip_distance,
    CASE 
      WHEN predicted_metodo_pago_binario = 1 THEN 'Tarjeta'
      ELSE 'Efectivo'
    END AS metodo_pago_predicho,
    predicted_metodo_pago_binario_probs[OFFSET(1)].prob * 100 AS probabilidad_tarjeta,
    CASE 
      WHEN predicted_metodo_pago_binario_probs[OFFSET(1)].prob >= 0.7 THEN 'Alta'
      WHEN predicted_metodo_pago_binario_probs[OFFSET(1)].prob >= 0.5 THEN 'Media'
      ELSE 'Baja'
    END AS confianza
  FROM ML.PREDICT(
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
      WHERE payment_type IN (1, 2) AND fare_amount > 0 LIMIT 100
    )
  )
)
LIMIT 10;
```

**Captura:** `16_predicciones_metodo_pago_muestra.png`.

---

## Paso 10: Crear Vistas para el Dashboard (Looker Studio)

Para que Looker Studio pueda conectarse y visualizar datos, crear vistas públicas o tabla exportada:

### 10.1 Vista de Resultados Exploratorios

```sql
CREATE OR REPLACE VIEW `corded-evening-493205-n7.proyecto2_taxi.vista_exploracion` AS
SELECT
  'Métricas Generales' as tipo,
  CAST(COUNT(*) AS STRING) as cantidad,
  ROUND(AVG(fare_amount), 2) as tarifa_promedio,
  EXTRACT(HOUR FROM pickup_datetime) as hora,
  FORMAT_DATE('%A', DATE(pickup_datetime)) as dia_semana
FROM `corded-evening-493205-n7.proyecto2_taxi.viajes_optimizados`
GROUP BY hora, dia_semana, DATE(pickup_datetime);
```

Esta vista sirve como fuente de datos para gráficos en Looker Studio (horas, días, tarifas).

---

## Checklist de Entregables

Una vez completados todos los pasos, verifica que tengan:

- [ ] Carpeta `sql/` con 12 archivos `.sql`
- [ ] Carpeta `images/` con ≥15 screenshots
- [ ] `Readme.md` completo con sección de BigQuery ML
- [ ] Archivo `INSTRUCCIONES_EJECUCION.md` (este archivo)
- [ ] Enlace a dashboard de Looker Studio en el README
- [ ] Archivo `.gitignore` (opcional, para excluir archivos grandes)

---

## Tiempo Total de Ejecución

```
Paso 0 (Dataset):           < 1 min
Paso 1-2 (Exploración):     5 min
Paso 3 (Tabla derivada):    5 min
Paso 4 (Optimizada):        2 min
Paso 5 (Comparación):       2 min
Paso 6 (Modelo regresión):  10 min
Paso 7 (Modelo clasif):     10 min
Paso 8 (Evaluación):        5 min
Paso 9 (Predicciones):      5 min
Paso 10 (Vistas):           2 min
─────────────────────────────────
TOTAL:                     ~47 min
```

---

## Troubleshooting

### Problema: "Dataset not found"
**Solución:** Asegurate que el proyecto ID en los scripts sea correcto: `corded-evening-493205-n7`. Si usas otro proyecto, reemplaza ese ID en todos los scripts.

### Problema: "Table not found: viajes_limpios"
**Solución:** Ejecuta el Paso 3 (tabla_derivada.sql) antes del Paso 4 (optimizacion.sql). Las tablas tienen dependencias.

### Problema: El modelo tarda mucho
**Solución:** Los scripts incluyen `LIMIT 500000` en el entrenamiento. Puedes aumentarlo a `LIMIT 1000000` o remover el LIMIT en producción, pero tardará más.

### Problema: Bytes procesados son muy altos
**Solución:** Es normal en pasos 1-3 (lecturas del dataset público). El particionado y clustering (Paso 4+) reducen bytes drásticamente.

---

## Notas Finales

- Todos los scripts usan el proyecto `corded-evening-493205-n7`. **Si usas otro proyecto, cambia ese ID en todos lados.**
- Las capturas de pantalla son para **evidencia de entrega**. Guárdalas en `images/`.
- El tiempo total es ≈45 minutos. Se puede ejecutar en segundo plano sin bloquear.
- Después de todo, crear un dashboard básico en Looker Studio y adjuntar el enlace en el README.

¡Listo! Ejecuta los pasos en orden y captura evidencias en cada hito.
