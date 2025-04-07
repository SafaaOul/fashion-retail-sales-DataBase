OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Data/products.csv'
INTO TABLE Dim_Product
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Product_ID,
    Category,
    Sub_Category,
    Description,
    Sizes,
    Production_Cost "TO_NUMBER(:Production_Cost, '999.99', 'NLS_NUMERIC_CHARACTERS=''.,''')"
)