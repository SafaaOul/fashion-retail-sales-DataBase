-- Supprime les tables si elles existent (Oracle 11g ne supporte pas DROP TABLE IF EXISTS)

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Dim_Customer CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Dim_Date CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Dim_Discount CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Dim_Product CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Dim_Store CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Fait_Transaction CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Table  Dim_Customer
CREATE TABLE Dim_Customer (
    Customer_ID NUMBER PRIMARY KEY,
    Country VARCHAR2(20),
    City VARCHAR2(50),
    Gender VARCHAR2(1),
    Age NUMBER(2),
    CONSTRAINT valid_age CHECK (Age BETWEEN 0 AND 100)
);

-- Table Dim_Date
CREATE TABLE Dim_Date (
    Date_ID NUMBER PRIMARY KEY,
    DateTime TIMESTAMP,
    Date_only DATE,
    Year NUMBER(4),
    Month NUMBER(2),
    Day NUMBER(2),
    Hour NUMBER(2),
    DayOfWeek NUMBER(1),
    WeekOfYear NUMBER(2)
);

-- Table Dim_Discount
CREATE TABLE Dim_Discount (
    Discount_ID NUMBER PRIMARY KEY,
    Percent_discount NUMBER(4,2),
    Date_start DATE NOT NULL,
    Date_end DATE NOT NULL,
    CONSTRAINT valid_dates CHECK (Date_end >= Date_start)
);

-- Table Dim_Product
CREATE TABLE Dim_Product (
    Product_ID NUMBER PRIMARY KEY,
    Category VARCHAR2(20) NOT NULL,
    Sub_Category VARCHAR2(50),
    Description VARCHAR2(100),
    Sizes VARCHAR2(30),
    Production_cost NUMBER(5,2),
    CONSTRAINT valid_production_cost CHECK (Production_cost > 0)
);

-- Table Dim_Store
CREATE TABLE Dim_Store (
    Store_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(30) NOT NULL,
    City VARCHAR2(20) NOT NULL,
    Country VARCHAR2(20) NOT NULL,
    Zip_code VARCHAR2(20) NOT NULL,
    Latitude NUMBER(9,6),
    Longitude NUMBER(9,6)
);

-- Table Fait_Transaction
CREATE TABLE Fait_Transaction (
    Transactions_ID NUMBER PRIMARY KEY,
    Date_ID NUMBER,
    Discount_ID NUMBER,
    Product_ID NUMBER,
    Store_ID NUMBER,
    Customer_ID NUMBER,  
    Quantity NUMBER(2),
    Unit_Price NUMBER(6,2),
    Line_Total NUMBER(6,2),
    Transaction_Type VARCHAR2(10),
    -- Contraintes de clé étrangère
    CONSTRAINT FK_Transactions_Date FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID),
    CONSTRAINT FK_Transactions_Discount FOREIGN KEY (Discount_ID) REFERENCES Dim_Discount(Discount_ID),
    CONSTRAINT FK_Transactions_Product FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID),
    CONSTRAINT FK_Transactions_Store FOREIGN KEY (Store_ID) REFERENCES Dim_Store(Store_ID),
    CONSTRAINT FK_Transactions_Customer FOREIGN KEY (Customer_ID) REFERENCES Dim_Customer(Customer_ID)
);