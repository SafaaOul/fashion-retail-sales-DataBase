OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Data/date.csv'
INTO TABLE Dim_Date
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
	DateTime "TO_TIMESTAMP(:DateTime, 'YYYY-MM-DD HH24:MI:SS')",  -- Format correct pour un champ TIMESTAMP
	Date_ID,
	Date_only DATE 'YYYY-MM-DD',   	-- Format de date pour Date_Value
	Year,
	Month,
	Day,
	Hour,
	DayOfWeek,
	WeekOfYear
)
