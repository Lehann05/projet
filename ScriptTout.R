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


#------------------------------------

#Remplacer les NULL par NA dans tout le dataframe
  df <- NoNull(df)  
  
  #Assurer qu'il n'y a pas de valeurs négatives dans les colonnes numériques sauf pour les coordonnées
  df <- justePositif(df)  
  
  #Si des colonnes sont des listes, les convertir en chaines de caractère
  #Facilite le transfert en csv
  df[] <- lapply(df, function(col) {
    if (is.list(col)) {
      col <- sapply(col, function(x) {
        if (is.null(x)) return(NA)
        if (length(x) > 1) return(paste(x, collapse = ";"))
        return(as.character(x))
      })
    }
    return(col)
  })
  #Sauvegarder le dataframe dans un fichier csv
  output_file <- file.path(output_dir, basename(file))
  write.csv(df, output_file, row.names = FALSE)



# Liste des fichiers CSV dans le répertoire, excluant 'taxonomie.csv'
file_list <- list.files(path = "~/BIO500/series_temporelles/series_temporelles/series_nettoyées", 
                        pattern = "*.csv", full.names = TRUE)

# Exclure explicitement le fichier 'taxonomie.csv' de la liste
file_list <- file_list[!grepl("taxonomie.csv$", file_list)]

# Lire tous les fichiers CSV
df_list <- lapply(file_list, function(file) {
  df <- read.csv(file, stringsAsFactors = FALSE)
  return(df)
})

# Trouver les colonnes communes
all_columns <- unique(unlist(lapply(df_list, colnames)))

# Aligner les colonnes pour chaque dataframe
df_list <- lapply(df_list, function(df) {
  # Ajouter les colonnes manquantes avec des NA
  missing_cols <- setdiff(all_columns, colnames(df))
  df[missing_cols] <- NA
  # Réorganiser les colonnes pour qu'elles soient dans le même ordre
  df <- df[, all_columns]
  return(df)
})



# Assurez-vous que les deux colonnes existent
if ("lisense" %in% names(combined_df) && "license" %in% names(combined_df)) {
  # Identifier les valeurs non numériques dans 'lisense' (celles qui ne sont pas purement numériques)
  non_numeric_values <- !grepl("^[0-9]+$", combined_df$lisense)  # Regex qui vérifie que la valeur n'est pas uniquement numérique
  
  # Transférer les valeurs non numériques dans 'license'
  combined_df$license[non_numeric_values] <- combined_df$lisense[non_numeric_values]
  
  combined_df$lisense <- NULL
}






