IF OBJECT_ID('ref.[Malaysia Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Malaysia Delivery]
END;
-- 1. Add Make date column adjustments
-- 2. Add up the columns for the different dose numbers for each manufacturer and convert the column name into our desired manufacturer codes
WITH table_1 AS (
	SELECT 'Malaysia' AS [Recipient], 'MYS' AS [ISO], 415 AS [CountryID], 'https://raw.githubusercontent.com/CITF-Malaysia/citf-public/main/vaccination/vax_malaysia.csv' AS [Delivery Source],
	DATEADD(day, 1, EOMONTH([date], -1)) AS [Delivery Date], CONCAT(FORMAT([Date], 'MMM'), SPACE(1), DATEPART(year, [Date])) AS [Month],
	(pfizer1+pfizer2+pfizer3) AS [13], (sinovac1+sinovac2+sinovac3) AS [76], (astra1+astra2+astra3) AS [98],
	(sinopharm1+sinopharm2+sinopharm3) AS [22], (pending1+pending2+pending3) AS [XX]
	FROM raw.[Malaysia Delivery]
),
-- 3. Aggregate the data by month
table_2 AS (
	SELECT [Recipient], [ISO], [CountryID], [Delivery Source], [Delivery Date], [Month], SUM([13]) AS [13], SUM([76]) AS [76], SUM([98]) AS [98], SUM([22]) AS [XX]
	FROM table_1
	GROUP BY [Recipient], [ISO], [CountryID], [Delivery Source], [Delivery Date], [Month]
)
-- 4. Wastage adjustment and unpivot the vaccine code columns into 1 column vaccine id
SELECT [ISO], [Recipient], [CountryID], [Month], [Delivery Date], [Vaccine ID],  CAST(ROUND(([Doses Delivered]*1.10), 0) AS int) AS [Doses Delivered], [Delivery Source], 
'Commercial' AS [Delivery Type]
INTO ref.[Malaysia Delivery]
FROM table_2
UNPIVOT(
	[Doses Delivered]
	FOR [Vaccine ID] IN ([13], [76], [98], [XX])
)u order by [Delivery Date]
