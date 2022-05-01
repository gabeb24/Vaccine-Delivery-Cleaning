IF OBJECT_ID('ref.[Colombia Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Colombia Delivery]
END
-- 1. convert the source's string date to a date so we can convert it to our own date variables
-- 2. get our desired vaccine codes
;WITH table_1 AS (
	SELECT CAST([vaccination_date] as DATE) as [vaccination_date], 
		CASE WHEN vaccine_manufacturer = 'PFIZER' THEN '13'
			 WHEN vaccine_manufacturer = 'MODERNA' THEN '65' 
			 WHEN vaccine_manufacturer IN('ASTRAZENECA', 'AZTRAZENECA') THEN '98'
			 WHEN vaccine_manufacturer = 'JANSSEN' THEN '58'
			 WHEN vaccine_manufacturer = 'SINOVAC' THEN '76'
			 END AS [Vaccine ID], [Quantity] AS [Doses Delivered]
	FROM raw.[Colombia Delivery]
),
-- 3. get our preffered date conversions
table_2 AS (
	SELECT DATEADD(day, 1, EOMONTH([vaccination_date], -1)) AS [Delivery Date], CONCAT(FORMAT([vaccination_date], 'MMM'), SPACE(1), DATEPART(year, [vaccination_date])) AS [Month],
	[Vaccine ID], [Doses Delivered]
	FROM table_1
),
-- 4. Just adding other columns later, so we don't need to group by all the constant variables
-- 5. Account for wastage since it is doses administered
table_3 AS (
SELECT [Delivery Date], [Month], [Vaccine ID], CONVERT(int,ROUND(SUM([Doses Delivered]*1.10),0)) AS [Doses Delivered]
FROM table_2
GROUP BY [Delivery Date], [Month], [Vaccine ID]
)
SELECT 'COL' AS [ISO], 'Colombia' AS [Recipient], 357 AS [CountryID],
[Month], [Delivery Date], [Vaccine ID], [Doses Delivered], 'https://www.datos.gov.co/Salud-y-Protecci-n-Social/Asignaci-n-de-dosis-de-vacuna-contra-COVID-19/sdvb-4x4j'
AS [Delivery Source], 'Commercial' AS [Delivery Type]
INTO ref.[Colombia Delivery]
FROM table_3