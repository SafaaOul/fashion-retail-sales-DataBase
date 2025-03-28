COPY Dim_Discount (Date_start, Date_end, Percent_discount, Discount_ID)
FROM 'chemin/du/fichier/discounts.csv'
DELIMITER ','
CSV HEADER;

COPY Dim_Product (Product_ID, Category, Sub_Category, Description, Sizes, Production_Cost)
FROM 'chemin/du/fichier/products.csv'
DELIMITER ','
CSV HEADER;

COPY Dim_Store (Store_ID, Name, City, Country, ZIP_Code, Latitude, Longitude)
FROM 'chemin/du/fichier/stores.csv'
DELIMITER ','
CSV HEADER;

COPY Dim_Date (DateTime, Date_ID, Date, Year, Month, Day, Hour, DayOfWeek, WeekOfYear)
FROM 'chemin/du/fichier/date.csv'
DELIMITER ','
CSV HEADER;

COPY Fait_Transaction (Product_ID, Store_ID, Quantity, Unit_Price, Line_Total, Transaction_Type, Invoice_Total, Date_ID, Discount_ID, Transactions_ID)
FROM 'chemin/du/fichier/transactions.csv'
DELIMITER ','
CSV HEADER;

-- Exécutable avec la commande \i chemin/du/fichier/insertion.sql en psql