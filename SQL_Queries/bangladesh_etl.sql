IF OBJECT_ID('ref.[Bangladesh Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Bangladesh Delivery]
END
-- 1. Fill NULL values with 0 to avoid errors from adding NULL
;WITH temp_table AS (
	SELECT [Month], [Date], [AstraZeneca First], [Pfizer First], [Sinopharm First], [Moderna First], [Sinovac First], [Janssen First], 
		CASE WHEN [AstraZeneca Second] IS NULL THEN 0 ELSE [AstraZeneca Second] END AS [AstraZeneca Second],
		CASE WHEN [Pfizer Second] IS NULL THEN 0 ELSE [Pfizer Second] END AS [Pfizer Second],
		CASE WHEN [Sinopharm Second] IS NULL THEN 0 ELSE [Sinopharm Second] END AS [Sinopharm Second],
		CASE WHEN [Moderna Second] IS NULL THEN 0 ELSE [Moderna Second] END AS [Moderna Second],
		CASE WHEN [Janssen Second] IS NULL THEN 0 ELSE [Janssen Second] END AS [Janssen Second],
		CASE WHEN [Sinovac Second] IS NULL THEN 0 ELSE [Sinovac Second] END AS [Sinovac Second],
		CASE WHEN [AstraZeneca Third] IS NULL THEN 0 ELSE [AstraZeneca Third] END AS [AstraZeneca Third],
		CASE WHEN [Pfizer Third] IS NULL THEN 0 ELSE [Pfizer Third] END AS [Pfizer Third],
		CASE WHEN [Sinopharm Third] IS NULL THEN 0 ELSE [Sinopharm Third] END AS [Sinopharm Third],
		CASE WHEN [Moderna Third] IS NULL THEN 0 ELSE [Moderna Third] END AS [Moderna Third],
		CASE WHEN [Sinovac Third] IS NULL THEN 0 ELSE [Sinovac Third] END AS [Sinovac Third],
		CASE WHEN [Janssen Third] IS NULL THEN 0 ELSE [Janssen Third] END AS [Janssen Third]
	FROM raw.[Bangladesh Delivery]
),
-- 2. Add First second and third doses of each manufacturer and convert to our preferred vaccine codes
temp_table2 AS (
	SELECT [Month], [Date] AS [Delivery Date], ([AstraZeneca First] + [AstraZeneca Second] + [AstraZeneca Third]) AS [98],
	([Pfizer First] + [Pfizer Second] + [Pfizer Third]) AS [13],
	([Sinopharm First] + [Sinopharm Second] + [Sinopharm Third]) AS [22],
	([Moderna First] + [Moderna Second] + [Moderna Third]) AS [65],
	([Sinovac First] + [Sinovac Second] + [Sinovac Third]) AS [76], 
	([Janssen First] + [Janssen Second] + [Janssen Third]) AS [58]
	FROM temp_table
	WHERE [Date] IS NOT NULL
)
-- 3. Unpivot the manufacturer columns and apply a 10% wastage adjustment to obtain the number of doses delivered
SELECT 'BGD' AS [ISO], 'Bangladesh' AS [Recipient], 274 AS [CountryID], [Month], [Delivery Date], [Vaccine ID], CAST(ROUND(([Doses Delivered]*1.10), 0) AS int) AS [Doses Delivered],
'http://103.247.238.92/webportal/pages/covid19-vaccination-update.php#' AS [Delivery Source],
'Commercial' AS [Delivery Type]
FROM temp_table2
UNPIVOT (
	[Doses Delivered]
	FOR [Vaccine ID] in ([98], [13], [65], [22], [76], [58])
) u;
