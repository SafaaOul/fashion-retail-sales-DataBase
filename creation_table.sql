-- Table Dim_discount (correction "Discont" → "Discount")
CREATE TABLE Dim_discount (
    Discount_key SERIAL PRIMARY KEY,
    Percent_discount DECIMAL(5,2) NOT NULL CHECK (Percent_discount BETWEEN 0 AND 100),
    Date_start DATE NOT NULL,  
    Date_end DATE NOT NULL, 
    CONSTRAINT valid_dates CHECK (Date_end >= Date_start)
);

-- Table Dim_product (gestion des espaces et description)
CREATE TABLE Dim_product (
    Product_key SERIAL PRIMARY KEY,
    Category VARCHAR(100) NOT NULL,
    Sub_Category VARCHAR(100),
    Description TEXT,          
    Sizes VARCHAR(50),
    Production_cost DECIMAL(10,2) CHECK (Production_cost >= 0)
);