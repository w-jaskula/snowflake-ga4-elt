-- ==========================================
-- 1. CONTEXT SETUP
-- ==========================================
USE DATABASE ANALYTICS_PROD;
USE SCHEMA GOOGLE_ANALYTICS;

-- ==========================================
-- 2. POPULATE TABLES (DML)
-- ==========================================

-- ------------------------------------------
-- 2.1 POPULATE DIM_DEVICES
-- ------------------------------------------
INSERT INTO DIM_DEVICES (device_id, device_category, operating_system, browser, country, city)
SELECT DISTINCT
    MD5(CONCAT_WS('_', 
        device_category, 
        device_operating_system, 
        device_web_info_browser, 
        geo_country, 
        CASE WHEN LOWER(geo_city) LIKE '%not set%' THEN 'Unknown' ELSE geo_city END
    )) AS device_id,
    device_category,
    device_operating_system,
    device_web_info_browser,
    geo_country,
    CASE
        WHEN LOWER(geo_city) LIKE '%not set%' THEN 'Unknown'
        ELSE geo_city
    END
    AS geo_city
FROM GA4_RAW_EVENTS
WHERE device_category IS NOT NULL;

-- ------------------------------------------
-- 2.2 POPULATE FACT_EVENTS
-- ------------------------------------------
INSERT INTO FACT_EVENTS (event_id, user_pseudo_id, device_id, event_date, event_name, session_id, engagement_time_msec)
SELECT DISTINCT
    MD5(CONCAT_WS('_', event_timestamp, user_pseudo_id, event_name)) AS event_id,
    user_pseudo_id,
    MD5(CONCAT_WS('_', 
        device_category, 
        device_operating_system, 
        device_web_info_browser, 
        geo_country, 
        CASE WHEN LOWER(geo_city) LIKE '%not set%' THEN 'Unknown' ELSE geo_city END
    )) AS device_id,
    TO_DATE(CAST(event_date AS VARCHAR), 'YYYYMMDD') AS event_date,
    event_name,
    CASE
        WHEN event_params_key = 'ga_session_id' THEN CAST(event_params_value_int_value AS VARCHAR)
        ELSE NULL  
    END
    AS session_id,
    CASE
        WHEN event_params_key = 'engagement_time_msec' THEN event_params_value_int_value
        ELSE NULL
    END
    AS engagement_time_msec
FROM GA4_RAW_EVENTS
WHERE event_name IS NOT NULL;
