import streamlit as st
import os

def get_connection():
    conn = st.connection("snowflake", ttl=os.getenv("SNOWFLAKE_CONNECTION_TTL"))
    return conn.session()

def load_data(session):
    df_device = session.sql("SELECT * FROM ANALYTICS_PROD.GOOGLE_ANALYTICS.DEVICE_ENGAGEMENT").to_pandas()
    df_geo = session.sql("SELECT * FROM ANALYTICS_PROD.GOOGLE_ANALYTICS.GEO_PERFORMANCE").to_pandas()
    df_daily = session.sql("SELECT * FROM ANALYTICS_PROD.GOOGLE_ANALYTICS.DAILY_EVENT_SUMMARY").to_pandas()
    df_kpis = session.sql("SELECT * FROM ANALYTICS_PROD.GOOGLE_ANALYTICS.OVERALL_KPI_SUMMARY").to_pandas()
    return {"device": df_device, "geo": df_geo, "daily": df_daily, "kpis": df_kpis}