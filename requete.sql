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



