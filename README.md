# Projet Bases de données avancés

**Données accessible au lien suivant données** : https://www.kaggle.com/datasets/ricgomes/global-fashion-retail-stores-dataset?select=discounts.csv

## Liste des commandes du projet

### Installation des dépendances pour l'exécution du notebook

- `pip install pandas`
- `pip install unidecode`

### Création des tables de la base de données

Depuis sqlplus (doit être lancé depuis la racine du projet)
- `@script/creation_table.sql`

### Insertion des données

Doivent être exécuté depuis un terminal dans la racine du projet

Il faut remplacer les informations suivantes :
- utilisateur : utilisateur avec des droits pour insérer des données
- mdp : mot de passe de l'utilisateur
- nom_bd : nom de la base de données dans laquelle réaliser les insertions

- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Dim_Customer.ctl`
- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Dim_Date.ctl`
- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Dim_Discount.ctl`
- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Dim_Product.ctl`
- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Dim_Store.ctl`
- `sqlldr userid=utilisateur/mdp@nom_bd control=script/Fait_Transaction.ctl`

### Exécution des requêtes

Depuis sqlplus (doit être lancé depuis la racine du projet)
- `@script/requete.sql`

### Création des Rôles et du contrôle d'accès

Depuis sqlplus (doit être lancé depuis la racine du projet)
- `@script/ControlAccessVPD.sql`