-- ======================================================
-- 1. RÔLES GLOBAUX (groupes de privilèges)
-- ======================================================
CREATE ROLE store_manager;
CREATE ROLE regional_manager;
CREATE ROLE category_manager;
CREATE ROLE discount_admin;
CREATE ROLE analyste;
CREATE ROLE super_admin;

-- ======================================================
-- 2. UTILISATEURS PAR MAGASIN (Store_ID dans stores.csv)
-- ======================================================
CREATE USER store_manager_1 WITH PASSWORD 'sm1'; -- Store_ID = 1
CREATE USER store_manager_2 WITH PASSWORD 'sm2'; -- Store_ID = 2
GRANT store_manager TO store_manager_1, store_manager_2;

-- ======================================================
-- 3. UTILISATEURS PAR RÉGION / PAYS
-- ======================================================
CREATE USER regional_manager_paris WITH PASSWORD 'rp';
CREATE USER regional_manager_madrid WITH PASSWORD 'rm';
GRANT regional_manager TO regional_manager_paris, regional_manager_madrid;

-- ======================================================
-- 4. UTILISATEURS PAR CATÉGORIE DE PRODUITS (products.csv)
-- ======================================================
CREATE USER category_manager_food WITH PASSWORD 'cf';
CREATE USER category_manager_tech WITH PASSWORD 'ct';
GRANT category_manager TO category_manager_food, category_manager_tech;

-- ======================================================
-- 5. AUTRES UTILISATEURS SPÉCIALISÉS
-- ======================================================
CREATE USER discount_admin WITH PASSWORD 'promo';
GRANT discount_admin TO discount_admin;

CREATE USER analyste_commercial WITH PASSWORD 'analyst';
GRANT analyste TO analyste_commercial;

-- ======================================================
-- 6. ADMIN GLOBAL (accès complet à toutes les données)
-- ======================================================
CREATE USER admin WITH PASSWORD 'adminpass';
GRANT super_admin TO admin;
