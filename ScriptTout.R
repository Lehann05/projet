#Définir le directory

#Ouvrir les bibliothèques nécessaires 
library(tidyr)
library(dplyr)

#Charger les scripts avec source
source('Eval1.R')
source('Eval2.R')
source('Eval3.R')
source('Eval4.R')
source('Eval5.R')
source('Combine.R')
source('Cor_geom.R')
source('Cor_license.R')
source('enl_col_vide.R')

#Utiliser la fonction qui combine les csv (sauf taxonomie)
# Étape 1 - Combiner
combiner_csv(dossier_principal = "~/projet/series_temporelles",
             dossier_a_exclure = "taxonomie.csv",
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

#Faire la même chose pour le csv taxonomie 
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
donnees_comb <- separer_coords(donnees_comb)



# Appliquer la fonction separer_coords pour séparer les coordonnées
coords_list <- lapply(donnees_comb$geom, separer_coords)

#Créer deux nouvelles colonnes avec la longitude et la latitude
donnees_comb$longitude <- sapply(coords_list, `[`, 1)  
donnees_comb$latitude <- sapply(coords_list, `[`, 2)  

#Supprimer la colonne geom
donnees_comb$geom <- NULL  # Supprimer la colonne 'geom' après avoir extrait les coordonnées









