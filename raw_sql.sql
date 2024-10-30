/*
    Quick Guide to the SQL Grocery Data Project

    This SQL script is designed to clean, analyze, and visualize grocery data 
    through various transformations and calculations. Below is a breakdown of 
    each section in the script:

    1. **Month Mapping Table Creation**
       - Creates a table to map month codes to their respective names.

    2. **Populating Month Mapping Table**
       - Inserts month code and name pairs into the mapping table.

    3. **Clearing Previous Data**
       - Drops the cleaned_grocery_data table if it exists to start fresh.

    4. **Creating Cleaned Grocery Data Table**
       - Defines the structure of the cleaned_grocery_data table with relevant fields.

    5. **Populating Cleaned Grocery Table**
       - Inserts data from the raw grocery data into the cleaned table with renamed headers.

    6. **Updating Product Names**
       - Joins with the product mapping table to add product names to the cleaned data.

    7. **Adding Average Price Column**
       - Alters the cleaned grocery data table to add a column for average price per year.

    8. **Populating Average Price Column**
       - Calculates and rounds the average price per year for each product.

    9. **Calculating Yearly Percentage Change**
       - Computes the highest percentage change for each product year over year.

    10. **Selecting Year with Highest Percentage Change**
        - Identifies the year for each product that shows the maximum percentage change.

    11. **Creating SQLite View**
        - Drops any existing view with the same name to avoid conflicts.

    12. **Creating View with Desired Data**
        - Constructs a view combining month name, year, product name, price, and average price.

    13. **Displaying the View**
        - Selects all data from the created view for easy access.

    14. **Displaying the View with Pandas**
        - Retrieves the view data to be displayed in a DataFrame using Pandas.

    15. **Displaying Product and Year with Highest Change**
        - Shows the product, year, and percentage change of the year with the highest change.

    16. **Final Cleaned Grocery Data Table**
        - Displays all records from the cleaned grocery data table.
*/



-- 1. Create a month mapping table to translate month codes (M01) to names (January)
CREATE TABLE IF NOT EXISTS month_mapping (
    month_code VARCHAR(3) PRIMARY KEY,
    month_name VARCHAR(255)
);

-- 2. Populate the month mapping table
INSERT OR IGNORE INTO month_mapping (month_code, month_name) VALUES
    ('M01', 'January'),
    ('M02', 'February'),
    ('M03', 'March'),
    ('M04', 'April'),
    ('M05', 'May'),
    ('M06', 'June'),
    ('M07', 'July'),
    ('M08', 'August'),
    ('M09', 'September'),
    ('M10', 'October'),
    ('M11', 'November'),
    ('M12', 'December');

-- 3. Clearing cleaned_grocery_data table for a fresh run 
DROP TABLE IF EXISTS cleaned_grocery_data;

-- 4. Creating a new grocery data table with cleaned data
CREATE TABLE IF NOT EXISTS cleaned_grocery_data(
    product_id VARCHAR(255),
    product_name VARCHAR(255),
    year INT,
    month_name VARCHAR(255),
    price_usd FLOAT
);

-- 5. Populating cleaned grocery table and renaming headers
INSERT INTO cleaned_grocery_data (product_id, year, month_name, price_usd)
SELECT
    Series_id AS product_id,
    Year AS year,
    Period AS month_name,
    Value AS price_usd
FROM
    grocery_data gd;

-- 6. Adding in the product names (Eggs, Bread, etc.) from the separate product mapping table to help identify products
UPDATE cleaned_grocery_data
SET product_name = (
    SELECT product_name
    FROM product_mapping
    WHERE product_mapping.product_id = cleaned_grocery_data.product_id
)
WHERE cleaned_grocery_data.product_id IN (
    SELECT product_id
    FROM product_mapping
);

-- 7. Adding a new column that will calculate the average price per year for each product 
ALTER TABLE cleaned_grocery_data 
ADD COLUMN avg_price_per_year FLOAT;

-- 8. Populating the new average price column and rounding to hundredths for USD 
UPDATE cleaned_grocery_data
SET avg_price_per_year = ROUND(
    (
        SELECT AVG(price_usd)
        FROM cleaned_grocery_data sub
        WHERE sub.product_id = cleaned_grocery_data.product_id
          AND sub.year = cleaned_grocery_data.year
        GROUP BY sub.year
    ),
    2
);

-- 9. Calculating the percent change from year to year for each product based on yearly average:
SELECT
    product_id,
    product_name,
    year,
    MAX(percent_change) AS highest_percentage_change
FROM (
    SELECT
        cg.product_id,
        cg.year,
        cg.price_usd,
        pm.product_name,
        ((avg_price - lag_avg_price) / lag_avg_price) * 100 AS percent_change
    FROM cleaned_grocery_data cg
    JOIN product_mapping pm ON cg.product_id = pm.product_id
    JOIN (
        SELECT
            product_id,
            year,
            AVG(price_usd) AS avg_price,
            lag(AVG(price_usd)) OVER (PARTITION BY product_id ORDER BY year) AS lag_avg_price
        FROM cleaned_grocery_data
        GROUP BY product_id, year
    ) avg_prices ON cg.product_id = avg_prices.product_id AND cg.year = avg_prices.year
) changes
GROUP BY product_id, year;

-- 10. Selecting the year for each product that has the highest percentage change based on yearly average
WITH RankedChanges AS (
    SELECT
        product_id,
        product_name,
        year,
        (price_usd - lag_avg_price) / lag_avg_price * 100 AS percentage_change,
        RANK() OVER (PARTITION BY product_id ORDER BY (price_usd - lag_avg_price) / lag_avg_price DESC) AS rank_change
    FROM (
        SELECT
            cg.product_id,
            cg.year,
            cg.price_usd,
            pm.product_name,
            LAG(avg_price) OVER (PARTITION BY cg.product_id ORDER BY cg.year) AS lag_avg_price
        FROM cleaned_grocery_data cg
        JOIN product_mapping pm ON cg.product_id = pm.product_id
        JOIN (
            SELECT
                product_id,
                year,
                AVG(price_usd) AS avg_price
            FROM cleaned_grocery_data
            GROUP BY product_id, year
        ) avg_prices ON cg.product_id = avg_prices.product_id AND cg.year = avg_prices.year
    ) changes
)
SELECT
    product_id,
    product_name,
    year
FROM RankedChanges
WHERE rank_change = 1;

-- 11. Making a new SQLite view with only desired data, first erasing any previous view with same name
DROP VIEW IF EXISTS grocery_data_view;

-- 12. Creating the view with month name, year, product name, product id, rounded USD price, and average price per year
CREATE VIEW grocery_data_view AS
SELECT mm.month_name, cgd.year, cgd.product_name, cgd.product_id, ROUND(cgd.price_usd, 2) AS price_usd, avg_price_per_year
FROM cleaned_grocery_data AS cgd
LEFT JOIN month_mapping AS mm ON cgd.month_name = mm.month_code;

-- 13. Displaying the view
SELECT * FROM grocery_data_view;

-- 14. Displaying the view with Pandas
SELECT * FROM grocery_data_view;

-- 15. Displaying the product, year with highest percentage change, and percentage change value of that respective year
WITH RankedChanges AS (
    SELECT
        product_id,
        product_name,
        year,
        (price_usd - lag_avg_price) / lag_avg_price * 100 AS percentage_change,
        RANK() OVER (PARTITION BY product_id ORDER BY (price_usd - lag_avg_price) / lag_avg_price DESC) AS rank_change
    FROM (
        SELECT
            cg.product_id,
            cg.year,
            cg.price_usd,
            pm.product_name,
            LAG(avg_price) OVER (PARTITION BY cg.product_id ORDER BY cg.year) AS lag_avg_price
        FROM cleaned_grocery_data cg
        JOIN product_mapping pm ON cg.product_id = pm.product_id
        JOIN (
            SELECT
                product_id,
                year,
                AVG(price_usd) AS avg_price
            FROM cleaned_grocery_data
            GROUP BY product_id, year
        ) avg_prices ON cg.product_id = avg_prices.product_id AND cg.year = avg_prices.year
    ) changes
)
SELECT
    product_id,
    product_name,
    year,
    percentage_change
FROM RankedChanges
WHERE rank_change = 1;

-- 16. Showing the final cleaned grocery data table
SELECT * FROM cleaned_grocery_data;