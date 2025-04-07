OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Data/transactions.csv'
INTO TABLE Fait_Transaction
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Product_ID,
    Store_ID,
    Customer_ID,
    Quantity,
    Unit_Price "TO_NUMBER(:Unit_Price, '9999.99', 'NLS_NUMERIC_CHARACTERS=''.,''')",
    Line_Total "TO_NUMBER(:Line_Total, '9999.99', 'NLS_NUMERIC_CHARACTERS=''.,''')",
    Transaction_Type,
    Date_ID,
    Discount_ID,
    Transactions_ID
)