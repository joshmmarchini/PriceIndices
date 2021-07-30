/*
This script looks at Cost of Living from 2018 - 2021 across countries. 
Data was downloaded from numbeo.com.
Data downloaded information:
- All indices are relative to New yor City, which means that for NYC, each index should be 100%.
- So for example, if a city has a rent index of 120, it means that on average that city has rent 20% more expensive than NYC.
- If a city has 70% rent index, it is 30% less expensive than NYC.
- Cost of Living Index (Excl. Rent): Relative indicator of consumer goods prices like groceries, restaurats, transportation, and utilities.
	- Does not include accomodation expenses such as rent or mortgage.
- Rent Index: Estimation of prices compared to NYC
- Groceries Index: Estimation of groceries compared to NYC
- Restaurants Index: Comparison of prices of meals and drinks in restaurants and bars compared to NYC
- Cost of LIving Plus Rent Index: Estimation of consumer goods prices including rent comparing to NYC
- Local Purchasing Power: Shows relative purchsaing power in buying goods and services in a given city for the average net salary in that city. 
- Disclaimer about numbeo data: There is no third party check or audit on the accuracy of data.
	-Comparison against other international city data sources conducted by Ray Woodcock in 2017
	 suggested that Numbeo might be inaccurate on a city level, while on a country level it is more accurate
 */

--Import five tables: cost of living, groceries, local purchasing power, rent, restaurants

--Lets check out the tables that were imported

SELECT*
FROM cost_of_living_tbl;

SELECT*
FROM groceries_tbl;

SELECT*
FROM local_purchasing_power_tbl;

SELECT*
FROM rent_tbl;

SELECT*
FROM restaurants_tbl;

/*Sometimes a country is missing a measurment for a time interval.
To account for this, let's create a list with a row for every country/snapshot date that has 
an index measurement taken and put this list in a view*/

CREATE VIEW country_snapshot_list_v AS (
SELECT DISTINCT country, snapshot_date FROM cost_of_living_tbl WHERE country IS NOT NULL
UNION
SELECT DISTINCT country, snapshot_date FROM groceries_tbl WHERE country IS NOT NULL
UNION
SELECT DISTINCT country, snapshot_date FROM local_purchasing_power_tbl WHERE country IS NOT NULL
UNION
SELECT DISTINCT country, snapshot_date FROM rent_tbl WHERE country IS NOT NULL
UNION
SELECT DISTINCT country, snapshot_date FROM restaurants_tbl WHERE country IS NOT NULL);

--Let's check out the view
SELECT*
FROM country_snapshot_list_v

/*Create a view that displays all indexes for a given country and snapshot date*/

CREATE VIEW all_indexes_v As (
SELECT l.country, l.snapshot_date, g.groceries_index, col.cost_of_living_index,
pp.local_purchasing_power_index, r.rent_index, rr.restaurants_index
FROM country_snapshot_list_v l
LEFT JOIN cost_of_living_tbl col
	ON col.country = l.country AND col.snapshot_date = l.snapshot_date
LEFT JOIN groceries_tbl g
	ON l.country = g.country AND l.snapshot_date = g.snapshot_date
LEFT JOIN local_purchasing_power_tbl pp
	ON l.country = pp.country AND l.snapshot_date = pp.snapshot_date
LEFT JOIN rent_tbl r
	ON l.country = r.country AND l.snapshot_date = r.snapshot_date
LEFT JOIN restaurants_tbl rr
	ON l.country = rr.country AND l.snapshot_date = rr.snapshot_date);

--Check out the view
SELECT*
FROM all_indexes_v

--Create a view containing the time period average for each index
CREATE VIEW snapshot_avg_v AS (
SELECT distinct snapshot_date,
AVG(cost_of_living_index) OVER(PARTITION BY snapshot_date) As avg_snapshot_cost_of_living_index,
AVG(groceries_index) OVER(PARTITION BY snapshot_date) As avg_snapshot_groceries_index,
AVG(local_purchasing_power_index) OVER(PARTITION BY snapshot_date) As avg_snapshot_purchasing_power_index,
AVG(rent_index) OVER(PARTITION BY snapshot_date) As avg_snapshot_rent_index,
AVG(restaurants_index) OVER(PARTITION BY snapshot_date) As avg_snapshot_restaurants_index
FROM all_indexes_v);

--Let's rank how expensive each country is relative to other countries according to the five cost of living indexes.
--To do this, let's get the average index value from 2018 - 2021 for each country, then rank each country with each of the five indeces
--Put this in a view

CREATE VIEW avg_index_2018_to_2021_v AS(
SELECT country,
ROUND(avg(groceries_index),2) AS avg_groceries_2018_to_2021,
RANK() OVER(ORDER BY avg(groceries_index) DESC) As rank_avg_groceries_2018_to_2021,
ROUND(avg(cost_of_living_index),2) AS avg_cost_of_living_2018_to_2021,
RANK() OVER(ORDER BY avg(cost_of_living_index) DESC) As rank_avg_cost_of_living_2018_to_2021,
ROUND(avg(rent_index),2) AS avg_rent_2018_to_2021,
RANK() OVER(ORDER BY avg(rent_index) DESC) As rank_avg_rent_2018_to_2021,
ROUND(avg(local_purchasing_power_index),2) AS avg_local_purchasing_power_2018_to_2021,
RANK() OVER(ORDER BY avg(local_purchasing_power_index) DESC) As rank_avg_local_purchasing_power_2018_to_2021,
ROUND(avg(restaurants_index),2) AS avg_restaurants_index_2018_to_2021,
RANK() OVER(ORDER BY avg(restaurants_index) DESC) As rank_avg_restaurants_2018_to_2021
FROM all_indexes_v
GROUP B
\Y country);

--View executed. Let's check it out.

SELECT*
FROM avg_index_2018_to_2021_v









-------------------------------------------------------------
Scrap
SELECT*
FROM cost_of_living_tbl
WHERE country = 'Afghanistan'
ORDER By snapshot_date_for_ordering










 





















