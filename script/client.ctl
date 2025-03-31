LOAD DATA
INFILE '../Data/clients.csv'
INTO TABLE Dim_Client
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    Client_ID,
    Country,
    City,
    Age,
    Signup_Date DATE "YYYY-MM-DD"
)
