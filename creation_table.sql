CREATE TABLE Dim_discount(
    discount_key  PRIMARY KEY,
    percent_discount  NUMERIC(6,2) DEFAULT 0.00,
    date_start_disc DATE NOT NULL,
    date_end_disc DATE NOT NULL,
    CHECK (date_start_disc <= date_end_disc)
);
CREATE TABLE Dim_date(
    date_key PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    jour INT NOT NULL CHECK (jour BETWEEN 1 AND 31),
    jourSemaine VARCHAR(15) NOT NULL CHECK (JourSemaine IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday','Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche')), 
    mois    INT NOT NULL CHECK (mois BETWEEN 1 AND 12),
    annee     INT NOT NULL,
    saison  VARCHAR(15)
);