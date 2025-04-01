-- Voir le résultat des requetes en bas de page 
"1. Total des ventes par pays"

SELECT s.Country, SUM(f.Invoice_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY s.Country;

"2. Total des ventes par pays et ville avec ROLLUP "
SELECT s.Country, s.City, SUM(f.Invoice_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY ROLLUP (s.Country, s.City);

"3. Ventes par catégorie et sous-catégorie avec CUBE"
SELECT p.Category, p.Sub_Category, SUM(f.Invoice_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
GROUP BY CUBE (p.Category, p.Sub_Category);

"4. Utilisation de GROUPING et GROUPING_ID"
SELECT
  p.Category,
  p.Sub_Category,
  SUM(f.Invoice_Total) AS Total_Ventes,
  GROUPING(p.Category) AS grp_cat,
  GROUPING(p.Sub_Category) AS grp_sub,
  (GROUPING(p.Category) * 2 + GROUPING(p.Sub_Category)) AS gid
FROM Fait_Transaction f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
GROUP BY CUBE (p.Category, p.Sub_Category);

"5. Top 5 des produits les plus vendus en quantité"

SELECT * FROM (
  SELECT p.Description, SUM(f.Quantity) AS Total_Qte,
         RANK() OVER (ORDER BY SUM(f.Quantity) DESC) AS Rang
  FROM Fait_Transaction f
  JOIN Dim_Product p ON f.Product_ID = p.Product_ID
  GROUP BY p.Description
) AS classement
WHERE Rang <= 5;

"6. Répartition des ventes en quartiles (NTILE)"
SELECT f.TransactionS_ID, f.Invoice_Total,
       NTILE(4) OVER (ORDER BY f.Invoice_Total DESC) AS Quartile
FROM Fait_Transaction f;

"7. Moyenne mobile des ventes sur 3 dates"

SELECT d.Date, f.Invoice_Total,
       AVG(f.Invoice_Total) OVER (
         ORDER BY d.Date
         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS Moyenne_Mobile
FROM Fait_Transaction f
JOIN Dim_Date d ON f.Date_ID = d.Date_ID;

'8. Évolution des ventes mois par mois'
SELECT d.Year, d.Month,
       SUM(f.Invoice_Total) AS Total_Mois,
       SUM(f.Invoice_Total) - LAG(SUM(f.Invoice_Total)) OVER (ORDER BY d.Year, d.Month) AS Evolution
FROM Fait_Transaction f
JOIN Dim_Date d ON f.Date_ID = d.Date_ID
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;

'9. Classement des magasins par pays selon les ventes'
SELECT s.Country, s.Name, SUM(f.Invoice_Total) AS Total,
       RANK() OVER (PARTITION BY s.Country ORDER BY SUM(f.Invoice_Total) DESC) AS Rang
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY s.Country, s.Name;


'10. Groupes personnalisés avec GROUPING SETS'
SELECT p.Category, s.Country, SUM(f.Invoice_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY GROUPING SETS (
  (p.Category),
  (s.Country),
  (p.Category, s.Country)
);

/* Requete1: Total des ventes par pays

COUNTRY              TOTAL_VENTES
-------------------- ------------
China                   123036913
United Kingdom         3882702,03
United States          16913288,7
France                  5860439,8
Espa├▒a                5199611,61
Deutschland            6977308,79
Portugal               5352084,41

7 rows selected.*/

/* Requete2:

COUNTRY              CITY                 TOTAL_VENTES
-------------------- -------------------- ------------
China                Canton                 29767473,4
China                P├®kin                 22097528,4
China                Shanghai               30026711,3
China                Shenzhen               25999570,5
China                Chongqing              15145629,8
China                                        123036913
France               Lyon                   1124840,25
France               Nice                    989607,61
France               Paris                  1652794,83
France               Toulouse               1015433,69
France               Marseille              1077763,42
France                                       5860439,8
Portugal             Braga                   606286,14
Portugal             Porto                  1348022,06
Portugal             Lisboa                 1800208,83
Portugal             Coimbra                 883395,66
Portugal             Guimar├úes              714171,72
Portugal                                    5352084,41
Espa├▒a              Madrid                 1822995,05
Espa├▒a              Sevilla                 867356,47
Espa├▒a              Valencia                668536,87
Espa├▒a              Zaragoza               1037717,82
Espa├▒a              Barcelona                803005,4
Espa├▒a                                     5199611,61
Deutschland          Berlin                  2570561,8
Deutschland          Hamburg                1518615,97
Deutschland          K├Âln                  1142101,84
Deutschland          M├╝nchen               1007481,83
Deutschland          Frankfurt am Main       738547,35
Deutschland                                 6977308,79
United States        Chicago                2411626,88
United States        Houston                3113568,22
United States        Phoenix                2050165,68
United States        New York               4930240,22
United States        Los Angeles             4407687,7
United States                               16913288,7
United Kingdom       London                 1179549,44
United Kingdom       Bristol                 786778,77
United Kingdom       Glasgow                 519745,25
United Kingdom       Liverpool               532986,06
United Kingdom       Birmingham              863642,51
United Kingdom                              3882702,03
                                             167222349

43 rows selected. */


