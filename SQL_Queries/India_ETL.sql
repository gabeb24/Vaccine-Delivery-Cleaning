IF OBJECT_ID('ref.[India Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[India Delivery]
END

-- 1. data is cumulative, so ge the maximum amount of doses delivered each month and convert to BIGINT
-- 2. Since we want monthly totals use the lag function to get the numbers from the previous month.
-- 3. Convert to our preferred vaccine IDs 
;WITH table_output AS (
	SELECT 'IND' AS [ISO], [str_date], 'India' AS [Recipient], 389 AS [CountryID], 'https://data.covid19india.org/' AS [Delivery Source],
	(MAX(CONVERT(BIGINT, [Covaxin (Doses Administered)])) - 
	 LAG(MAX(CONVERT(BIGINT, [Covaxin (Doses Administered)])), 1, 0) OVER (ORDER BY [str_date])) AS [148], 
	 (MAX(CONVERT(BIGINT, [CoviShield (Doses Administered)])) -
	 LAG(MAX(CONVERT(BIGINT, [CoviShield (Doses Administered)])), 1, 0) OVER (ORDER BY [str_date])) AS [98-1],
	 (MAX(CONVERT(BIGINT, [Sputnik V (Doses Administered)])) - 
	 LAG(MAX(CONVERT(BIGINT, [Sputnik V (Doses Administered)])), 1, 0) OVER (ORDER BY [str_date])) AS [227]

-- 4. Use subquery to create better date variable to LAG over
	FROM
	(
-- 5. The format of the source's data is YYYY-DD-MM until the 13th of each month before it converts to YYYY-MM-DD so we need to convert these for LAG function to be accurate.
		SELECT [Covaxin (Doses Administered)], [CoviShield (Doses Administered)], [Sputnik V (Doses Administered)], ---[XX],
		---February
		(CASE 
			WHEN [Updated On] IN ('2021-01-02', '2021-02-02', '2021-03-02', '2021-04-02', '2021-05-02', '2021-06-02', '2021-07-02', '2021-08-02', '2021-09-02',
			'2021-10-02', '2021-11-02', '2021-12-02') THEN '2021-02-01'
			---March
			WHEN [Updated On] IN ('2021-01-03', '2021-02-03', '2021-03-03', '2021-04-03', '2021-05-03', '2021-06-03', '2021-07-03', '2021-08-03', '2021-09-03',
			'2021-10-03', '2021-11-03', '2021-12-03') THEN '2021-03-01'
			---April
			WHEN [Updated On] IN ('2021-01-04', '2021-02-04', '2021-03-04', '2021-04-04', '2021-05-04', '2021-06-04', '2021-07-04', '2021-08-04', '2021-09-04',
			'2021-10-04', '2021-11-04', '2021-12-04') THEN '2021-04-01'
			---May
			WHEN [Updated On] IN ('2021-01-05', '2021-02-05', '2021-03-05', '2021-04-05', '2021-05-05', '2021-06-05', '2021-07-05', '2021-08-05', '2021-09-05',
			'2021-10-05', '2021-11-05', '2021-12-05') THEN '2021-05-01'
			---June
			WHEN [Updated On] IN ('2021-01-06', '2021-02-06', '2021-03-06', '2021-04-06', '2021-05-06', '2021-06-06', '2021-07-06', '2021-08-06', '2021-09-06',
			'2021-10-06', '2021-11-06', '2021-12-06') THEN '2021-06-01'
			---July
			WHEN [Updated On] IN ('2021-01-07', '2021-02-07', '2021-03-07',  '2021-04-07', '2021-05-07', '2021-06-07', '2021-07-07', '2021-08-07', '2021-09-07',
			'2021-10-07', '2021-11-07', '2021-12-07') THEN '2021-07-01'
			---August
			WHEN [Updated On] IN ('2021-01-08', '2021-02-08', '2021-03-08', '2021-04-08', '2021-05-08', '2021-06-08', '2021-07-08', '2021-08-08', '2021-09-08',
			 '2021-10-08', '2021-11-08', '2021-12-08') THEN '2021-08-01'
			---September
			WHEN [Updated On] IN ('2021-01-09', '2021-02-09', '2021-03-09', '2021-04-09', '2021-05-09', '2021-06-09', '2021-07-09', '2021-08-09', '2021-09-09',
			'2021-10-09', '2021-11-09', '2021-12-09') THEN '2021-09-01'
			---October
			WHEN [Updated On] IN ('2021-01-10','2021-02-10', '2021-03-10', '2021-04-10', '2021-05-10', '2021-06-10', '2021-07-10', '2021-08-10', '2021-09-10', '2021-10-10', '2021-11-10',
			'2021-12-10') THEN '2021-10-01'
			---November
			WHEN [Updated On] IN ('2021-01-11','2021-02-11', '2021-03-11', '2021-04-11', '2021-05-11', '2021-06-11', '2021-07-11', '2021-08-11', '2021-09-11', '2021-10-11', '2021-11-11',
			'2021-12-11') THEN '2021-11-01'
			---December
			WHEN [Updated On] IN ('2021-01-12','2021-02-12', '2021-03-12', '2021-04-12', '2021-05-12', '2021-06-12', '2021-07-12', '2021-08-12', '2021-09-12', '2021-10-12', '2021-11-12',
			'2021-12-12') THEN '2021-12-01'
		ELSE [Updated On full month start date] END) AS [str_date]
			FROM raw.[India Delivery]
			WHERE State = 'India'
	)d
	GROUP BY [str_date]
),
-- 6.Convert our string date column to a date and unpivot the vaccine manufacturers into a single column vaccine id.
table_output2 AS (
	SELECT ISO, Recipient, CountryID, [Delivery Source], [Doses Delivered], [Vaccine ID], CAST([str_date] AS date) AS [Delivery Date]
	FROM table_output --- select all from the temporary table
	UNPIVOT 
	([Doses Delivered] 
		FOR [Vaccine ID] in ([148], [98-1], [227])
	) u
)
-- 7.Get our preferred format of the month column
-- 8.Since the data is 'Administered' we apply a 10% wastage adjustment to obtain the number of doses delivered
SELECT t.[ISO], t.[Recipient], t.[CountryID], CONCAT(FORMAT(t.[Delivery Date], 'MMM'), SPACE(1), DATEPART(year, t.[Delivery Date])) AS [Month],
t.[Delivery Date] AS [Delivery Date],
t.[Vaccine ID], CAST(ROUND((t.[Doses Delivered]*1.10), 0) AS int) AS [Doses Delivered],
t.[Delivery Source], 'Commercial' AS [Delivery Type]
INTO ref.[India Delivery]
FROM table_output2 AS t