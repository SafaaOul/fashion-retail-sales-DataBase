OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Data/stores.csv'
INTO TABLE Dim_Store
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Store_ID,
    Name, 
    City, 
    Country, 
    ZIP_Code, 
    Latitude "TO_NUMBER(:Latitude, '999.999999', 'NLS_NUMERIC_CHARACTERS=''.,''')", 
    Longitude "TO_NUMBER(:Longitude, '999.999999', 'NLS_NUMERIC_CHARACTERS=''.,''')"
)