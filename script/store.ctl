LOAD DATA
INFILE '../Data/stores.csv'
INTO TABLE Dim_Store
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Store_ID,
    Name, 
    City, 
    Country, 
    ZIP_Code, 
    Latitude, 
    Longitude
)