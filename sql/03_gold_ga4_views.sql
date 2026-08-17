-- ==========================================
-- 1. CONTEXT SETUP
-- ==========================================
USE DATABASE ANALYTICS_PROD;
USE SCHEMA GOOGLE_ANALYTICS;

-- ==========================================
-- 2. CREATE VIEWS
-- ==========================================

-- ------------------------------------------
-- 2.1 DEVICE_ENGAGEMENT VIEW
-- ------------------------------------------
CREATE OR REPLACE VIEW DEVICE_ENGAGEMENT 
COMMENT = 'A data breakdown showing how individual devices, systems, and browsers translate into traffic and user engagement'
AS 
SELECT 
    d.device_category, 
    d.operating_system, 
    d.browser, 
    COUNT(DISTINCT f.user_pseudo_id) AS unique_users, 
    COUNT(DISTINCT f.session_id) AS unique_sessions, 
    COUNT(f.event_id) AS total_events, 
    ROUND(AVG(f.engagement_time_msec) / 1000.0, 2) AS avg_engagement_seconds
FROM FACT_EVENTS f
INNER JOIN DIM_DEVICES d ON f.device_id = d.device_id
GROUP BY 
    d.device_category, 
    d.operating_system, 
    d.browser;

-- ------------------------------------------
-- 2.2 GEO_PERFORMANCE VIEW
-- ------------------------------------------
CREATE OR REPLACE VIEW GEO_PERFORMANCE 
COMMENT = 'Data source for maps and geographic summaries'
AS
SELECT 
    d.country, 
    d.city, 
    COUNT(DISTINCT f.user_pseudo_id) AS unique_users, 
    COUNT(DISTINCT f.session_id) AS unique_sessions, 
    COUNT(f.event_id) AS total_events
FROM FACT_EVENTS f
INNER JOIN DIM_DEVICES d ON f.device_id = d.device_id
GROUP BY 
    d.country, 
    d.city;

-- ------------------------------------------
-- 2.3 DAILY_EVENT_SUMMARY VIEW
-- ------------------------------------------
CREATE OR REPLACE VIEW DAILY_EVENT_SUMMARY 
COMMENT = 'Data summary for line charts showing the daily dynamics of individual actions'
AS
SELECT 
    f.event_date, 
    f.event_name, 
    COUNT(f.event_id) AS total_events, 
    COUNT(DISTINCT f.user_pseudo_id) AS unique_users
FROM FACT_EVENTS f
GROUP BY 
    f.event_date, 
    f.event_name;

-- ------------------------------------------
-- 2.4 OVERALL_KPI_SUMMARY VIEW
-- ------------------------------------------
CREATE OR REPLACE VIEW OVERALL_KPI_SUMMARY 
COMMENT = 'Overall KPI metrics for top-level dashboard summary cards'
AS
SELECT 
    COUNT(event_id) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    ROUND(AVG(engagement_time_msec) / 1000.0, 2) AS avg_engagement_seconds
FROM FACT_EVENTS;
