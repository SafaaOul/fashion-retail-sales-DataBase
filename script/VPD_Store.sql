

EXECUTE DBMS_RLS.DROP_POLICY('ADMIN11','Fait_Transaction','STORE_POLICY');
DROP TABLE EMPLOYES_PAYS;
DROP ROLE directeur_regional;
--DROP ROLE client;


-- 1. Création des rôles
CREATE ROLE directeur_regional;


-- Directeur Régional : accès limité
GRANT SELECT ON Dim_Product TO directeur_regional;
GRANT SELECT ON Dim_Store TO directeur_regional;
GRANT SELECT ON Fait_Transaction TO directeur_regional;


--CREATE USER USER1 WITH PASSWORD 'user';
GRANT directeur_regional TO USER1;
GRANT directeur_regional TO USER2;


-- Creation de la Table Employes Pays avec les informations sur le pays de chaque user
CREATE TABLE EMPLOYES_PAYS(
utilisateur VARCHAR2(10) PRIMARY KEY,
pays VARCHAR2(20)
);


INSERT INTO EMPLOYES_PAYS VALUES ('USER1', 'China');
INSERT INTO EMPLOYES_PAYS VALUES ('USER2', 'United States');
INSERT INTO EMPLOYES_PAYS VALUES ('USER3', 'United Kingdom');
INSERT INTO EMPLOYES_PAYS VALUES ('USER4', 'Deutschland');
INSERT INTO EMPLOYES_PAYS VALUES ('USER5', 'France');
INSERT INTO EMPLOYES_PAYS VALUES ('USER6', 'España');
INSERT INTO EMPLOYES_PAYS VALUES ('USER7', 'Portugal');




CREATE OR REPLACE CONTEXT PAYS_ctx USING set_PAYS_ctx_pkg;
CREATE OR REPLACE PACKAGE set_PAYS_ctx_pkg IS
   PROCEDURE set_pays;
END;
/


CREATE OR REPLACE PACKAGE BODY set_PAYS_ctx_pkg IS
   PROCEDURE set_pays IS
       role_var VARCHAR2(40);
       pays_var VARCHAR2(20);
   BEGIN
   -- Requête permettant de récupérer le rôle de l'utilisateur qui est connecté
       SELECT granted_role INTO role_var
       FROM DBA_ROLE_PRIVS
       WHERE granted_role = 'directeur_regional' AND GRANTEE=user
       AND ROWNUM=1;
   -- Initialisation de la variable role du contexte
       DBMS_SESSION.SET_CONTEXT('PAYS_ctx', 'role_nom', role_var);
   -- Requête pour récupérer le pays de l'employé qui est connecté
       SELECT pays INTO pays_var
       FROM ADMIN11.EMPLOYES_PAYS
       WHERE utilisateur=user
       AND ROWNUM=1;
   -- Initialisation de la variable role du contexte
       DBMS_SESSION.SET_CONTEXT('PAYS_ctx', 'pays', pays_var);
   -- Si pas de données alors NULL
       EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
    END set_pays;
END set_PAYS_ctx_pkg;
/
SHOW ERROR;


BEGIN
   DBMS_RLS.ADD_POLICY (
       OBJECT_SCHEMA => 'ADMIN11',
       OBJECT_NAME => 'Fait_Transaction',
       POLICY_NAME => 'STORE_POLICY',
       FUNCTION_SCHEMA => 'ADMIN11',
       POLICY_FUNCTION => 'Auth_Clients_PAYS',
       STATEMENT_TYPES => 'SELECT, UPDATE'
   );
END;
/

CREATE OR REPLACE FUNCTION Auth_Clients_PAYS(
   SCHEMA_VAR IN VARCHAR2,
   TABLE_VAR IN VARCHAR2)
   RETURN VARCHAR2
   IS
       return_val VARCHAR2(140);
       role_user VARCHAR2(40);
       pays_var VARCHAR2(20);
   BEGIN
       role_user := SYS_CONTEXT('PAYS_ctx','role_nom');
       pays_var := SYS_CONTEXT('PAYS_ctx', 'pays');
       IF role_user = 'directeur_regional' THEN
           return_val := 'Dim_Store.Country= ''' || pays_var || '''';
       ELSE
           return_val := '1=1';   
       END IF;
       RETURN return_val;
   END Auth_Clients_PAYS;
/
SHOW ERROR;


