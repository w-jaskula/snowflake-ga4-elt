-- ==========================================
-- 1. CONTEXT SETUP
-- ==========================================
CREATE DATABASE IF NOT EXISTS ANALYTICS_PROD;
CREATE SCHEMA IF NOT EXISTS GOOGLE_ANALYTICS;

USE DATABASE ANALYTICS_PROD;
USE SCHEMA GOOGLE_ANALYTICS;

-- ==========================================
-- 2. CREATE TABLES (DDL)
-- ==========================================

-- ------------------------------------------
-- 2.1 CREATE DIM_DEVICES
-- ------------------------------------------
CREATE OR REPLACE TABLE DIM_DEVICES (
    device_id VARCHAR (50) NOT NULL PRIMARY KEY,
    device_category VARCHAR(100),
    operating_system VARCHAR(50),
    browser VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100)
);

-- ------------------------------------------
-- 2.2 CREATE FACT_EVENTS
-- ------------------------------------------
CREATE OR REPLACE TABLE FACT_EVENTS (
    event_id VARCHAR(50) NOT NULL PRIMARY KEY,
    user_pseudo_id VARCHAR(100),
    device_id VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES DIM_DEVICES(device_id),
    event_date DATE,
    event_name VARCHAR(50),
    session_id VARCHAR(50),
    engagement_time_msec INT
); 
