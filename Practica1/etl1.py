import pandas as pd
import numpy as np
from datetime import datetime
from sqlalchemy import create_engine
import urllib.parse

#conexion base de datos
server_name = r"localhost\SQLEXPRESS"     # <-- TU instancia local
db_name = "Vuelos_Practica1"                   # o "PracticaETL" si así la creaste
driver_name = "ODBC Driver 17 for SQL Server"

# Parámetros extra para evitar error de certificado
params = urllib.parse.quote_plus(
    f"DRIVER={{{driver_name}}};"
    f"SERVER={server_name};"
    f"DATABASE={db_name};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

with engine.connect() as conn:
    conn.exec_driver_sql("SELECT 1;")
print("✅ Conexión OK a SQL Server")


#etapa 1: Carga de datos/extraccion
print("1. Cargando datos desde CSV")
df_vuelos = pd.read_csv('dataset_vuelos_crudo.csv')



# Limpieza básica
df_vuelos = df_vuelos.dropna(subset=['passenger_id', 'departure_datetime', 'origin_airport', 'destination_airport'])

# todo mayusucula y sin espacios
columnas_texto = ['airline_code', 'origin_airport', 'destination_airport', 'status', 'cabin_class', 'sales_channel', 'payment_method']
for col in columnas_texto:
    if col in df_vuelos.columns:
        df_vuelos[col] = df_vuelos[col].astype(str).str.strip().str.upper()

# Manejo de fechas
df_vuelos['departure_datetime'] = pd.to_datetime(df_vuelos['departure_datetime'], format='mixed', dayfirst=True)
df_vuelos['fecha_dt'] = df_vuelos['departure_datetime'].dt.date

#carga a las tablas de dimensiones
print("3. insertando datos en tablas de dimensiones")

# Dim_Aerolinea
df_dim_aerolinea = df_vuelos[['airline_code', 'airline_name']].drop_duplicates()
df_dim_aerolinea.columns = ['codigo_aerolinea', 'nombre_aerolinea']
df_dim_aerolinea.to_sql('Dim_Aerolinea', con=engine, if_exists='append', index=False)

# Dim_Pasajero
df_dim_pasajero = df_vuelos[['passenger_id', 'passenger_gender', 'passenger_nationality', 'passenger_age']].drop_duplicates()
df_dim_pasajero.columns = ['codigo_pasajero', 'genero', 'nacionalidad', 'edad']
df_dim_pasajero.to_sql('Dim_Pasajero', con=engine, if_exists='append', index=False)

# Dim_Aeropuerto (Solo códigos IATA disponibles en el CSV)
codes = pd.concat([df_vuelos['origin_airport'], df_vuelos['destination_airport']]).unique()
df_dim_aeropuerto = pd.DataFrame({'codigo_iata': codes})
df_dim_aeropuerto.to_sql('Dim_Aeropuerto', con=engine, if_exists='append', index=False)

# Dim_Tiempo
fechas_unicas = pd.to_datetime(df_vuelos['fecha_dt'].unique())
df_dim_tiempo = pd.DataFrame({
    'fecha': fechas_unicas,
    'anio': fechas_unicas.year,
    'mes': fechas_unicas.month,
    'nombre_mes': fechas_unicas.month_name(),
    'dia': fechas_unicas.day,
    'trimestre': fechas_unicas.quarter
})
df_dim_tiempo.to_sql('Dim_Tiempo', con=engine, if_exists='append', index=False)

#etapa 2: Construcción y carga de la tabla de hechos
print("4. Construyendo y cargando Fact_Vuelos")


db_aerolineas = pd.read_sql("SELECT id_aerolinea, codigo_aerolinea FROM Dim_Aerolinea", con=engine)
db_pasajeros = pd.read_sql("SELECT id_pasajero, codigo_pasajero FROM Dim_Pasajero", con=engine)
db_aeropuertos = pd.read_sql("SELECT id_aeropuerto, codigo_iata FROM Dim_Aeropuerto", con=engine)
db_tiempo = pd.read_sql("SELECT id_tiempo, fecha FROM Dim_Tiempo", con=engine)
db_tiempo['fecha'] = pd.to_datetime(db_tiempo['fecha']).dt.date

# Unir (Merge) para obtener las llaves foráneas
df_fact = df_vuelos.copy()
df_fact = df_fact.merge(db_aerolineas, left_on='airline_code', right_on='codigo_aerolinea', how='left')
df_fact = df_fact.merge(db_pasajeros, left_on='passenger_id', right_on='codigo_pasajero', how='left')
df_fact = df_fact.merge(db_tiempo, left_on='fecha_dt', right_on='fecha', how='left')
df_fact = df_fact.merge(db_aeropuertos, left_on='origin_airport', right_on='codigo_iata', how='left').rename(columns={'id_aeropuerto': 'id_origen'})
df_fact = df_fact.merge(db_aeropuertos, left_on='destination_airport', right_on='codigo_iata', how='left').rename(columns={'id_aeropuerto': 'id_destino'})

# Selección y renombramiento de TODAS las columnas necesarias para Fact_Vuelos
df_fact_final = df_fact[[
    'id_tiempo', 'id_pasajero', 'id_origen', 'id_destino', 'id_aerolinea',
    'flight_number', 'cabin_class', 'sales_channel', 'payment_method', 'status',
    'duration_min', 'delay_min', 'ticket_price_usd_est', 'bags_total', 'bags_checked'
]].copy()

df_fact_final.columns = [
    'id_tiempo', 'id_pasajero', 'id_origen', 'id_destino', 'id_aerolinea',
    'numero_vuelo', 'clase_cabina', 'canal_venta', 'metodo_pago', 'estado_vuelo',
    'duracion_minutos', 'retraso_minutos', 'precio_boleto_usd', 'total_maletas', 'maletas_documentadas'
]

df_fact_final['cantidad_vuelos'] = 1

# Carga final
df_fact_final.to_sql('Fact_Vuelos', con=engine, if_exists='append', index=False)

print("ETL completado exitosamente. Datos cargados en SQL Server.")