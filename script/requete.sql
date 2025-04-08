-- Voir le résultat des requetes en bas de page 
"1. Total des ventes par pays"

SELECT s.Country, SUM(f.Line_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY s.Country;

"2. Total des ventes par pays et ville avec ROLLUP "
SELECT s.Country, s.City, SUM(f.Line_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY ROLLUP (s.Country, s.City);

"3. Ventes par catégorie et sous-catégorie avec CUBE"
SELECT p.Category, p.Sub_Category, SUM(f.Line_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
GROUP BY CUBE (p.Category, p.Sub_Category);

"4. Utilisation de GROUPING et GROUPING_ID"
SELECT
  p.Category,
  p.Sub_Category,
  SUM(f.Line_Total) AS Total_Ventes,
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
SELECT f.TransactionS_ID, f.Line_Total,
       NTILE(4) OVER (ORDER BY f.Line_Total DESC) AS Quartile
FROM Fait_Transaction f;

"7. Moyenne mobile des ventes sur 3 dates"

SELECT d.Date, f.Line_Total,
       AVG(f.Line_Total) OVER (
         ORDER BY d.Date
         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS Moyenne_Mobile
FROM Fait_Transaction f
JOIN Dim_Date d ON f.Date_ID = d.Date_ID;

'8. Évolution des ventes mois par mois'
SELECT d.Year, d.Month,
       SUM(f.Line_Total) AS Total_Mois,
       SUM(f.Line_Total) - LAG(SUM(f.Line_Total)) OVER (ORDER BY d.Year, d.Month) AS Evolution
FROM Fait_Transaction f
JOIN Dim_Date d ON f.Date_ID = d.Date_ID
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;

'9. Classement des magasins par pays selon les ventes'
SELECT s.Country, s.Name, SUM(f.Line_Total) AS Total,
       RANK() OVER (PARTITION BY s.Country ORDER BY SUM(f.Line_Total) DESC) AS Rang
FROM Fait_Transaction f
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY s.Country, s.Name;


'10. Groupes personnalisés avec GROUPING SETS'
SELECT p.Category, s.Country, SUM(f.Line_Total) AS Total_Ventes
FROM Fait_Transaction f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY GROUPING SETS (
  (p.Category),
  (s.Country),
  (p.Category, s.Country)
);

'11. Classement des 10 villes sans boutiques avec le plus de clients'

SELECT * FROM (
    SELECT C.Country, C.City, COUNT(*) AS "Nombre de Ventes"
    FROM Fait_Transaction F
    INNER JOIN Dim_Customer C ON F.Customer_ID = C.Customer_ID
    INNER JOIN Dim_Store S ON F.Store_ID = S.Store_ID
    WHERE C.City NOT IN (SELECT S.City FROM Dim_Store S)
    GROUP BY C.Country, C.City
    ORDER BY COUNT(*) DESC)
WHERE ROWNUM <=10;


'12. Groupement des boutiques par année en fonction de la somme de leurs ventes'

SELECT S.Name, D.Year, SUM(F.Line_Total), Count(F.Line_Total) AS Ventes
FROM Fait_Transaction F
INNER JOIN Dim_Store S ON F.Store_ID = S.Store_ID
INNER JOIN Dim_Date D ON F.Date_ID = D.Date_ID
WHERE F.Transaction_Type = 'Sale'
GROUP BY ROLLUP(S.Name, D.Year);