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


--Création de trigger 
CREATE OR REPLACE TRIGGER trg_set_ctx_after_login
AFTER LOGON ON DATABASE
BEGIN
  set_app_ctx_pkg.set_context;
END;
/

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
    v_user VARCHAR2(100) := USER;
    v_country VARCHAR2(50);
  BEGIN
    -- Récupération du rôle
    BEGIN
      SELECT granted_role INTO v_role
      FROM USER_ROLE_PRIVS
      WHERE granted_role IN ('ANALYSTE','DIRECTEUR_REGIONAL','CLIENT')
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN v_role := NULL;
    END;

    DBMS_SESSION.SET_CONTEXT('app_ctx', 'role', v_role);

    -- Déduction du pays à partir du nom utilisateur
    IF v_role = 'ANALYSTE' THEN
      IF INSTR(v_user, '_') > 0 THEN
        v_country := UPPER(SUBSTR(v_user, INSTR(v_user, '_') + 1));
        DBMS_SESSION.SET_CONTEXT('app_ctx', 'country', v_country);
      END IF;
    ELSIF v_role = 'DIRECTEUR_REGIONAL' THEN
      DBMS_SESSION.SET_CONTEXT('app_ctx', 'store_id', TO_NUMBER(SUBSTR(v_user, 10))); -- ex: directeur1001
    ELSIF v_role = 'CLIENT' THEN
      DBMS_SESSION.SET_CONTEXT('app_ctx', 'customer_id', TO_NUMBER(SUBSTR(v_user, 7))); -- ex: client2001
    END IF;
  END;
END;
/
SHOW ERRORS;


GRANT EXECUTE ON set_app_ctx_pkg TO analyste_CHINA;
GRANT EXECUTE ON set_app_ctx_pkg TO analyste_FRANCE;
GRANT EXECUTE ON set_app_ctx_pkg TO analyste_BRAZIL;
GRANT EXECUTE ON set_app_ctx_pkg TO directeur1001;
GRANT EXECUTE ON set_app_ctx_pkg TO client2001;

------------------------------------------------------------------
-- FONCTIONS VPD
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION vpd_analyste_country (
  schema_var IN VARCHAR2,
  table_var IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  --  Autoriser l'accès complet à ADMIN27
  IF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'ADMIN27' THEN
    RETURN '1=1';
  END IF;

  --  Filtrer uniquement pour les analystes avec un pays défini
  IF SYS_CONTEXT('app_ctx', 'role') = 'ANALYSTE' 
     AND SYS_CONTEXT('app_ctx', 'country') IS NOT NULL THEN
    RETURN 'store_id IN (
      SELECT store_id 
      FROM ADMIN27.Dim_Store 
      WHERE UPPER(country) = UPPER(SYS_CONTEXT(''app_ctx'', ''country''))
    )';
  END IF;

  --  Bloquer l'accès par défaut
  RETURN '1=0';
END;
/


/*CREATE OR REPLACE FUNCTION vpd_directeur_store (
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
*/
------------------------------------------------------------------
-- POLITIQUES VPD
------------------------------------------------------------------
BEGIN
  DBMS_RLS.DROP_POLICY('ADMIN27', 'FAIT_TRANSACTION', 'analyste_transaction_policy');
  DBMS_RLS.ADD_POLICY(
    object_schema => 'ADMIN27',
    object_name => 'FAIT_TRANSACTION',
    policy_name => 'analyste_transaction_policy',
    function_schema => 'ADMIN27',
    policy_function => 'vpd_analyste_country',
    statement_types => 'SELECT'
  );
END;
/
-- Création des utilisateurs ANALYSTE
CREATE USER analyste_FRANCE IDENTIFIED BY france123;
GRANT CONNECT TO analyste_FRANCE;
GRANT analyste TO analyste_FRANCE;

CREATE USER analyste_CHINA IDENTIFIED BY china123;
GRANT CONNECT TO analyste_CHINA;
GRANT analyste TO analyste_CHINA;

CREATE USER analyste_Portugal IDENTIFIED BY portugal123;
GRANT CONNECT TO analyste_Portugal;
GRANT analyste TO analyste_Portugal;

-- Création d’un utilisateur DIRECTEUR REGIONAL
-- Exemple : directeur1001 = magasin avec store_id = 1001
CREATE USER directeur1001 IDENTIFIED BY dir123;
GRANT CONNECT TO directeur1001;
GRANT directeur_regional TO directeur1001;

-- Création d’un utilisateur CLIENT
-- Exemple : client2001 = client avec customer_id = 2001
CREATE USER client2001 IDENTIFIED BY client123;
GRANT CONNECT TO client2001;
GRANT client TO client2001;
-- Donner accès aux objets du schéma ADMIN27
BEGIN
  FOR obj IN (
    SELECT object_name
    FROM all_objects
    WHERE owner = 'ADMIN27'
    AND object_type IN ('TABLE', 'VIEW')
  )
  LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN27.' || obj.object_name || ' TO analyste_FRANCE';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN27.' || obj.object_name || ' TO analyste_CHINA';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN27.' || obj.object_name || ' TO analyste_PORTUGAL';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN27.' || obj.object_name || ' TO directeur1001';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN27.' || obj.object_name || ' TO client2001';
  END LOOP;
END;
/
