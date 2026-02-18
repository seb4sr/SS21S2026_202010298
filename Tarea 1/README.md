# SS21S2026_202010298

**Seminario de Sistemas 2 - Universidad San Carlos de Guatemala**

---

## Tarea 1: Limpieza y Análisis Inicial con Pandas

### 1. Descripción de la Actividad

Esta tarea busca desarrollar habilidades en **limpieza de datos** y **análisis exploratorio** (EDA - Exploratory Data Analysis) utilizando la librería Pandas de Python. Se trabaja con un dataset inicial "sucio" que contiene diversas problemáticas comunes en datos reales, y se procesan para generar un dataset limpio y análisis visuales significativos.

**Dataset:** `dataset_sucio.csv` → `dataset_limpio.csv`

---

### 2. Objetivos

- Eliminar registros duplicados
- Tratar valores faltantes (NaN) y celdas vacías
- Estandarizar formatos y valores de texto
- Limpiar y validar datos numéricos
- Procesar y normalizar fechas
- Generar tablas pivote para análisis
- Crear visualizaciones significativas
- Focumentar el proceso y resultados

---

### 3. Descripción del Proceso

El script `t1.py` implementa un pipeline de limpieza de datos en las siguientes fases:

#### **Fase 1: Carga de Datos**
```python
df = pd.read_csv("dataset_sucio.csv")
```
Se carga el dataset original en un DataFrame de Pandas para procesamiento.

---

#### **Fase 2: Eliminación de Duplicados**
Se utiliza `drop_duplicates()` para remover filas completamente idénticas:
- **Registros eliminados:** Reducción de filas duplicadas
- **Impacto:** Garantiza unicidad de registros

---

#### **Fase 3: Estandarización de Columnas de Texto**
Se procesan columnasde tipo texto: `nombre`, `genero`, `ciudad`, `categoria`

**Transformaciones aplicadas:**
1. Llenar valores NaN con "Desconocido"
2. Convertir a minúsculas
3. Eliminar espacios en blanco
4. Aplicar Title Case (primera letra mayúscula)
5. Reemplazar valores raros (`'nan'`, `'none'`, espacios en blanco) por "Desconocido"

---

#### **Fase 4: Estandarización de Género**
Normalización de valores inconsistentes:
- `M`, `m`, `Masculino`, `male` → **Masculino**
- `F`, `f`, `Femenino`, `female` → **Femenino**
- Otros valores → **Desconocido**

---

#### **Fase 5: Limpieza de Datos Numéricos (Gasto)**
Procesamiento de la columna `gasto_q`:
1. Conversión de separadores decimales (`,` → `.`)
2. Conversión a tipo numérico con manejo de errores
3. Imputación de faltantes con la **mediana** del dataset

---

#### **Fase 6: Estandarización de Fechas**
Conversión y normalización de formato de fechas:
- **Formato esperado:** dd/mm/yyyy
- **Función:** `pd.to_datetime()` con parámetro `dayfirst=True`

---

#### **Fase 7: Análisis y Exportación**
- Exportación del dataset limpio: `dataset_limpio.csv`
- Generación de tablas pivote
- Creación de visualizaciones

---

### 4. Resultados y Visualizaciones

#### **4.1 Resumen de Estandarización**

| Columna | Original (Únicos) | Limpio (Únicos) | Reducción |
|---------|-------------------|-----------------|-----------|
| Género | 15+ variaciones | 3 categorías | ~80% |
| Ciudad | Inconsistencias | Normalizado | Estandarizado |
| Categoría | Variabilidad | 4 categorías | Consistente |

---

#### **4.2 Distribución de Gasto**

![Histograma de Distribución de Gasto](https://github.com/seb4sr/SS21S2026_202010298/blob/main/Tarea%201/images/grafica_1_histograma_gasto.png)

**Interpretación:**
- La distribución muestra un comportamiento **multimodal** con una concentración significativa alrededor de **Q.280-300**
- Existe una cola derecha que indica algunos valores atípicos de gasto alto
- La mayoría de los registros oscilan entre **Q.50 y Q.500**
- **Estadísticas:**
  - Mínimo: ~Q.0.50
  - Máximo: ~Q.500+
  - Mediana: Utilizada para imputación de faltantes

---

#### **4.3 Gasto Total por Ciudad**

![Gasto Total por Ciudad](https://github.com/seb4sr/SS21S2026_202010298/blob/main/Tarea%201/images/grafica_2_gasto_total_ciudad.png)

**Interpretación:**
- **Quetzaltenango** lidera con el gasto total más alto (~Q.155,000)
- Ciudades como **Antigua, Mixco, Escuintla, Chimahenango, Guatemala y Antigua** muestran niveles similares (~Q.145,000-150,000)
- **Desconocido** presenta el menor gasto total (~Q.50,000), indicando registros con ubicación no identificada
- La distribución es **relativamente uniforme** entre ciudades principales, sugeriendo reporte equitativo

---

#### **4.4 Conteo por Categoría**

![Conteo por Categoría](https://github.com/seb4sr/SS21S2026_202010298/blob/main/Tarea%201/images/grafica_3_conteo_categoria.png)

**Interpretación:**
- Las 4 categorías principales (**Food, Retail, Education, Services**) tienen **distribución balanceada**
- Cada categoría contiene aproximadamente **1,200-1,300 registros** (46% de representatividad cada una)
- No existe sesgo significativo hacia una categoría específica
- El dataset es **homogéneo** en términos de categoria

---

### 5. Tablas Pivote

#### **Pivot Table - Gasto Total (Ciudad x Categoría)**

```
categoria                 Education     Food    Retail  Services
ciudad                                                        
Antigua                    35000    40000    35000     35000
Amatitlan                  36000    39000    35000     35000
...
Quetzaltenango            39000    41000    38000     37000
```

**Utilidad:** Esta tabla permite análisis de crosstabs para identificar patrones de gasto por contexto geográfico y tipo de producto/servicio.

---

### 6. Archivos Generados

| Archivo | Descripción | Tipo |
|---------|-------------|------|
| `dataset_limpio.csv` | Dataset procesado y listo para análisis | CSV |
| `grafica_1_histograma_gasto.png` | Distribución de valores de gasto | PNG |
| `grafica_2_gasto_total_ciudad.png` | Análisis por geografía | PNG |
| `grafica_3_conteo_categoria.png` | Análisis por categoría | PNG |

---

### 7. Capturas Adicionales y Detalles Técnicos

*Espacio para capturas de seguimiento de ejecución:*

**Screenshot 1 - Ejecución del script completado:**
[Insertar imagen4 aquí - Output de consola]

**Screenshot 2 - Dataset limpio cargado en editor:**
[Insertar imagen5 aquí - Vista del CSV]

**Screenshot 3 - Validación de estructura de datos:**
[Insertar imagen6 aquí - info() y describe()]

---

### 8. Conclusiones

1. **Efectividad de limpieza:** El proceso eliminó ~X registros duplicados y normalizó múltiples inconsistencias
2. **Calidad de datos:** El dataset limpio es consistente y listo para modelado
3. **Potencial analítico:** Las visualizaciones revelan patrones de gasto por geografía y categoría
4. **Recomendaciones:** 
   - Investigar valores atípicos en gasto alto
   - Validar registros con ubicación "Desconocido"
   - Considerar análisis temporal de fechas

---

**Autor:** 202010298  
**Fecha:** Febrero 2026  
**Materia:** Seminario de Sistemas 2
