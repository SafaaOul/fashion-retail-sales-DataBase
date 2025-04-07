OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Data/customers.csv'
INTO TABLE Dim_Customer
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
  Customer_ID,
  City,
  Country,
  Gender,
  Age
)