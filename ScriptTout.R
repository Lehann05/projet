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








