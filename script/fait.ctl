LOAD DATA
INFILE '../Data/transactions.csv'
INTO TABLE Fait_Transaction
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Product_ID,
    Store_ID,
    Quantity,
    Unit_Price,
    Line_Total,
    Transaction_Type,
    Invoice_Total,
    Date_ID,
    Discount_ID,
    Transactions_ID
)
