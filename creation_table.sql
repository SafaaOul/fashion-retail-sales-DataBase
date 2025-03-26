DROP TABLE IF EXISTS Dim_Discount CASCADE;
DROP TABLE IF EXISTS Dim_Product CASCADE;
DROP TABLE IF EXISTS Dim_Store CASCADE;
DROP TABLE IF EXISTS Dim_Date CASCADE;
DROP TABLE IF EXISTS Fait_Transaction CASCADE;

CREATE TABLE Dim_Discount (
    Discount_ID INT,
    Percent_discount DECIMAL(5,2) NOT NULL CHECK (Percent_discount BETWEEN 0 AND 100),
    Date_start DATE NOT NULL,  
    Date_end DATE NOT NULL, 

    CONSTRAINT PK_Discount PRIMARY KEY (Discount_ID),
    CONSTRAINT valid_dates CHECK (Date_end >= Date_start)
);

CREATE TABLE Dim_Product (
    Product_ID INT,
    Category VARCHAR(20) NOT NULL,
    Sub_Category VARCHAR(50),
    Description VARCHAR(100),          
    Sizes VARCHAR(30),
    Production_cost DECIMAL(5,2),

    CONSTRAINT PK_Product PRIMARY KEY (Product_ID),
    CONSTRAINT valid_production_cost CHECK (Production_cost > 0)
);

CREATE TABLE Dim_Store (
    Store_ID INT,
    Name VARCHAR(30) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Country VARCHAR(20) NOT NULL,
    Zip_code VARCHAR(20) NOT NULL,
    Latitude DECIMAL(7,4),
    Longitude DECIMAL(7,4),

    CONSTRAINT PK_Store PRIMARY KEY (Store_ID)
);

CREATE TABLE Dim_Date (
    Date_ID INT,
    DateTime TIMESTAMP,     
    Date DATE,             
    Year INT,
    Month INT,
    Day INT,
    Hour INT,
    DayOfWeek INT,
    WeekOfYear INT,

    CONSTRAINT PK_Date PRIMARY KEY (Date_ID)
);

CREATE TABLE Fait_Transaction (
    Transactions_ID INT,
    Date_ID INT,
    Discount_ID INT,
    Product_ID INT,
    Store_ID INT,
    Quantity INT,
    Unit_Price DECIMAL(10, 2),
    Line_Total DECIMAL(10, 2),
    Transaction_Type VARCHAR(50),
    Invoice_Total DECIMAL(10, 2),

    CONSTRAINT PK_Transactions PRIMARY KEY (Transactions_ID),

    CONSTRAINT FK_Transactions_Date FOREIGN KEY (Date_ID)
        REFERENCES Dim_Date(Date_ID),

    CONSTRAINT FK_Transactions_Discount FOREIGN KEY (Discount_ID)
        REFERENCES Dim_Discount(Discount_ID),

    CONSTRAINT FK_Transactions_Product FOREIGN KEY (Product_ID)
        REFERENCES Dim_Product(Product_ID)

 --   CONSTRAINT FK_Transactions_Store FOREIGN KEY (Store_ID)
 --       REFERENCES Dim_Store(Store_ID)
);

-- Exécutable avec la commande \i chemin/du/fichier/creation_table.sql