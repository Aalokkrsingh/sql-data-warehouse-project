/*
===============================================================================
Gold Layer - Test & Build Script
===============================================================================
Script Purpose:
    This script contains ad-hoc checks and view-building logic used while
    developing the Gold Layer. It covers:
    - Referential integrity between fact and dimension tables.
    - Data integration logic for conflicting source columns (gender).
    - Duplicate checks after joining Silver tables (grain validation).
    - The gold.dim_products view definition.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Foreign Key Integrity (Dimension)
-- Expectation: No results (every fact row should find a matching customer)
SELECT
    *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL;


-- ====================================================================
-- Checking 'silver.crm_cust_info' vs 'silver.erp_cust_az12'
-- ====================================================================
-- Data Integration Check - Gender
-- Purpose: Resolve conflicting gender values between CRM and ERP sources.
-- Rule: CRM is the master for gender info; fall back to ERP, then 'n/a'.
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- CRM is the master for gender info
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gen_2
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- ====================================================================
-- Checking Grain of Joined Customer Data
-- ====================================================================
-- Purpose: Confirm the CRM + ERP customer join does not fan out
--          (i.e. each cst_id should still appear only once).
-- Expectation: No results
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ca.bdate,
        la.cntry,
        ci.cst_create_date
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
        ON ci.cst_key = la.cid
) AS t
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- ====================================================================
-- Building 'gold.dim_products'
-- ====================================================================
-- Notes:
--   - Change the names of the columns for better understanding.
--   - Surrogate keys: system-generated unique identifiers assigned to
--     each record in a table (don't always depend on the source system).
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id                                                AS product_id,
    pn.prd_key                                                AS product_number,
    pn.prd_nm                                                 AS product_name,
    pn.cat_id                                                 AS category_id,
    pc.cat                                                    AS category,
    pc.subcat                                                 AS subcategory,
    pc.maintenance,
    pn.prd_cost                                               AS cost,
    pn.prd_line                                               AS product_line,
    pn.prd_start_dt                                           AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;  -- Filter out all historical data


/*
===============================================================================
TODO - Fact Table Build Notes
===============================================================================
    1. No need to perform Data Integration, since only one table (CRM)
       feeds the Fact table.
    2. Surrogate keys from the dimension tables must be added inside
       the Fact table.
    3. Sort columns into logical groups to improve readability
       (Dimension keys, Dates, Measures).
===============================================================================
*/
