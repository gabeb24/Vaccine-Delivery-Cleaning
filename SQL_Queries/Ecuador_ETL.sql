IF OBJECT_ID('ref.[Ecuador Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Ecuador Delivery]
END
-- 1. Convert the dates into our prefeered date format as a date variable
-- 2. Conver vaccine manufacturer names to our manufacturer codes
;WITH table_1 AS (
	SELECT 'ECU' AS [ISO], 'Ecuador' AS [Recipient], 367 AS CountryID,
	CASE 
		WHEN arrived_at = 'ene-21' THEN CAST('2021-01-01' AS date)
		WHEN arrived_at = 'feb-21' THEN CAST('2021-02-01' AS date)
		WHEN arrived_at = 'mar-21' THEN CAST('2021-03-01' AS date)
		WHEN arrived_at = 'abr-21' THEN CAST('2021-04-01' AS date)
		WHEN arrived_at = 'may-21' THEN CAST('2021-05-01' AS date)
		WHEN arrived_at = 'jun-21' THEN CAST('2021-06-01' AS date)
		WHEN arrived_at = 'jul-21' THEN CAST('2021-07-01' AS date)
		WHEN arrived_at = 'ago-21' THEN CAST('2021-08-01' AS date)
		WHEN arrived_at = 'sept-21' THEN CAST('2021-09-01' AS date)
		WHEN arrived_at = 'oct-21' THEN CAST('2021-10-01' AS date)
		WHEN arrived_at = 'nov-21' THEN CAST('2021-11-01' AS date)
		WHEN arrived_at = 'dic-21' THEN CAST('2021-12-01' AS date)
		WHEN arrived_at = 'ene-22' THEN CAST('2022-01-01' AS date)
		WHEN arrived_at = 'feb-22' THEN CAST('2022-02-01' AS date)
		WHEN arrived_at = 'mar-22' THEN CAST('2022-03-01' AS date)
		WHEN arrived_at = 'abr-22' THEN CAST('2022-04-01' AS date)
		WHEN arrived_at = 'may-22' THEN CAST('2022-05-01' AS date)
		WHEN arrived_at = 'jun-22' THEN CAST('2022-06-01' AS date)
		WHEN arrived_at = 'jul-22' THEN CAST('2022-07-01' AS date)
		WHEN arrived_at = 'aug-22' THEN CAST('2022-08-01' AS date)
		WHEN arrived_at = 'sept-22' THEN CAST('2022-09-01' AS date)
		WHEN arrived_at = 'oct-22' THEN CAST('2022-10-01' AS date)
		WHEN arrived_at = 'nov-22' THEN CAST('2022-11-01' AS date)
		WHEN arrived_at = 'dic-22' THEN CAST('2022-12-01' AS date)
	END as [Delivery Date],
	CASE 
		WHEN vaccine = 'Oxford/AstraZeneca' THEN '98'
		WHEN vaccine = 'Pfizer/BioNTech' THEN '13'
		WHEN vaccine = 'CanSino' THEN '87'
		WHEN vaccine = 'Sinovac' THEN '76'
	END AS [Vaccine ID],
	doses AS [Doses Delivered],
	'https://raw.githubusercontent.com/andrab/ecuacovid/master/datos_crudos/vacunas/arribos_fabricantes_por_mes.csv' AS [Delivery Source],
	'Commercial' AS [Delivery Type]
	FROM raw.[Ecuador Delivery]
)
-- 3. Finally create the month variable using our preffered date format.
SELECT ISO, Recipient, CountryID, CONCAT(FORMAT([Delivery Date], 'MMM'), SPACE(1), DATEPART(year, [Delivery Date])) AS [Month], [Delivery Date],
[Vaccine ID], [Doses Delivered], [Delivery Source], [Delivery Type]
INTO ref.[Ecuador Delivery]
FROM table_1