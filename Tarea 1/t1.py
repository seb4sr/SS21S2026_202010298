import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# TAREA #1 - Limpieza y análisis inicial con Pandas
# Universidad San Carlos de Guatemala - Seminario de Sistemas 2
# Requerimientos:
# - Eliminación de duplicados
# - Tratamiento de celdas vacías
# - Estandarización de valores y formatos
# - Tablas tipo pivote (antes y después)
# - Visualizaciones (gráficas)
# ============================================================
# Archivo de entrada (dataset original sucio):
# dataset_sucio.csv
# ============================================================

print("1. Cargando datos...")

# ====== Cargar dataset original ======
df_orig = pd.read_csv("dataset_sucio.csv")
df = df_orig.copy()

print(f"Dataset cargado: {df.shape[0]} filas, {df.shape[1]} columnas")


# ============================================================
# 2. ELIMINACIÓN DE DUPLICADOS
# ============================================================
print("\n2. Eliminando duplicados...")

df.drop_duplicates(inplace=True)

print(f"Dataset después de eliminar duplicados: {df.shape[0]} filas")


# ============================================================
# 3. TRATAMIENTO DE VALORES FALTANTES + ESTANDARIZACIÓN STRINGS
# ============================================================
print("\n3. Tratando valores faltantes y estandarizando strings...")

# Columnas tipo texto (según el notebook)
string_cols = ['nombre', 'genero', 'ciudad', 'categoria']

for col in string_cols:
    # 1) Llenar NaN
    df[col] = df[col].fillna("Desconocido")

    # 2) Convertir a string, limpiar espacios y poner Title Case
    df[col] = df[col].astype(str).str.strip().str.title()

    # 3) Reemplazar valores raros por "Desconocido"
    df.loc[df[col].isin(['Nan', 'None', '', ' ']), col] = "Desconocido"

print("String columns estandarizadas.")


# ============================================================
# 4. ESTANDARIZACIÓN DE GÉNERO
# ============================================================
print("\n4. Estandarizando género...")

df['genero'] = df['genero'].apply(
    lambda x: "Masculino" if str(x).upper().startswith("M")
    else ("Femenino" if str(x).upper().startswith("F") else "Desconocido")
)

print(f"Géneros únicos: {df['genero'].unique()}")


# ============================================================
# 5. LIMPIEZA DE GASTO (NUMÉRICO)
# ============================================================
print("\n5. Limpiando gasto (valores numéricos)...")

# Convertir separador decimal (coma a punto)
df['gasto_q'] = df['gasto_q'].astype(str).replace(',', '.', regex=False)

# Convertir a numérico
df['gasto_q'] = pd.to_numeric(df['gasto_q'], errors='coerce')

# Imputar faltantes con la mediana
df['gasto_q'] = df['gasto_q'].fillna(df['gasto_q'].median())

print(f"Gasto procesado - Min: {df['gasto_q'].min()}, Max: {df['gasto_q'].max()}")


# ============================================================
# 6. ESTANDARIZACIÓN DE FECHAS
# ============================================================
print("\n6. Estandarizando fechas...")

df['fecha_registro'] = pd.to_datetime(
    df['fecha_registro'],
    dayfirst=True,
    errors='coerce'
)

print(f"Fechas procesadas - Rango: {df['fecha_registro'].min()} a {df['fecha_registro'].max()}")


# ============================================================
# 7. EXPORTACIÓN DEL DATASET LIMPIO + TABLAS PIVOTE
# ============================================================
print("\n7. Exportando dataset limpio y realizando análisis...")

df.to_csv("dataset_limpio.csv", index=False)
print("Dataset limpio exportado a 'dataset_limpio.csv'")


# ====== Resumen de estandarización (como en el notebook) ======
resumen_limpieza = pd.DataFrame({
    'Columna': ['genero', 'ciudad', 'categoria'],
    'Original (Únicos)': [
        df_orig['genero'].nunique(),
        df_orig['ciudad'].nunique(),
        df_orig['categoria'].nunique()
    ],
    'Limpio (Únicos)': [
        df['genero'].nunique(),
        df['ciudad'].nunique(),
        df['categoria'].nunique()
    ]
})

print("\nResumen de Estandarización:")
print(resumen_limpieza)


# ====== Pivot Table (Gasto total por ciudad y categoría) ======
pivot_final = df.pivot_table(
    index='ciudad',
    columns='categoria',
    values='gasto_q',
    aggfunc='sum',
    fill_value=0
)

print("\nPivot Table (Gasto Total):")
print(pivot_final)


# ============================================================
# 8. GRÁFICAS CON PANDAS/MATPLOTLIB (igual al notebook)
# ============================================================

print("\n8. Generando gráficas...")

# --------- 1) Histograma de gasto ----------
plt.figure(figsize=(8, 4))
df['gasto_q'].plot(kind='hist', bins=20, edgecolor='black')
plt.title("Distribución de gasto")
plt.xlabel("Gasto (Q)")
plt.ylabel("Frecuencia")
plt.tight_layout()
plt.savefig("grafica_1_histograma_gasto.png", dpi=300)
plt.show()


# --------- 2) Gasto total por ciudad ----------
plt.figure(figsize=(10, 4))
df.groupby('ciudad')['gasto_q'].sum().sort_values(ascending=False).plot(kind='bar')
plt.title("Gasto total por ciudad")
plt.xlabel("Ciudad")
plt.ylabel("Gasto total (Q)")
plt.tight_layout()
plt.savefig("grafica_2_gasto_total_ciudad.png", dpi=300)
plt.show()


# --------- 3) Conteo por categoría ----------
plt.figure(figsize=(8, 4))
df['categoria'].value_counts().plot(kind='bar')
plt.title("Conteo por categoría")
plt.xlabel("Categoría")
plt.ylabel("Cantidad")
plt.tight_layout()
plt.savefig("grafica_3_conteo_categoria.png", dpi=300)
plt.show()


print("\n✅ Proceso finalizado.")
print("Archivos generados:")
print("- dataset_limpio.csv")
print("- grafica_1_histograma_gasto.png")
print("- grafica_2_gasto_total_ciudad.png")
print("- grafica_3_conteo_categoria.png")
