------------------------------------------------------------------
-- SUPPRIMER LES POLITIQUES VPD SI ELLES EXISTENT
------------------------------------------------------------------
BEGIN
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Dim_Product', 'analyste_product_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Dim_Store', 'analyste_store_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Dim_Discount', 'analyste_discount_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Dim_Customer', 'analyste_customer_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Fait_Transaction', 'analyste_transaction_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Fait_Transaction', 'directeur_transaction_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Dim_Customer', 'client_customer_policy');
  DBMS_RLS.DROP_POLICY('ADMIN27', 'Fait_Transaction', 'client_transaction_policy');
EXCEPTION
  WHEN OTHERS THEN NULL; -- ignorer les erreurs si les politiques n'existent pas
END;
/

------------------------------------------------------------------
--  SUPPRIMER LES RÔLES S'ILS EXISTENT
------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP ROLE directeur_regional';
  EXECUTE IMMEDIATE 'DROP ROLE analyste';
  EXECUTE IMMEDIATE 'DROP ROLE client';
EXCEPTION
  WHEN OTHERS THEN NULL; -- ignorer les erreurs si les rôles n'existent pas
END;
/

------------------------------------------------------------------
--  CRÉATION DES RÔLES ET PRIVILÈGES
------------------------------------------------------------------
CREATE ROLE directeur_regional;
CREATE ROLE analyste;
CREATE ROLE client;

-- Directeur Régional
GRANT SELECT ON Dim_Product TO directeur_regional;
GRANT SELECT ON Dim_Store TO directeur_regional;
GRANT SELECT ON Fait_Transaction TO directeur_regional;

-- Analyste
GRANT SELECT ON Dim_Product TO analyste;
GRANT SELECT ON Dim_Store TO analyste;
GRANT SELECT ON Dim_Discount TO analyste;
GRANT SELECT ON Dim_Customer TO analyste;
GRANT SELECT ON Fait_Transaction TO analyste;

-- Client
GRANT SELECT ON Dim_Customer TO client;
GRANT SELECT ON Fait_Transaction TO client;

------------------------------------------------------------------
--  CONTEXTE D’APPLICATION
------------------------------------------------------------------
CREATE OR REPLACE CONTEXT app_ctx USING set_app_ctx_pkg;

CREATE OR REPLACE PACKAGE set_app_ctx_pkg IS
  PROCEDURE set_context;
END;
/

CREATE OR REPLACE PACKAGE BODY set_app_ctx_pkg IS
  PROCEDURE set_context IS
    v_role VARCHAR2(30);
  BEGIN
    SELECT granted_role INTO v_role
    FROM USER_ROLE_PRIVS
    WHERE ROWNUM = 1;

    DBMS_SESSION.SET_CONTEXT('app_ctx', 'role', v_role);

    IF v_role = 'ANALYSTE' THEN
      DBMS_SESSION.SET_CONTEXT('app_ctx', 'country', USER);
    ELSIF v_role = 'DIRECTEUR_REGIONAL' THEN
      DBMS_SESSION.SET_CONTEXT('app_ctx', 'store_id', TO_NUMBER(SUBSTR(USER, 6)));
    ELSIF v_role = 'CLIENT' THEN
      DBMS_SESSION.SET_CONTEXT('app_ctx', 'customer_id', TO_NUMBER(SUBSTR(USER, 5)));
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN NULL;
  END;
END;
/
SHOW ERRORS;

------------------------------------------------------------------
-- FONCTIONS VPD
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION vpd_analyste_country (
  schema_var IN VARCHAR2,
  table_var IN VARCHAR2  -- Corriger le nom du paramètre
) RETURN VARCHAR2 IS
BEGIN
  CASE table_var  -- Utiliser table_var au lieu d’un nom incorrect
    WHEN 'FAIT_TRANSACTION' THEN
      RETURN 'store_id IN (SELECT store_id FROM Dim_Store WHERE country = SYS_CONTEXT(''app_ctx'', ''country''))';
    ELSE
      RETURN '1=1';
  END CASE;
END;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION vpd_directeur_store (
  schema_var IN VARCHAR2,
  table_var IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN 'store_id = SYS_CONTEXT(''app_ctx'', ''store_id'')';
END;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION vpd_client_customer (
  schema_var IN VARCHAR2,
  table_var IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN 'customer_id = SYS_CONTEXT(''app_ctx'', ''customer_id'')';
END;
/
SHOW ERRORS;

------------------------------------------------------------------
-- POLITIQUES VPD
------------------------------------------------------------------
BEGIN
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Dim_Product',     'analyste_product_policy',     'ADMIN27', 'vpd_analyste_country',     'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Dim_Store',       'analyste_store_policy',       'ADMIN27', 'vpd_analyste_country',     'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Dim_Discount',    'analyste_discount_policy',    'ADMIN27', 'vpd_analyste_country',     'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Dim_Customer',    'analyste_customer_policy',    'ADMIN27', 'vpd_analyste_country',     'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Fait_Transaction','analyste_transaction_policy', 'ADMIN27', 'vpd_analyste_country',     'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Fait_Transaction','directeur_transaction_policy','ADMIN27', 'vpd_directeur_store',      'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Dim_Customer',    'client_customer_policy',      'ADMIN27', 'vpd_client_customer',      'SELECT');
  DBMS_RLS.ADD_POLICY('ADMIN27', 'Fait_Transaction','client_transaction_policy',   'ADMIN27', 'vpd_client_customer',      'SELECT');
END;
/
