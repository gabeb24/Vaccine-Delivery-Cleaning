IF OBJECT_ID('ref.[EU Delivery_2]') IS NOT NULL 
BEGIN 
	DROP TABLE ref.[EU Delivery_2]
END
 

-- 1. Examining the data, the primary structural change that we must implement in order to achieve or desired database structure is converting the dates from yyyy-ww structure to yyyy-mm-dd.
--		Unfortunately SQL does not have a built in functionality to convert yyyy-ww to alternative date formats. Inititally I took the substring of both the year and week, separated them into
--		different columns and tried to find a function that would convert a week number to 
-- 2. We need to standardize the vaccine IDs into our preferred format
;WITH table_temp AS (
	SELECT [ISO], [NumberDosesReceived],
	FirstDose, SecondDose, DoseAdditional1, FirstDose + SecondDose + DoseAdditional1 AS Total,
	[TargetGroup], 'https://qap.ecdc.europa.eu/public/extensions/COVID-19/vaccine-tracker.html#distribution-tab' AS [Delivery Source],
	CASE 
		WHEN [YearWeekISO] = '2020-W50' THEN '2020-12-01'
		WHEN [YearWeekISO] = '2020-W51' THEN '2020-12-01'
		WHEN [YearWeekISO] = '2020-W52' THEN '2020-12-01'
		WHEN [YearWeekISO] = '2020-W53' THEN '2020-12-01'
		WHEN [YearWeekISO] = '2021-W01' THEN '2021-01-01'
		WHEN [YearWeekISO] = '2021-W02' THEN '2021-01-01'
		WHEN [YearWeekISO] = '2021-W03' THEN '2021-01-01'
		WHEN [YearWeekISO] = '2021-W04' THEN '2021-01-01'

		WHEN [YearWeekISO] = '2021-W05' THEN '2021-02-01'
		WHEN [YearWeekISO] = '2021-W06' THEN '2021-02-01'
		WHEN [YearWeekISO] = '2021-W07' THEN '2021-02-01'
		WHEN [YearWeekISO] = '2021-W08' THEN '2021-02-01'

		WHEN [YearWeekISO] = '2021-W09' THEN '2021-03-01'
		WHEN [YearWeekISO] = '2021-W10' THEN '2021-03-01'
		WHEN [YearWeekISO] = '2021-W11' THEN '2021-03-01'
		WHEN [YearWeekISO] = '2021-W12' THEN '2021-03-01'

		WHEN [YearWeekISO] = '2021-W13' THEN '2021-04-01'
		WHEN [YearWeekISO] = '2021-W14' THEN '2021-04-01'
		WHEN [YearWeekISO] = '2021-W15' THEN '2021-04-01'
		WHEN [YearWeekISO] = '2021-W16' THEN '2021-04-01'

		WHEN [YearWeekISO] = '2021-W17' THEN '2021-05-01'
		WHEN [YearWeekISO] = '2021-W18' THEN '2021-05-01'
		WHEN [YearWeekISO] = '2021-W19' THEN '2021-05-01'
		WHEN [YearWeekISO] = '2021-W20' THEN '2021-05-01'
		WHEN [YearWeekISO] = '2021-W21' THEN '2021-05-01'

		WHEN [YearWeekISO] = '2021-W22' THEN '2021-06-01'
		WHEN [YearWeekISO] = '2021-W23' THEN '2021-06-01'
		WHEN [YearWeekISO] = '2021-W24' THEN '2021-06-01'
		WHEN [YearWeekISO] = '2021-W25' THEN '2021-06-01'

		WHEN [YearWeekISO] = '2021-W26' THEN '2021-07-01'
		WHEN [YearWeekISO] = '2021-W27' THEN '2021-07-01'
		WHEN [YearWeekISO] = '2021-W28' THEN '2021-07-01'
		WHEN [YearWeekISO] = '2021-W29' THEN '2021-07-01'

		WHEN [YearWeekISO] = '2021-W30' THEN '2021-08-01'
		WHEN [YearWeekISO] = '2021-W31' THEN '2021-08-01'
		WHEN [YearWeekISO] = '2021-W32' THEN '2021-08-01'
		WHEN [YearWeekISO] = '2021-W33' THEN '2021-08-01'
		WHEN [YearWeekISO] = '2021-W34' THEN '2021-08-01'

		WHEN [YearWeekISO] = '2021-W35' THEN '2021-09-01'
		WHEN [YearWeekISO] = '2021-W36' THEN '2021-09-01'
		WHEN [YearWeekISO] = '2021-W37' THEN '2021-09-01'
		WHEN [YearWeekISO] = '2021-W38' THEN '2021-09-01'

		WHEN [YearWeekISO] = '2021-W39' THEN '2021-10-01'
		WHEN [YearWeekISO] = '2021-W40' THEN '2021-10-01'
		WHEN [YearWeekISO] = '2021-W41' THEN '2021-10-01'
		WHEN [YearWeekISO] = '2021-W42' THEN '2021-10-01'
		WHEN [YearWeekISO] = '2021-W43' THEN '2021-10-01'

		WHEN [YearWeekISO] = '2021-W44' THEN '2021-11-01'
		WHEN [YearWeekISO] = '2021-W45' THEN '2021-11-01'
		WHEN [YearWeekISO] = '2021-W46' THEN '2021-11-01'
		WHEN [YearWeekISO] = '2021-W47' THEN '2021-11-01'

		WHEN [YearWeekISO] = '2021-W48' THEN '2021-12-01'
		WHEN [YearWeekISO] = '2021-W49' THEN '2021-12-01'
		WHEN [YearWeekISO] = '2021-W50' THEN '2021-12-01'
		WHEN [YearWeekISO] = '2021-W51' THEN '2021-12-01'
		WHEN [YearWeekISO] = '2021-W52' THEN '2021-12-01'
		WHEN [YearWeekISO] = '2021-W53' THEN '2021-12-01'

		WHEN [YearWeekISO] = '2022-W01' THEN '2022-01-01'
		WHEN [YearWeekISO] = '2022-W02' THEN '2022-01-01'
		WHEN [YearWeekISO] = '2022-W03' THEN '2022-01-01'
		WHEN [YearWeekISO] = '2022-W04' THEN '2022-01-01'

		WHEN [YearWeekISO] = '2022-W05' THEN '2022-02-01'
		WHEN [YearWeekISO] = '2022-W06' THEN '2022-02-01'
		WHEN [YearWeekISO] = '2022-W07' THEN '2022-02-01'
		WHEN [YearWeekISO] = '2022-W08' THEN '2022-02-01'

		WHEN [YearWeekISO] = '2022-W09' THEN '2022-03-01'
		WHEN [YearWeekISO] = '2022-W10' THEN '2022-03-01'
		WHEN [YearWeekISO] = '2022-W11' THEN '2022-03-01'
		WHEN [YearWeekISO] = '2022-W12' THEN '2022-03-01'

		WHEN [YearWeekISO] = '2022-W13' THEN '2022-04-01'
		WHEN [YearWeekISO] = '2022-W14' THEN '2022-04-01'
		WHEN [YearWeekISO] = '2022-W15' THEN '2022-04-01'
		WHEN [YearWeekISO] = '2022-W16' THEN '2022-04-01'
		WHEN [YearWeekISO] = '2022-W17' THEN '2022-04-01'

		WHEN [YearWeekISO] = '2022-W18' THEN '2022-05-01'
		WHEN [YearWeekISO] = '2022-W19' THEN '2022-05-01'
		WHEN [YearWeekISO] = '2022-W20' THEN '2022-05-01'
		WHEN [YearWeekISO] = '2022-W21' THEN '2022-05-01'

		WHEN [YearWeekISO] = '2022-W22' THEN '2022-06-01'
		WHEN [YearWeekISO] = '2022-W23' THEN '2022-06-01'
		WHEN [YearWeekISO] = '2022-W24' THEN '2022-06-01'
		WHEN [YearWeekISO] = '2022-W25' THEN '2022-06-01'

		WHEN [YearWeekISO] = '2022-W26' THEN '2022-07-01'
		WHEN [YearWeekISO] = '2022-W27' THEN '2022-07-01'
		WHEN [YearWeekISO] = '2022-W28' THEN '2022-07-01'
		WHEN [YearWeekISO] = '2022-W29' THEN '2022-07-01'
		WHEN [YearWeekISO] = '2022-W30' THEN '2022-07-01'

		WHEN [YearWeekISO] = '2022-W31' THEN '2022-08-01'
		WHEN [YearWeekISO] = '2022-W32' THEN '2022-08-01'
		WHEN [YearWeekISO] = '2022-W33' THEN '2022-08-01'
		WHEN [YearWeekISO] = '2022-W34' THEN '2022-08-01'

		WHEN [YearWeekISO] = '2022-W35' THEN '2022-09-01'
		WHEN [YearWeekISO] = '2022-W36' THEN '2022-09-01'
		WHEN [YearWeekISO] = '2022-W37' THEN '2022-09-01'
		WHEN [YearWeekISO] = '2022-W38' THEN '2022-09-01'
		WHEN [YearWeekISO] = '2022-W39' THEN '2022-09-01'

		WHEN [YearWeekISO] = '2022-W40' THEN '2022-10-01'
		WHEN [YearWeekISO] = '2022-W41' THEN '2022-10-01'
		WHEN [YearWeekISO] = '2022-W42' THEN '2022-10-01'
		WHEN [YearWeekISO] = '2022-W43' THEN '2022-10-01'

		WHEN [YearWeekISO] = '2022-W44' THEN '2022-11-01'
		WHEN [YearWeekISO] = '2022-W45' THEN '2022-11-01'
		WHEN [YearWeekISO] = '2022-W46' THEN '2022-11-01'
		WHEN [YearWeekISO] = '2022-W47' THEN '2022-11-01'

		WHEN [YearWeekISO] = '2022-W48' THEN '2022-12-01'
		WHEN [YearWeekISO] = '2022-W49' THEN '2022-12-01'
		WHEN [YearWeekISO] = '2022-W50' THEN '2022-12-01'
		WHEN [YearWeekISO] = '2022-W51' THEN '2022-12-01'
		WHEN [YearWeekISO] = '2022-W52' THEN '2022-12-01'

	ELSE '2001-01-01' END AS [str_date], 


	CASE
		WHEN [Vaccine] = 'MOD' THEN '65'
		WHEN [Vaccine] = 'JANSS' THEN '58'
		WHEN [Vaccine] = 'AZ' THEN '98'
		WHEN [Vaccine] = 'COM' THEN '13'
		WHEN [Vaccine] = 'BECNBG' THEN '22'
		WHEN [Vaccine] = 'SPU' THEN '227'
		WHEN [Vaccine] = 'NVXD' THEN '112'
		WHEN [Vaccine] = 'BHACOV' THEN '148'
		WHEN [Vaccine] = 'SIN' THEN '76'
		WHEN [Vaccine] = 'UNK' THEN 'XX'
	ELSE 'NULL' END AS [Vaccine ID]
	FROM [raw].[EU Delivery]
	WHERE [TargetGroup] = 'ALL'
),
--- For denmark only
-- 3. Examining the data we can see that doses in Denmark are no longer reported in the 'NumberDosesReceived' column  after 2021-W33, but they are reported using the 'FirstDose',
--	'SecondDose' and 'DoseAdditional1 columns'
--	This is the only Country in the dataset which follows this pattern so we must separately calculate doses delivered in Denmark.
temp_dnk AS (
	SELECT t.[ISO], t.[Delivery Source], CAST(t.[str_date] AS date) AS [Delivery Date], t.[Vaccine ID], SUM([Total]) AS [Doses Delivered]
	FROM table_temp AS t
	WHERE ISO = 'DNK'
	GROUP BY t.[ISO], CAST([str_date] AS date), t.[Vaccine ID], t.[Delivery Source]
),

--- not for denmark!
-- 4. Calculate the number of doses delivered by each month for every country except Europe.
temp_table AS (
	SELECT t.[ISO], t.[Delivery Source], CAST(t.[str_date] AS date) AS [Delivery Date], t.[Vaccine ID], SUM([NumberDosesReceived]) AS [Doses Delivered]
	FROM table_temp AS t
	WHERE ISO != 'DNK'
	GROUP BY t.[ISO], CAST([str_date] AS date), t.[Vaccine ID], t.[Delivery Source]
),
-- 5. Union Denmark and all other countries
union_dnk AS (
	SELECT * FROM temp_table
	UNION SELECT * FROM temp_dnk
)
-- 6. get our desired date format.
SELECT t2.[ISO], c.[GVMM Name] AS [Recipient], c.[CountryID],
CONCAT(FORMAT(t2.[Delivery Date], 'MMM'), SPACE(1), DATEPART(year, t2.[Delivery Date])) AS [Month],
t2.[Delivery Date], t2.[Vaccine ID], 
CASE 
	WHEN [Doses Delivered] IS NULL
	THEN 0
	ELSE [Doses Delivered] END AS [Doses Delivered], 
t2.[Delivery Source], 'Commercial' AS [Delivery Type]
INTO ref.[EU Delivery_2]
FROM union_dnk AS t2
LEFT JOIN ref.[Country Names] AS c
ON t2.[ISO] = c.[ISO]



SELECT *
FROM raw.[EU Delivery]
WHERE ISO = 'DNK'