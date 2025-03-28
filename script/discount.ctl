LOAD DATA
INFILE '../Data/discounts.csv'
INTO TABLE Dim_Discount
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Date_start DATE 'YYYY-MM-DD',
	Date_end DATE 'YYYY-MM-DD',
	Percent_discount,
	Discount_ID
)