-- The japan table follows a slightly different pattern because the structure of of the raw data for the first & second dose were significantly different from the third dose
-- 1. Convert null values to 0 to avoid errors when adding columns
WITH table_1 AS (
	SELECT [Month], [Delivery Date], pfizer_first_1, moderna_first_1, az_first_1, pfizer_second_1, moderna_second_1, az_second_1,
		CASE WHEN pfizer_first_2 IS NULL then 0 ELSE pfizer_first_2 END AS pfizer_first_2,
		CASE WHEN pfizer_second_2 IS NULL then 0 ELSE pfizer_second_2 END AS pfizer_second_2,
		CASE WHEN moderna_first_2 IS NULL then 0 ELSE moderna_first_2 END AS moderna_first_2,
		CASE WHEN moderna_second_2 IS NULL then 0 ELSE moderna_second_2 END AS moderna_second_2
	FROM raw.japan_first_second
	WHERE [Month] IS NOT NULL
-- 2. Join the first & second dose table with the third dose table by the date and replace null with 0 in the third dose table
),
table_2 AS (
	SELECT t.[Month], t.[Delivery Date], (t.pfizer_first_1+t.pfizer_first_2+t.pfizer_second_1+t.pfizer_second_2) AS [Pfizer],
	(t.moderna_first_1+t.moderna_first_2+t.moderna_second_1+t.moderna_second_2) AS [Moderna],
	(t.az_first_1+t.az_second_1) AS [AstraZeneca],
		CASE WHEN j.Pfizer_third IS NULL then 0 ELSE j.Pfizer_third END as pfizer_third,
		CASE WHEN j.Moderna_Third IS NULL then 0 ELSE j.Moderna_Third END AS moderna_third
	FROM table_1 AS t
	LEFT OUTER JOIN raw.japan_third_dose AS j ON j.[Delivery Date] = t.[Delivery Date]
	---ORDER BY [Delivery Date]
),
-- 2. Add the add the 1st and 2nd dose tables with the third dose table and rename the output columns using our manufacturer codes
table_3 AS (
	SELECT [Month], [Delivery Date], Pfizer+pfizer_third AS [13], Moderna + moderna_third AS [65], [AstraZeneca] AS [98]
	FROM table_2
)
-- 3. Make wastage adjustment and unpivot the manufacturer codes into 1 column.
SELECT 'JPN' AS [ISO], 'Japan' AS [Recipient], 398 AS [CountryID], [Month], [Delivery Date], [Vaccine ID], 
CAST(ROUND(([Doses Delivered]*1.10), 0) AS int) AS [Doses Delivered],
'https://www.kantei.go.jp/jp/headline/kansensho/vaccine.html' AS [Delivery Source], 'Commercial' AS [Delivery Type]
FROM table_3
UNPIVOT(
	[Doses Delivered]
	FOR [Vaccine ID] IN ([13], [65], [98])
)u ORDER BY [Delivery Date]