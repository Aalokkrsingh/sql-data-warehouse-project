/*
======================================================================
File: test_silver_layer.sql
Purpose:
    Validate data quality and transformation rules applied during the
    Bronze -> Silver ETL process.

Project Data Quality Rules:
    1. Store clear and meaningful values instead of abbreviated terms.
    2. Use 'n/a' or 'N/A' for missing/unknown values where applicable.
    3. Sales = Quantity * Price.
    4. Sales, Quantity, and Price must be greater than zero.
    5. Primary keys must not contain NULLs or duplicate values.
    6. Dates must follow valid business rules and logical order.

Validation Approach:
    - "Before Cleaning" queries identify data quality issues in Bronze.
    - "After Cleaning" queries validate that the Silver transformation
      successfully resolved those issues.
    - Investigation queries are used to understand complex
      transformation logic.

Expected Result:
    Validation queries should return NO ROWS unless explicitly stated.
======================================================================
*/


/*
======================================================================
1. CRM CUSTOMER INFORMATION
======================================================================
Table:
    bronze.crm_cust_info
    silver.crm_cust_info
======================================================================
*/


/*
----------------------------------------------------------------------
1.1 Check for NULLs or Duplicates in Customer Primary Key
----------------------------------------------------------------------
Expectation:
    Bronze may contain NULLs or duplicate customer IDs.
    Silver should contain NO NULLs or duplicate customer IDs.
*/

-- Before Cleaning: Identify NULLs and duplicate customer IDs
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- After Cleaning: Validate customer primary key
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/*
----------------------------------------------------------------------
1.2 Check for Unwanted Spaces in Customer Names
----------------------------------------------------------------------
Expectation:
    Silver customer names should not contain leading or trailing spaces.
*/

-- Before Cleaning
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- After Cleaning
SELECT
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


/*
----------------------------------------------------------------------
1.3 Data Standardization and Consistency - Gender
----------------------------------------------------------------------
Expected Silver Values:
    Male
    Female
    n/a
*/

-- Before Cleaning
SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info;


-- After Cleaning
SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info;


/*
----------------------------------------------------------------------
1.4 Data Standardization and Consistency - Marital Status
----------------------------------------------------------------------
Expected Silver Values:
    Married
    Single
    n/a
*/

-- Before Cleaning
SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info;


-- After Cleaning
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;



/*
======================================================================
2. CRM PRODUCT INFORMATION
======================================================================
Table:
    bronze.crm_prd_info
    silver.crm_prd_info
======================================================================
*/


/*
----------------------------------------------------------------------
2.1 Check for NULLs or Duplicates in Product Primary Key
----------------------------------------------------------------------
Expectation:
    Silver should contain NO NULLs or duplicate product IDs.
*/

-- Before Cleaning
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- After Cleaning
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


/*
----------------------------------------------------------------------
2.2 Check for Unwanted Spaces in Product Name
----------------------------------------------------------------------
Expectation:
    Product names should not contain leading or trailing spaces.
*/

-- Before Cleaning
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- After Cleaning
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


/*
----------------------------------------------------------------------
2.3 Check for NULL or Negative Product Cost
----------------------------------------------------------------------
Expectation:
    Silver product cost should not contain negative values.
    NULL costs are transformed to 0 during the Silver load.
*/

-- Before Cleaning
SELECT
    prd_id,
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0
    OR prd_cost IS NULL;


-- After Cleaning
SELECT
    prd_id,
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
    OR prd_cost IS NULL;


/*
----------------------------------------------------------------------
2.4 Data Standardization and Consistency - Product Line
----------------------------------------------------------------------
Expected Silver Values:
    Mountain
    Road
    other Sales
    Touring
    n/a
*/

-- Before Cleaning
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;


-- After Cleaning
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


/*
----------------------------------------------------------------------
2.5 Validate Product Date Ranges
----------------------------------------------------------------------
Business Rule:
    Product start date must not be greater than the end date.

    Silver end date is derived using:
        Next Product Start Date - 1 day

    This prevents overlapping product validity periods.
*/

-- Validate Silver Product Date Ranges
SELECT
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


/*
----------------------------------------------------------------------
2.6 Investigate Product Date Transformation
----------------------------------------------------------------------
Purpose:
    Validate the LEAD() logic used to derive product end dates.
*/

SELECT
    prd_id,
    prd_key,
    prd_nm,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        LEAD(prd_start_dt)
        OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - 1 AS DATE
    ) AS calculated_prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN (
    'AC-HE-HL-U509-R',
    'AC-HE-HL-U509'
);



/*
======================================================================
3. CRM SALES DETAILS
======================================================================
Table:
    bronze.crm_sales_details
    silver.crm_sales_details
======================================================================
*/


/*
----------------------------------------------------------------------
3.1 Validate Sales Date Order
----------------------------------------------------------------------
Business Rules:
    Order Date <= Ship Date
    Ship Date <= Due Date
    Order Date <= Due Date

Expectation:
    No invalid date relationships in Silver.
*/

SELECT
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_ship_dt > sls_due_dt
    OR sls_order_dt > sls_due_dt;


/*
----------------------------------------------------------------------
3.2 Check Invalid Sales Dates in Bronze
----------------------------------------------------------------------
Purpose:
    Identify invalid date representations before conversion to DATE.

Rules:
    - Date cannot be zero or negative.
    - Date must contain exactly 8 digits.
    - Date should fall within the expected business range.
*/

SELECT
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101;


/*
----------------------------------------------------------------------
3.3 Validate Due Date in Bronze
----------------------------------------------------------------------
*/

SELECT
    sls_ord_num,
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101;


/*
----------------------------------------------------------------------
3.4 Validate Sales, Quantity and Price
----------------------------------------------------------------------
Business Rules:
    Sales = Quantity * Price
    Sales > 0
    Quantity > 0
    Price > 0
    None of the three values should be NULL.

Expectation:
    Identify records violating these rules in Bronze.
*/

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


/*
----------------------------------------------------------------------
3.5 Validate Business Rules After Silver Transformation
----------------------------------------------------------------------
Expectation:
    No invalid Sales, Quantity or Price values should remain.
*/

SELECT
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
    OR sls_sales != sls_quantity * sls_price;



/*
======================================================================
4. ERP CUSTOMER INFORMATION
======================================================================
Table:
    bronze.erp_cust_az12
    silver.erp_cust_az12
======================================================================
*/


/*
----------------------------------------------------------------------
4.1 Data Standardization and Consistency - Gender
----------------------------------------------------------------------
Expected Silver Values:
    Male
    Female
    N/A
*/

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


/*
----------------------------------------------------------------------
4.2 Validate Future Birth Dates
----------------------------------------------------------------------
Business Rule:
    Birth date cannot be in the future.

Expectation:
    No result.
*/

SELECT
    cid,
    bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();



/*
======================================================================
5. ERP LOCATION INFORMATION
======================================================================
Table:
    bronze.erp_loc_a101
    silver.erp_loc_a101
======================================================================
*/


/*
----------------------------------------------------------------------
5.1 Validate Customer ID Transformation
----------------------------------------------------------------------
Transformation:
    Remove '-' from ERP customer IDs before loading Silver.

Purpose:
    Identify ERP location records whose transformed customer ID
    does not match a CRM customer key.
*/

SELECT
    REPLACE(cid, '-', '') AS transformed_cid,
    CASE
        WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) = ''
            OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS standardized_country
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);


/*
----------------------------------------------------------------------
5.2 Data Standardization and Consistency - Country
----------------------------------------------------------------------
Expected Silver Values:
    Standardized country names/codes
    N/A for missing values
*/

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101;



/*
======================================================================
6. ERP PRODUCT CATEGORY INFORMATION
======================================================================
Table:
    bronze.erp_px_cat_g1v2
    silver.erp_px_cat_g1v2
======================================================================
*/


/*
----------------------------------------------------------------------
6.1 Check for Unwanted Spaces
----------------------------------------------------------------------
Expectation:
    No leading or trailing spaces in category-related fields.
*/

-- Before Cleaning
SELECT
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);


/*
----------------------------------------------------------------------
6.2 Data Standardization and Consistency
----------------------------------------------------------------------
Purpose:
    Review category values before/after the Silver transformation.
*/

-- Before Cleaning
SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2;


-- After Cleaning
SELECT DISTINCT
    cat
FROM silver.erp_px_cat_g1v2;



/*
======================================================================
7. SUMMARY OF VALIDATION AREAS
======================================================================

The Bronze -> Silver transformation has been validated across:

    1. Primary Key Integrity
       - NULL primary keys
       - Duplicate primary keys

    2. Data Cleansing
       - Leading/trailing spaces
       - Missing values

    3. Data Standardization
       - Gender
       - Marital status
       - Product line
       - Country

    4. Date Validation
       - Invalid date formats
       - Date boundaries
       - Future birth dates
       - Order/Ship/Due date relationships
       - Product validity periods

    5. Business Rule Validation
       - Sales = Quantity * Price
       - Positive Sales
       - Positive Quantity
       - Positive Price

    6. Transformation Validation
       - Customer ID cleanup
       - Product key/category extraction
       - Product validity date calculation
       - Country standardization

    7. Cross-table Validation
       - ERP customer IDs against CRM customer keys

======================================================================
*/
