/*
Solution to the costAnalysis question

Answer:
Fixed cost for production below 8500: 2,800,352
Fixed cost for production above 8500: 4,303,369
Variable cost (per unit): 1000

*/



--Create a table to import data
CREATE TABLE cost_data (
	monthID bigInt,
	production int,
	cost_incurred int);

--Import data
COPY cost_data (monthID, production, cost_incurred)
FROM 'C:\location of your file\cost_data.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');
 
–Find missing values
SELECT monthID,
	production,
 	cost_incurred
FROM cost_data
WHERE production IS NULL OR cost_incurred IS NULL;
--monthID 15 identified


--find duplicate values
SELECT monthID,
	production,
 	cost_incurred,
	count(*)
FROM cost_data
GROUP BY monthID, production, cost_incurred
HAVING count(*) > 1;
--monthID 27 identified


--find extreme values
SELECT monthID,
	production, 
	cost_incurred
FROM cost_data 
WHERE production >= ( 
	SELECT percentile_cont(0.99) WITHIN GROUP (ORDER BY production) 
	FROM cost_data ) OR 
	production <= ( 
	SELECT percentile_cont(.01) WITHIN GROUP (ORDER BY production) 
	FROM cost_data )
ORDER BY production ASC;
--monthID 25 has a zero for production 

SELECT monthID,
 production, 
 cost_incurred 
FROM cost_data 
WHERE cost_incurred >= ( 
 SELECT percentile_cont(0.99) WITHIN GROUP (ORDER BY cost_incurred) 
 FROM cost_data ) OR 
 cost_incurred <= ( 
 SELECT percentile_cont(.01) WITHIN GROUP (ORDER BY cost_incurred) 
 FROM cost_data )
ORDER BY cost_incurred ASC;
--monthID 32 has an abnormally high cost_incurred figure


--create backup
CREATE TABLE cost_data_backup AS
SELECT * FROM cost_data;

– remove null values and extreme values
DELETE FROM cost_data
WHERE monthID = 15 OR
	monthID = 25 OR
	monthID = 27 OR
	monthID = 32; 

– regression in SQL (selecting only relevant values, separately for two groups)
SELECT round (
 regr_slope(cost_incurred, production ) :: numeric, 2
 ) AS slope,
 round(
 regr_intercept(cost_incurred, production) :: numeric, 2
 ) AS intercept
FROM cost_data
WHERE production < 8500;

SELECT round (
	regr_slope(cost_incurred, production ) :: numeric, 2
	) AS slope,
	round(
	regr_intercept(cost_incurred, production) :: numeric, 2
	) AS intercept
FROM cost_data
WHERE production >= 8500;
	

-- Optional export cleaned data and do regression in R
COPY cost_data
TO 'c:\location of your file\cost_data_cleaned.csv' ;
