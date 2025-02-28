# What is RFM Segmentation?

RFM segmentation is a marketing technique used to analyze customer value based on their purchasing behavior. RFM stands for **Recency**, **Frequency**, and **Monetary Value**, which are three key metrics used to segment customers. This method helps businesses identify their most valuable customers and tailor marketing strategies accordingly.

## How do we segment customers?

We calculate three key scores for each customer: Recency (how recently they bought something), Frequency (how often they shop), and Monetary (how much they spend). Based on these scores, we group customers into different categories like:

- Churned Customer: Haven’t shopped in a while, probably not coming back.

- Slipping Away, Cannot Lose: Used to shop a lot but haven’t been around recently need to win them back!

- New Customers: Just started shopping with us—let’s make them stick around.

- Potential Churners: At risk of leaving—time to re-engage them.

- Active: Shopping regularly but not super frequently.

- Loyal: Our best customers—they shop often, spend a lot, and keep coming back.

Using an SQL script, we crunch the numbers and sort customers into these groups. This helps us figure out who to focus on and how to keep them happy (or bring them back)!

## Database Setup

By doing Bulk Insertion, the database has created.

- Import wizard data

## Dataset Exploration

```sql
SELECT * FROM RFM_SALES LIMIT 10;
```

-- OUTPUT --
|ORDERNUMBER|QUANTITYORDERED|PRICEEACH|ORDERLINENUMBER|SALES |ORDERDATE |STATUS |QTR_ID|MONTH_ID|YEAR_ID|PRODUCTLINE|MSRP|PRODUCTCODE|CUSTOMERNAME |PHONE |ADDRESSLINE1 |ADDRESSLINE2|CITY |STATE|POSTALCODE|COUNTRY|TERRITORY|CONTACTLASTNAME|CONTACTFIRSTNAME|DEALSIZE|
|-----------|---------------|---------|---------------|-------|----------|-------|------|--------|-------|-----------|----|-----------|------------------------|----------------|-----------------------------|------------|-------------|-----|----------|-------|---------|---------------|----------------|--------|
|10107 |30 |95.7 |2 |2871 |2003-02-24|Shipped|1 |2 |2003 |Motorcycles|95 |S10_1678 |Land of Toys Inc. |2125557818 |897 Long Airport Avenue | |NYC |NY |10022 |USA |NA |Yu |Kwai |Small |
|10121 |34 |81.35 |5 |2765.9 |2003-05-07|Shipped|2 |5 |2003 |Motorcycles|95 |S10_1678 |Reims Collectables |26.47.1555 |59 rue de l'Abbaye | |Reims | |51100 |France |EMEA |Henriot |Paul |Small |
|10134 |41 |94.74 |2 |3884.34|2003-07-01|Shipped|3 |7 |2003 |Motorcycles|95 |S10_1678 |Lyon Souveniers |+33 1 46 62 7555|27 rue du Colonel Pierre Avia| |Paris | |75508 |France |EMEA |Da Cunha |Daniel |Medium |
|10145 |45 |83.26 |6 |3746.7 |2003-08-25|Shipped|3 |8 |2003 |Motorcycles|95 |S10_1678 |Toys4GrownUps.com |6265557265 |78934 Hillside Dr. | |Pasadena |CA |90003 |USA |NA |Young |Julie |Medium |
|10159 |49 |100 |14 |5205.27|2003-10-10|Shipped|4 |10 |2003 |Motorcycles|95 |S10_1678 |Corporate Gift Ideas Co.|6505551386 |7734 Strong St. | |San Francisco|CA | |USA |NA |Brown |Julie |Medium |
|10168 |36 |96.66 |1 |3479.76|2003-10-28|Shipped|4 |10 |2003 |Motorcycles|95 |S10_1678 |Technics Stores Inc. |6505556809 |9408 Furth Circle | |Burlingame |CA |94217 |USA |NA |Hirano |Juri |Medium |
|10180 |29 |86.13 |9 |2497.77|2003-11-11|Shipped|4 |11 |2003 |Motorcycles|95 |S10_1678 |Daedalus Designs Imports|20.16.1555 |184, chausse de Tournai | |Lille | |59000 |France |EMEA |Rance |Martine |Small |
|10188 |48 |100 |1 |5512.32|2003-11-18|Shipped|4 |11 |2003 |Motorcycles|95 |S10_1678 |Herkku Gifts |+47 2267 3215 |Drammen 121, PR 744 Sentrum | |Bergen | |N 5804 |Norway |EMEA |Oeztan |Veysel |Medium |
|10201 |22 |98.57 |2 |2168.54|2003-12-01|Shipped|4 |12 |2003 |Motorcycles|95 |S10_1678 |Mini Wheels Co. |6505555787 |5557 North Pendale Street | |San Francisco|CA | |USA |NA |Murphy |Julie |Small |
|10211 |41 |100 |14 |4708.44|2004-01-15|Shipped|1 |1 |2004 |Motorcycles|95 |S10_1678 |Auto Canal Petit |(1) 47.55.6555 |25, rue Lauriston | |Paris | |75016 |France |EMEA |Perrier |Dominique |Medium |

```sql
SELECT COUNT(*) FROM RFM_SALES; -- 2823
```

-- OUTPUT --
| COUNT(\*) |
|----------|
| 2823 |

```sql
SELECT COUNT(distinct ORDERNUMBER) FROM RFM_SALES; -- 307
```

-- OUTPUT --
| COUNT(\*) |
|----------|
| 307 |

## Checking unique values

```sql
select distinct STATUS from RFM_SALES;
select distinct PRODUCTLINE from RFM_SALES;
select distinct COUNTRY from RFM_SALES;
select distinct DEALSIZE from RFM_SALES;
select distinct TERRITORY from RFM_SALES;
```

-- OUTPUT --
| status |
|------------|
| Shipped |
| Disputed |
| In Process |
| Cancelled |
| On Hold |
| Resolved |

-- OUTPUT --
| PRODUCTLINE |
|------------------|
| Motorcycles |
| Classic Cars |
| Trucks and Buses |
| Vintage Cars |
| Planes |
| Ships |
| Trains |

-- OUTPUT --
| COUNTRY |
|-------------|
| USA |
| France |
| Norway |
| Australia |
| Finland |
| Austria |
| UK |
| Spain |
| Sweden |
| Singapore |
| Canada |
| Japan |
| Italy |
| Denmark |
| Belgium |
| Philippines |
| Germany |
| Switzerland |
| Ireland |

-- OUTPUT --
| DEALSIZE |
|----------|
| Small |
| Medium |
| Large |

-- OUTPUT --
| TERRITORY |
|-----------|
| NA |
| EMEA |
| APAC |
| Japan |

## Checking Data Duplicacy or Empty value or null values

```sql
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
```

## Analysis the Sales Data

- Highest Selling Items
```sql
with CTE as
(select productline, round(sum(sales), 0) as Total_revenue, count(*) as Total_number_of_sales
 from RFM_SALES
	group by productline)
select productline, Total_revenue, Total_number_of_sales,
RANK() OVER (ORDER BY Total_revenue desc) as rank_on_revenue  from CTE
group by productline;
```
  -- OUTPUT --
  |productline|Total_revenue|Total_number_of_sales|rank_on_revenue|
  |-----------|-------------|---------------------|---------------|
  |Classic Cars|3919616 |967 |1 |
  |Vintage Cars|1903151 |607 |2 |
  |Motorcycles|1166388 |331 |3 |
  |Trucks and Buses|1127790 |301 |4 |
  |Planes |975004 |306 |5 |
  |Ships |714437 |234 |6 |
  |Trains |226243 |77 |7 |

- Top Selling Countries
```sql
SELECT 
    COUNTRY, ROUND(SUM(sales), 0) AS Total_revenue
FROM
    RFM_SALES
GROUP BY country
ORDER BY Total_revenue desc
LIMIT 5;
```
  -- OUTPUT --
  |COUNTRY|Total_revenue|
  |-------|-------------|
  |USA |3627983 |
  |Spain |1215687 |
  |France |1110917 |
  |Australia|630623 |
  |UK |478880 |

- Top Selling Cities
```sql
SELECT 
    city, ROUND(SUM(sales), 0) AS Total_revenue
FROM
    RFM_SALES
GROUP BY city
ORDER BY Total_revenue desc
limit 10;
```
  -- OUTPUT --
  |city |Total_revenue|
  |-----|-------------|
  |Madrid|1082551 |
  |San Rafael|654858 |
  |NYC |560788 |
  |Singapore|288488 |
  |Paris|268945 |
  |San Francisco|224359 |
  |New Bedford|207875 |
  |Nantes|204305 |
  |Melbourne|200995 |
  |Brickhaven|165255 |

- Top Customers
```sql
SELECT
CUSTOMERNAME, ROUND(SUM(sales), 0) AS TOTAL_SALE
FROM RFM_SALES
group by CUSTOMERNAME
order by TOTAL_SALE desc
LIMIT 5;
```
  -- OUTPUT --
  |CUSTOMERNAME|TOTAL_SALE|
  |------------|----------|
  |Euro Shopping Channel|912294 |
  |Mini Gifts Distributors Ltd.|654858 |
  |Australian Collectors, Co.|200995 |
  |Muscle Machine Inc|197737 |
  |La Rochelle Gifts|180125 |

- What are the top selling products in November 2003?
```sql
select  PRODUCTLINE, ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency
from RFM_SALES
where year(orderdate) = 2003 and monthname(orderdate) = 'November' -- change year to see the rest
group by  PRODUCTLINE
order by Revenue desc;
```
  -- OUTPUT --
  |PRODUCTLINE|Revenue|Frequency|
  |-----------|-------|---------|
  |Classic Cars|452924 |114 |
  |Vintage Cars|184673 |66 |
  |Trucks and Buses|127063 |33 |
  |Motorcycles|109346 |31 |
  |Ships |79175 |27 |
  |Planes |54133 |16 |
  |Trains |22523 |9 |

- What was the best selling month in total by segmenting year? How much was earned that month?
```sql
select YEAR(orderdate) AS order_year,
    monthname(orderdate) AS order_month,
    ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency from RFM_SALES
GROUP BY order_year, order_month
ORDER BY order_year, Revenue DESC;
```	
  -- OUTPUT --
  |order_year|order_month|Revenue|Frequency|
  |----------|-----------|-------|---------|
  |2003 |November |1029838|296 |
  |2003 |October |568291 |158 |
  |2003 |September |263973 |76 |
  |2003 |December |261876 |70 |
  |2003 |April |201610 |58 |
  |2003 |August |197809 |58 |
  |2003 |May |192673 |58 |
  |2003 |July |187732 |50 |
  |2003 |March |174505 |50 |
  |2003 |June |168083 |46 |
  |2003 |February |140836 |41 |
  |2003 |January |129754 |39 |
  |2004 |November |1089048|301 |
  |2004 |October |552924 |159 |
  |2004 |August |461501 |133 |
  |2004 |December |372803 |110 |
  |2004 |July |327144 |91 |
  |2004 |September |320751 |95 |
  |2004 |January |316577 |91 |
  |2004 |February |311420 |86 |
  |2004 |June |286674 |85 |
  |2004 |May |273438 |74 |
  |2004 |April |206148 |64 |
  |2004 |March |205734 |56 |
  |2005 |May |457861 |120 |
  |2005 |March |374263 |106 |
  |2005 |February |358186 |97 |
  |2005 |January |339543 |99 |
  |2005 |April |261633 |56 |

- What was the best selling month in 2003? How much was earned that month?
```sql
select  monthname(orderdate) as Month_name, ROUND(SUM(sales), 0) as Revenue, count(ORDERNUMBER) Frequency
from RFM_SALES
where year(orderdate) = 2003 -- change year to see the rest
group by  Month_name
order by Revenue desc;
```
  -- OUTPUT --
  |Month_name|Revenue|Frequency|
  |----------|-------|---------|
  |November |1029838|296 |
  |October |568291 |158 |
  |September |263973 |76 |
  |December |261876 |70 |
  |April |201610 |58 |
  |August |197809 |58 |
  |May |192673 |58 |
  |July |187732 |50 |
  |March |174505 |50 |
  |June |168083 |46 |
  |February |140836 |41 |
  |January |129754 |39 |

**This SQL query calculates the RFM (Recency, Frequency, Monetary) values for each customer in the dataset**

```sql
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
```

-- OUTPUT --
|CUSTOMERNAME|RECENCY_VALUE|R_SCORE|FREQUENCY_VALUE|F_SCORE|MONETARY_VALUE|M_SCORE|TOTAL_RFM_SCORE|RFM_SCORE_COMBINATION|
|------------|-------------|-------|---------------|-------|--------------|-------|---------------|---------------------|
|Bavarian Collectables Imports, Co.|258 |1 |1 |1 |2500 |1 |3 |111 |
|Australian Collectables, Ltd|22 |5 |3 |2 |2808 |1 |8 |521 |
|Signal Gift Stores|183 |3 |3 |3 |2853 |1 |7 |331 |
|Royal Canadian Collectables, Ltd.|284 |1 |2 |1 |2871 |1 |3 |111 |
|Rovelli Gifts|200 |2 |3 |2 |2874 |1 |5 |221 |
|Marseille Mini Autos|145 |3 |3 |3 |2997 |1 |7 |331 |
|Petit Auto |1 |5 |3 |2 |2999 |1 |8 |521 |
|Double Decker Gift Stores, Ltd|495 |1 |2 |1 |3002 |1 |3 |111 |
|giftsbymail.co.uk|211 |2 |2 |1 |3009 |1 |4 |211 |
|Gift Ideas Corp.|178 |3 |3 |3 |3015 |1 |7 |331 |

**This SQL code segment assigns a customer segment label based on their RFM category combination**

```sql

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
```

-- OUTPUT --
|CUSTOMER_SEGMENT|NUMBER_OF_CUSTOMERS|
|----------------|-------------------|
|OTHER |23 |
|CHURNED CUSTOMER|16 |
|POTENTIAL CHURNERS|13 |
|ACTIVE |12 |
|SLIPPING AWAY, CANNOT LOSE|11 |
|LOYAL |11 |
|NEW CUSTOMERS |6 |
