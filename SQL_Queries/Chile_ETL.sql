IF OBJECT_ID('ref.[Chile Delivery]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[Chile Delivery]
END;

-- From examining the raw data we observe that the date data is reported in long format for each individual day. Where the date is the name of each column
-- Since our goal is to automate this process as much as possible we want to be able to select all future date columns that will eventually be added to the dataset
-- 1. Make a variable called colsUnpivot because we will need to unpivot all the date columns to convert the data into our desired format.
	-- We declare this variable and a variable @chile as nvarchar
DECLARE @colsUnpivot AS NVARCHAR(MAX),
 @chile_query  AS NVARCHAR(MAX)
 DECLARE @Results TABLE (ResultText VARCHAR(500));;

-- 2. Select the columns names to assign to our colsUnpivot variable 
--	 We select the columns from sys.columns where the object is our raw data table and the column name has the substring '20' in it, because only date columns have this substring in this table
--	After we do this the names of all the date columns appear in a column called 'name' in the table sys.columns
--	In short the variable colsUnpivot contains any dates that will be added as columns to this table
SELECT @colsUnpivot
	= STUFF((SELECT ','+QUOTENAME(s.name)
	FROM sys.columns AS s
	WHERE object_id = OBJECT_ID('raw.[Chile Delivery]')
	AND s.name LIKE '%20%'
	for xml path('')), 1, 1, '');

-- Since we set the chile_query as nvarchar we have to put our query in quotes
-- 3. The first order of business is unpivoting all of the dates in the colsUnpivot variable into a column delivery_date
-- 4. convert date format into yyyy-mm-dd
-- 5. get our desired date formats before aggregating any of the data by month
-- 6. the data is cumulative so we need to take the max before lagging and converting the data to monthly totals 
-- 7. Take lags and convert to monthly totals
-- 8. convert to our vaccine manufacturer codes
-- 9. adjust for wastage
-- 10. Execute the stored procedure/variable that we have created
set @chile_query =
'WITH test_table AS (
	select doses_delivered, Type, Dose, delivery_date
	from raw.[Chile Delivery]
	unpivot(
		doses_delivered
		for delivery_date in ('+ @colsUnpivot +')
	) u
),

	test_table2 AS (
	select doses_delivered, Type, Dose, CONVERT(date, delivery_date, 23) AS [Delivery Date]
	from test_table
	WHERE Type <> ''Total''
),

	test_table3 AS (
	SELECT doses_delivered, Type AS [Vaccine ID], Dose,
	DATEADD(day, 1, EOMONTH([Delivery Date], -1)) AS [Delivery Date], CONCAT(FORMAT([Delivery Date], ''MMM''), SPACE(1), DATEPART(year, [Delivery Date])) AS [Month]
	from test_table2
),
	test_table4 AS (
	select [Vaccine ID], [Delivery Date], [Month], Dose, MAX(doses_delivered) AS [Doses Delivered] 
	from test_table3
	GROUP BY [Vaccine ID], [Delivery Date], [Month], Dose
),

	test_table5 AS (
	SELECT [Vaccine ID], [Delivery Date], [Month], Dose,
	([Doses Delivered] - LAG([Doses Delivered],1, 0) OVER (PARTITION BY [Vaccine ID], Dose ORDER BY [Delivery Date])) AS [Doses Delivered]
	FROM test_table4
),

	test_table6 AS (
	SELECT ''CHL'' AS ISO, ''Chile'' AS Recipient, 365 AS [CountryID], Month, [Delivery Date], 
	CASE 
		WHEN [Vaccine ID] = ''Pfizer'' THEN ''13''
		WHEN [Vaccine ID] = ''Sinovac'' THEN ''76''
		WHEN [Vaccine ID] = ''CanSino'' THEN ''87''
		WHEN [Vaccine ID] = ''Astra-Zeneca'' THEN ''98'' END AS [Vaccine ID],
	[Doses Delivered], [Dose],
	''https://github.com/MinCiencia/Datos-COVID19'' AS [Delivery Source], ''Commercial'' AS [Delivery Type]
	FROM test_table5
)

SELECT ISO, Recipient, [CountryID], Month, [Delivery Date], [Vaccine ID], SUM(CAST(ROUND(([Doses Delivered]*1.10), 0) AS int)) AS [Doses Delivered], [Delivery Source], 
[Delivery Type]
INTO ref.[Chile Delivery]
FROM test_table6
GROUP BY ISO, Recipient, [CountryID], Month, [Delivery Date], [Vaccine ID], [Delivery Source], [Delivery Type]
HAVING [Vaccine ID] IS NOT NULL'
exec sp_executesql @chile_query
