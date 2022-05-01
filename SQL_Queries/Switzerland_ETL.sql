IF OBJECT_ID('ref.[Switzerland Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Switzerland Delivery]
END
-- 1. Convert vaccine names into our preferred vaccine codes
-- 2. We only want Doses Delivered, If we remove the filter numbers will be too large because it would also add on the total number of doses recieved.
;WITH table_1 AS (
	SELECT [vaccine], [Month], [Date], [sumTotal],
	CASE
		WHEN [vaccine] = 'johnson_johnson' THEN '65'
		WHEN [vaccine] = 'kinderimpfstoff_pfizer' THEN '13'
		WHEN [vaccine] = 'pfizer_biontech' THEN '13'
		WHEN vaccine = 'novavax' THEN '112'
		WHEN [vaccine] = 'moderna' THEN '58'
		ELSE NULL END AS [Vaccine ID]
	FROM raw.[Switzerland Delivery]
	WHERE type = 'COVID19VaccDosesDelivered'
),
table_2 AS (
	SELECT [Vaccine ID], [Month], [Date], MAX([sumTotal]) AS [Max Doses]
	FROM table_1
	GROUP BY [Vaccine ID], [Month], [Date]
),
-- 3. Data is cumulative, so we use the lag function to extract monthly totals.
table_3 AS (
	SELECT [Vaccine ID], [Month], [Date], [Max Doses],
	LAG([Max Doses], 1) OVER (PARTITION BY [Vaccine ID] ORDER BY [Vaccine ID], [Date])  AS [Previous]
	FROM table_2
),
table_4 AS (
	SELECT [Vaccine ID], [Month], [Date], [Max Doses],
	CASE WHEN [Previous] IS NULL THEN 0 
	ELSE [Previous] END AS [Previous Month]
	FROM table_3
)
SELECT 'CHE' AS [ISO], 'Switzerland' AS [Recipient], 284 AS [CountryID], [Month], [Date] AS [Delivery Date],
[Vaccine ID], ([Max Doses] - [Previous Month]) AS [Doses Delivered],
'https://opendata.swiss/en/dataset/covid-19-schweiz/resource/d52e637f-8392-4dc1-b210-2f7fa5f6d89f' AS [Delivery Source], 'Commercial' AS [Delivery Type]
INTO ref.[Switzerland Delivery]
FROM table_4
