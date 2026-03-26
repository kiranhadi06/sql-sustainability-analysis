-- =========================================================
-- Intel Sustainability Impact Analysis
-- Author: Kiran Hadi
-- Description:
-- SQL queries used to analyze Intel's 2024 repurposing program,
-- including device age, energy savings, CO2 reduction, device type,
-- age buckets, and regional sustainability impact.
-- =========================================================


-- =========================================================
-- 1. Join device and impact data
-- Purpose: Combine both datasets into one result using device_id
-- =========================================================
SELECT *
FROM intel.device_data AS a
LEFT JOIN intel.impact_data AS b
    ON a.device_id = b.device_id;


-- =========================================================
-- 2. Add calculated device_age column
-- Purpose: Show how old each repurposed device is in 2024
-- =========================================================
SELECT
    a.*,
    b.*,
    (2024 - a.model_year) AS device_age
FROM intel.device_data AS a
LEFT JOIN intel.impact_data AS b
    ON a.device_id = b.device_id;


-- =========================================================
-- 3. Average recycling rate by device age
-- Purpose: Explore whether newer or older devices are being
-- repurposed more often
-- =========================================================
SELECT
    (2024 - a.model_year) AS device_age,
    ROUND(AVG(b.recycling_rate), 3) AS avg_recycling_rate
FROM intel.device_data AS a
LEFT JOIN intel.impact_data AS b
    ON a.device_id = b.device_id
GROUP BY (2024 - a.model_year)
ORDER BY device_age DESC;


-- =========================================================
-- 4. Add device_age_bucket using CASE
-- Purpose: Categorize devices as newer, mid-age, or older
-- =========================================================
SELECT
    a.device_id,
    a.model_year,
    (2024 - a.model_year) AS device_age,
    CASE
        WHEN 2024 - a.model_year <= 3 THEN 'newer'
        WHEN 2024 - a.model_year > 3
             AND 2024 - a.model_year <= 6 THEN 'mid-age'
        ELSE 'older'
    END AS device_age_bucket,
    b.recycling_rate
FROM intel.device_data AS a
LEFT JOIN intel.impact_data AS b
    ON a.device_id = b.device_id
ORDER BY device_age DESC;


-- =========================================================
-- 5. Total number of repurposed devices
-- Purpose: Count all devices included in the 2024 dataset
-- =========================================================
WITH task1 AS (
    SELECT
        a.device_id,
        (2024 - a.model_year) AS device_age,
        b.energy_savings_yr,
        b.co2_saved_kg_yr
    FROM intel.device_data AS a
    LEFT JOIN intel.impact_data AS b
        ON a.device_id = b.device_id
)
SELECT COUNT(DISTINCT device_id) AS total_repurposed_devices
FROM task1;


-- =========================================================
-- 6. Overall sustainability metrics
-- Purpose: Return total devices, average age, average energy savings,
-- and total CO2 savings in tons
-- =========================================================
WITH task1 AS (
    SELECT
        a.device_id,
        (2024 - a.model_year) AS device_age,
        b.energy_savings_yr,
        b.co2_saved_kg_yr
    FROM intel.device_data AS a
    LEFT JOIN intel.impact_data AS b
        ON a.device_id = b.device_id
)
SELECT
    COUNT(DISTINCT device_id) AS total_repurposed_devices,
    ROUND(AVG(device_age), 3) AS avg_device_age,
    ROUND(AVG(energy_savings_yr), 3) AS avg_energy_savings_kwh,
    ROUND(SUM(co2_saved_kg_yr) / 1000.0, 3) AS total_co2_saved_tons
FROM task1;


-- =========================================================
-- 7. Sustainability metrics by device type
-- Purpose: Compare laptops and desktops
-- =========================================================
WITH task1 AS (
    SELECT
        a.device_type,
        a.device_id,
        b.energy_savings_yr,
        b.co2_saved_kg_yr
    FROM intel.device_data AS a
    LEFT JOIN intel.impact_data AS b
        ON a.device_id = b.device_id
)
SELECT
    device_type,
    COUNT(DISTINCT device_id) AS total_devices,
    ROUND(AVG(energy_savings_yr), 4) AS avg_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000.0, 4) AS avg_co2_saved_tons
FROM task1
GROUP BY device_type;


-- =========================================================
-- 8. Sustainability metrics by device age bucket
-- Purpose: Compare the environmental benefit across newer, mid-age,
-- and older devices
-- =========================================================
WITH task1 AS (
    SELECT
        a.device_id,
        b.energy_savings_yr,
        b.co2_saved_kg_yr,
        CASE
            WHEN 2024 - a.model_year <= 3 THEN 'newer'
            WHEN 2024 - a.model_year > 3
                 AND 2024 - a.model_year <= 6 THEN 'mid-age'
            ELSE 'older'
        END AS device_age_bucket
    FROM intel.device_data AS a
    LEFT JOIN intel.impact_data AS b
        ON a.device_id = b.device_id
)
SELECT
    device_age_bucket,
    COUNT(DISTINCT device_id) AS total_devices,
    ROUND(AVG(energy_savings_yr), 4) AS avg_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000.0, 4) AS avg_co2_saved_tons
FROM task1
GROUP BY device_age_bucket
ORDER BY avg_energy_savings_kwh DESC, avg_co2_saved_tons DESC;


-- =========================================================
-- 9. Sustainability metrics by region
-- Purpose: Compare the energy savings and CO2 reductions across regions
-- =========================================================
WITH task1 AS (
    SELECT
        a.device_id,
        b.energy_savings_yr,
        b.co2_saved_kg_yr,
        b.region
    FROM intel.device_data AS a
    LEFT JOIN intel.impact_data AS b
        ON a.device_id = b.device_id
)
SELECT
    region,
    COUNT(DISTINCT device_id) AS total_devices,
    ROUND(AVG(energy_savings_yr), 4) AS avg_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000.0, 4) AS avg_co2_saved_tons
FROM task1
GROUP BY region
ORDER BY avg_energy_savings_kwh DESC, avg_co2_saved_tons DESC;