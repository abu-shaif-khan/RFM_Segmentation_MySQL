-- Use defult database
USE SUPERSTORE;

-- Change table name
ALTER TABLE SALES RENAME TO RFM_SALES;

-- Inspection Data
SELECT * FROM RFM_SALES LIMIT 10;
SELECT * FROM RFM_SALES;
SELECT COUNT(*) FROM RFM_SALES; -- 2823

SELECT COUNT(distinct ORDERNUMBER) FROM RFM_SALES; -- 307

-- Checking unique values
select distinct STATUS from RFM_SALES;
select distinct year_id from RFM_SALES;
select distinct PRODUCTLINE from RFM_SALES;
select distinct COUNTRY from RFM_SALES;
select distinct DEALSIZE from RFM_SALES;
select distinct TERRITORY from RFM_SALES;

-- See order date format and convert date from string to date format
SELECT
 year(str_to_date(ORDERDATE, '%d/%m/%y')) AS Year,
    MONTHNAME(str_to_date(ORDERDATE, '%d/%m/%y')) AS MONTH_NAME
FROM RFM_SALES;

-- change date format to the table
SET SQL_SAFE_UPDATES = 0;
UPDATE RFM_SALES
SET ORDERDATE = str_to_date(ORDERDATE, '%d/%m/%y');

SELECT
 year(ORDERDATE) AS Year,
    MONTHNAME(ORDERDATE) AS MONTH_NAME
FROM RFM_SALES;

-- Checking Data Duplicacy or Empty value or null values 
select count(*) from RFM_SALES
	where ordernumber is null or ordernumber = '';
select count(*) from RFM_SALES
	where QUANTITYORDERED is null or QUANTITYORDERED = '';
select count(*) from RFM_SALES
	where PRICEEACH is null or PRICEEACH = '';
select count(*) from RFM_SALES
	where ORDERDATE is null or ORDERDATE = '';
select count(*) from RFM_SALES
	where STATUS is null or STATUS = '';
select count(*) from RFM_SALES
	where PRODUCTLINE is null or PRODUCTLINE = '';
select count(*) from RFM_SALES
	where CUSTOMERNAME is null or CUSTOMERNAME = '';
select count(*) from RFM_SALES
	where CITY is null or CITY = '';
select count(*) from RFM_SALES
	where COUNTRY is null or COUNTRY = '';
select count(*) from RFM_SALES
	where TERRITORY is null or TERRITORY = '';
select count(*) from RFM_SALES
	where DEALSIZE is null or DEALSIZE = '';
select count(*) from RFM_SALES
	where sales <= 0 and sales is null or sales = '';
    
select ORDERNUMBER, ORDERLINENUMBER, CUSTOMERNAME,  COUNT(*) AS duplicate_count
FROM RFM_SALES
GROUP BY ORDERNUMBER, ORDERLINENUMBER, CUSTOMERNAME
HAVING COUNT(*) > 1;
/* Here Necessery Columns and Rows are not empty so we do not need to drop that values by the reporting with stakeholders */

-- Analysis the sales data
SELECT sum(QUANTITYORDERED) FROM RFM_SALES; -- 99067

SELECT round(SUM(SALES), 0) AS REVENUE FROM RFM_SALES; -- 10032629

-- Highest Selling Items 
with CTE as
(select productline, round(sum(sales), 0) as Total_revenue, count(*) as Total_number_of_sales
 from RFM_SALES
	group by productline)
select productline, Total_revenue, Total_number_of_sales,
RANK() OVER (ORDER BY Total_revenue desc) as rank_on_revenue  from CTE
group by productline;

-- Top Selling Contries
SELECT 
    COUNTRY, ROUND(SUM(sales), 0) AS Total_revenue
FROM
    RFM_SALES
GROUP BY country
ORDER BY Total_revenue desc
LIMIT 5;

-- Top Selling Contries
SELECT 
    city, ROUND(SUM(sales), 0) AS Total_revenue
FROM
    RFM_SALES
GROUP BY city
ORDER BY Total_revenue desc
limit 10;

-- Top Customers 
SELECT
CUSTOMERNAME, ROUND(SUM(sales), 0) AS TOTAL_SALE
FROM RFM_SALES
group by CUSTOMERNAME
order by TOTAL_SALE desc
LIMIT 5;

-- What are the top selling products in November 2003??
select  PRODUCTLINE, ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency
from RFM_SALES
where year(orderdate) = 2003 and monthname(orderdate) = 'November' -- change year to see the rest
group by  PRODUCTLINE
order by Revenue desc;

-- What was the best selling month in 2003? How much was earned that month? 
select  monthname(orderdate) as Month_name, ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency
from RFM_SALES
where year(orderdate) = 2003 -- change year to see the rest
group by  Month_name
order by Revenue desc;

-- What was the best selling month in total by segmenting year? How much was earned that month?
select YEAR(orderdate) AS order_year,
    monthname(orderdate) AS order_month,
    ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency from RFM_SALES
GROUP BY order_year, order_month
ORDER BY order_year, Revenue DESC;


-- RFM SEGMENTATION: SEGMENTING YOUR CUSTOMER BASEN ON RECENCY (R), FREQUENCY (F), AND MONETARY (M) SCORES
CREATE OR REPLACE VIEW RFM_SCORE_DATA_VIEW AS
with RFM_Values as
(select CUSTOMERNAME, ROUND(avg(SALES),0) AS Monetary_Value,
    COUNT(DISTINCT ORDERNUMBER) AS Frequency_Value,
    datediff((select max(ORDERDATE) from RFM_SALES), max(ORDERDATE)) AS RECENCY_VALUE
    from RFM_SALES
    group by CUSTOMERNAME),
    
RFM_SCORE AS
(SELECT 
	RFM_Values.*,
    NTILE(4) OVER (ORDER BY RECENCY_VALUE DESC) AS R_SCORE,
    NTILE(4) OVER (ORDER BY FREQUENCY_VALUE ASC) AS F_SCORE,
    NTILE(4) OVER (ORDER BY MONETARY_VALUE ASC) AS M_SCORE
FROM RFM_Values)

SELECT
	R.CUSTOMERNAME,
    R.RECENCY_VALUE,
    R_SCORE,
    R.FREQUENCY_VALUE,
    F_SCORE,
    R.MONETARY_VALUE,
    M_SCORE,
    (R_SCORE + F_SCORE + M_SCORE) AS TOTAL_RFM_SCORE,
    CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) AS RFM_SCORE_COMBINATION
FROM RFM_SCORE AS R;

SELECT * FROM RFM_SCORE_DATA_VIEW limit 10;

CREATE OR REPLACE VIEW RFM_ANALYSIS AS
SELECT 
    RFM_SCORE_DATA_VIEW.*,
    CASE
        WHEN RFM_SCORE_COMBINATION IN (111, 112, 121, 132, 211, 211, 212, 114, 141) THEN 'CHURNED CUSTOMER'
        WHEN RFM_SCORE_COMBINATION IN (133, 134, 143, 224, 334, 343, 344, 144) THEN 'SLIPPING AWAY, CANNOT LOSE'
        WHEN RFM_SCORE_COMBINATION IN (311, 411, 331) THEN 'NEW CUSTOMERS'
        WHEN RFM_SCORE_COMBINATION IN (222, 231, 221,  223, 233, 322) THEN 'POTENTIAL CHURNERS'
        WHEN RFM_SCORE_COMBINATION IN (323, 333,321, 341, 422, 332, 432) THEN 'ACTIVE'
        WHEN RFM_SCORE_COMBINATION IN (433, 434, 443, 444) THEN 'LOYAL'
    ELSE 'OTHER'
    END AS CUSTOMER_SEGMENT
FROM RFM_SCORE_DATA_VIEW;

SELECT
	CUSTOMER_SEGMENT,
    COUNT(*) AS NUMBER_OF_CUSTOMERS
FROM RFM_ANALYSIS
GROUP BY CUSTOMER_SEGMENT
ORDER BY NUMBER_OF_CUSTOMERS DESC;

