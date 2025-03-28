LOAD DATA
INFILE '../Data/products.csv'
INTO TABLE Dim_Product
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Product_ID,
    Category,
    Sub_Category,
    Description,
    Sizes,
    Production_Cost
)