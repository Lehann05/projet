# Définir le directory

# Ouvrir les bibliothèques nécessaires 
library(tidyr)
library(dplyr)
library(RSQLite)

# Installer et charger pbapply pour avoir une barre de progression
# install.packages("pbapply")
library(pbapply)

# Charger les scripts avec source
source('Eval1.R')
source('Eval2.R')
source('Eval3.R')
source('Eval4.R')
source('Eval5.R')
source('Combine.R')
source('Cor_geom.R')
source('Cor_license.R')
source('enl_col_vide.R')
source('division_table.R')
source('creer_table.R')

# Utiliser la fonction qui combine les csv (sauf taxonomie)
# Étape 1 - Combiner
combiner_csv(dossier_principal = "~/series_temporelles",
             sans_taxonomie = "taxonomie.csv",
             nom_sortie = "dossier_comb.csv")

dossier_comb <- read.csv('dossier_comb.csv')


# Étape 2 - Corriger geom
donnees_comb <- corriger_geom(dossier_comb)

# Étape 3 - Corriger license
donnees_comb <- corriger_license(donnees_comb)

# Étape 4 - Enlever les colonnes vides
donnees_comb <- enlever_colonnes_vides(donnees_comb)

# Étape 4 - Valider
View(donnees_comb)

# Faire la même chose pour le csv taxonomie 
# Étape 1 - Ouvrir
taxonomie <- read.csv('taxonomie.csv')

# Étape 2 - Enlever les colonnes vides
taxonomie <- enlever_colonnes_vides(taxonomie)

# Étape 3 - Valider
View(taxonomie)

# Unnest les colonnes years et values
donnees_comb <- unnest_column(donnees_comb, colname = "years", sep = ",")
donnees_comb <- unnest_column(donnees_comb, colname = "values", sep = ",")

# Vérifier que tout est positifs (sauf les données géographique)
donnees_comb <- justePositif(donnees_comb)
  
# Transformer les null en NA
donnees_comb <- NoNull(donnees_comb)

# Gérer les données géom (séparation des latitudes et des longitudes)
# Utiliser la fonction separer_coords. Ajout d'une barre de progression
# Ça prend à peu près 5 minutes
coords_list <- pblapply(donnees_comb$geom, separer_coords)

# Créer la colonne longitude et latitude
donnees_comb$longitude <- sapply(coords_list, `[`, 1)
donnees_comb$latitude  <- sapply(coords_list, `[`, 2)

# Enlever la colonne geom 
donnees_comb$geom <- NULL


#Séparation de la table "donnees_comb" en 3 dataframes distincts pour analyse

#1ere table -> dataframe taxonomie dans données initiales

#2e table -> sources à partir de donnees_comb
sources_inject <- division_table(donnees_comb, c(original_source, title, publisher, license, owner))

#3e table -> abondance à partir de donnees_comb
abondance_inject <- division_table(donnees_comb, c(id, observed_scientific_name, years, unit, values, title, longitude, latitude))


#Création des dataframes avec RSQLite
#1. Connection à utiliser
con <- dbConnect(SQLite(), dbname="réseau.db")

#2. Commande création des dataframes
#2.1. taxonomie
creer_taxo <-
  "CREATE TABLE taxonomie(
    observed_scientific_name    VARCHAR(75),
    valid_scientific_name       VARCHAR(75),
    rank                        VARCHAR(20),
    vernacular_fr               VARCHAR(55),
    kingdom                     VARCHAR(15),
    phylum                      VARCHAR(15),
    class                       VARCHAR(30),
    order                       VARCHAR(35),
    family                      VARCHAR(35),
    genus                       VARCHAR(35),
    species                     VARCHAR(55),
    PRIMARY KEY(observed_scientific_name)
  );"

#2.2. sources
creer_sources <- 
  "CREATE TABLE sources(
    original_source         VARCHAR(50),
    title                   VARCHAR(500),
    publisher               VARCHAR(10),
    license                 VARCHAR(50),
    owner                   VARCHAR(10),
    PRIMARY KEY(title)
  );"

#2.3. abondance
creer_abondance <-
  "CREATE TABLE abondance(
    id                          INTEGER AUTOINCREMENT,
    observed_scientific_name    VARCHAR(75),
    years                       INTEGER,
    unit                        VARCHAR(75),
    values                      INTEGER,
    title                       VARCHAR(500),
    longitude                   INTEGER,
    latitude                    INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(observed_scientific_name)  REFERENCES taxonomie(observed_scientific_name),
    FOREIGN KEY(title)  REFERENCES sources(title)
  );"

#3. Création et injection des données dans les tables avec fonction creer_table
#3.1. taxonomie
creer_table(con, creer_taxo, "taxonomie", taxonomie)

#3.2. sources
creer_table(con, creer_sources, "sources", sources_inject)

#3.3. abondance
creer_abondance(con, creer_abondance, "abondance", abondance_inject)





