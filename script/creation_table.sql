-- Suppression sécurisée des tables
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Fait_Transaction CASCADE CONSTRAINTS';
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
   EXECUTE IMMEDIATE 'DROP TABLE Dim_Store CASCADE CONSTRAINTS';
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
   EXECUTE IMMEDIATE 'DROP TABLE Dim_Discount CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Dim_Client CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/


-- Suppression des séquences si elles existent
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_discount_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_product_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_store_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_date_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_transaction_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_client_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Création des tables avec syntaxe corrigée
CREATE TABLE Dim_Discount (
    Discount_ID NUMBER,
    Percent_discount NUMBER(5,2) NOT NULL CHECK (Percent_discount BETWEEN 0 AND 100),
    Date_start DATE NOT NULL,  
    Date_end DATE NOT NULL, 
    CONSTRAINT PK_Discount PRIMARY KEY (Discount_ID),
    CONSTRAINT valid_dates CHECK (Date_end >= Date_start)
);

CREATE TABLE Dim_Product (
    Product_ID NUMBER,
    Category VARCHAR2(20) NOT NULL,
    Sub_Category VARCHAR2(50),
    Description VARCHAR2(100),          
    Sizes VARCHAR2(30),
    Production_cost NUMBER(5,2),
    CONSTRAINT PK_Product PRIMARY KEY (Product_ID),
    CONSTRAINT valid_production_cost CHECK (Production_cost > 0)
);

CREATE TABLE Dim_Store (
    Store_ID NUMBER,
    Name VARCHAR2(30) NOT NULL,
    City VARCHAR2(20) NOT NULL,
    Country VARCHAR2(20) NOT NULL,
    Zip_code VARCHAR2(20) NOT NULL,
    Latitude NUMBER(7,4),
    Longitude NUMBER(7,4),
    CONSTRAINT PK_Store PRIMARY KEY (Store_ID)
);

CREATE TABLE Dim_Date (
    Date_ID NUMBER,
    DateTime TIMESTAMP,     
    Date_value DATE,             -- Changé de 'Date' à 'Date_value'
    Year NUMBER,
    Month NUMBER,
    Day NUMBER,
    Hour NUMBER,
    DayOfWeek NUMBER,
    WeekOfYear NUMBER,
    CONSTRAINT PK_Date PRIMARY KEY (Date_ID)
);
CREATE TABLE Dim_Client (
    Client_ID NUMBER,
    Country VARCHAR2(50),
    City VARCHAR2(50),
    Age NUMBER,
    CONSTRAINT PK_Client PRIMARY KEY (Client_ID),
    CONSTRAINT valid_age CHECK (Age >= 0 AND Age <= 120)
);

CREATE TABLE Fait_Transaction (
    Transactions_ID NUMBER,
    Date_ID NUMBER,
    Discount_ID NUMBER,
    Product_ID NUMBER,
    Store_ID NUMBER,
    Client_ID NUMBER,
    Quantity NUMBER,
    Unit_Price NUMBER(10, 2),
    Line_Total NUMBER(10, 2),
    Transaction_Type VARCHAR2(50),
    Invoice_Total NUMBER(10, 2),
    CONSTRAINT PK_Transactions PRIMARY KEY (Transactions_ID),
    CONSTRAINT FK_Transactions_Date FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID),
    CONSTRAINT FK_Transactions_Discount FOREIGN KEY (Discount_ID) REFERENCES Dim_Discount(Discount_ID),
    CONSTRAINT FK_Transactions_Product FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID),
    CONSTRAINT FK_Transactions_Store FOREIGN KEY (Store_ID) REFERENCES Dim_Store(Store_ID),
    CONSTRAINT FK_Transactions_Client FOREIGN KEY (Client_ID) REFERENCES Dim_Client(Client_ID)

);

-- Création des séquences
CREATE SEQUENCE seq_discount_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_product_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_store_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_date_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_transaction_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_client_id START WITH 1 INCREMENT BY 1 NOCACHE;


-- Création des index
CREATE INDEX idx_fact_date ON Fait_Transaction(Date_ID);
CREATE INDEX idx_fact_product ON Fait_Transaction(Product_ID);
CREATE INDEX idx_fact_store ON Fait_Transaction(Store_ID);
CREATE INDEX idx_fact_discount ON Fait_Transaction(Discount_ID);
CREATE INDEX idx_fact_client ON Fait_Transaction(Client_ID);


COMMIT;
