IF OBJECT_ID('ref.[OWID Deliveries]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[OWID Deliveries]
END
-- 1. Convert to our vaccine manufacturer codes
-- 2. Data is cumulative so use LAG function to get values from the previous month. Partitition by the Manufacturer, Country, and ISO
-- 3. Although this source provides data from more countries than the 8 that we filter to include, the countries that were excluded are included in the European Union Data
;WITH table_1 AS (
	SELECT r.[ISO], c.CountryID, c.[GVMM Name] AS Recipient, r.[Month], r.[Delivery Date], r.[Vaccine], 
	CASE
		WHEN r.[Vaccine] = 'Pfizer/BioNTech' THEN '13'
		WHEN r.[Vaccine] = 'Johnson&Johnson' THEN '58'
		WHEN r.[Vaccine] = 'Moderna' THEN '65'
		WHEN r.[Vaccine] = 'Oxford/AstraZeneca' THEN '98'
		WHEN r.[Vaccine] = 'Sinopharm/Beijing' THEN '22'
		WHEN r.[Vaccine] = 'Sputnik V' THEN '227'
		WHEN r.[Vaccine] = 'Sinovac' THEN '76'
		WHEN r.[Vaccine] = 'CanSino' THEN '87'
		WHEN r.[Vaccine] = 'Novavax' THEN '112'
		ELSE 'NULL'
	END AS [Vaccine ID],
		
	r.[Doses Administered], 
	LAG(r.[Doses Administered], 1) OVER (PARTITION BY r.[Vaccine], r.[ISO] ORDER BY r.[ISO], r.[Vaccine], r.[Delivery Date])  AS [Previous Month]
	FROM raw.[OWID Delivery] AS r
	LEFT JOIN ref.[Country Names] AS c ON r.ISO = c.ISO
	WHERE r.[ISO] IN ('MLT', 'UKR', 'URY', 'ARG', 'HKG', 'ZAF', 'NEP', 'KOR')

),
table_2 AS (
	SELECT [ISO], [CountryID], [Recipient], [Month], [Delivery Date], [Vaccine ID], [Doses Administered],
	CASE WHEN [Previous Month] IS NULL THEN 0
	ELSE [Previous Month] END AS [Previous Month]
	FROM table_1
)
-- 4. Subtract the previous month from the current month to get monthly totals and add 10% for wastage.
SELECT [ISO], [Recipient], [CountryID], [Month], [Delivery Date], [Vaccine ID],
ROUND((([Doses Administered] - [Previous Month])*1.10), 0) AS [Doses Delivered],
'https://github.com/owid/covid-19-data/blob/master/public/data/vaccinations/locations-manufacturer.csv' AS [Delivery Source],
'Commercial' AS [Delivery Type]
INTO ref.[OWID Deliveries]
FROM table_2
ORDER BY [ISO], [Vaccine ID], [Delivery Date]






SELECT *
FROM raw.[OWID Delivery]
WHERE ISO = 'KOR'