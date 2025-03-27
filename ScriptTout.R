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

#Utiliser la fonction qui combine les csv (sauf taxonomie)

combiner_csv(dossier_principal = "~/projet/series_temporelles",
             dossier_a_exclure = "taxonomie.csv",
             nom_sortie = "dossier_comb.csv")

dossier_comb <- read.csv('dossier_comb.csv')
View(dossier_comb)

#Liste des fichiers CSV
file_list <- list.files(path = "~/BIO500/series_temporelles/series_temporelles", pattern = "*.csv", full.names = TRUE)

#Boucle pour traiter et enregistrer les fichiers
for (file in file_list) {
  #Lire le fichier et le mettre dans un dataframe
  df <- read.csv(file, stringsAsFactors = FALSE)
  
  #Si la colonne existe --> liste de nombre
  if ("values" %in% names(df)) {
    df$values <- lapply(df$values, convertion_array_list)
  }
  if ("years" %in% names(df)) {
    if (is.character(df$years)) {
      df$years <- lapply(df$years, convertion_array_list)
    }
  }
  
  #Appliquer la fonction force_list si la fonction précédente n'a pas fonctionnée
  df <- force_list(df, "values")
  df <- force_list(df, "years")
  
  #Si la colonne geom existe, séparer les coordonnées
  if ("geom" %in% names(df)) {
    # Vérifier la structure de la colonne 'geom' avant de la séparer
    
    #Appliquer la fonction separer_coords pour séparer les coordonnées
    coords_list <- lapply(df$geom, separer_coords)
    #Créer deux nouvelles colonnes avec la longitude et la latitude
    df$longitude <- sapply(coords_list, `[`, 1)  
    df$latitude <- sapply(coords_list, `[`, 2)  
    #Supprimer la colonne geom
    df$geom <- NULL  # Supprimer la colonne 'geom' après avoir extrait les coordonnées
  }
  
  #Si la colonne geom existe, séparer les coordonnées
  if ("geometry" %in% names(df)) {
    # Vérifier la structure de la colonne 'geom' avant de la séparer
    
    #Appliquer la fonction separer_coords pour séparer les coordonnées
    coords_list <- lapply(df$geom, separer_coords)
    #Créer deux nouvelles colonnes avec la longitude et la latitude
    df$longitude <- sapply(coords_list, `[`, 1)  
    df$latitude <- sapply(coords_list, `[`, 2)  
    #Supprimer la colonne geom
    df$geometry <- NULL  # Supprimer la colonne 'geom' après avoir extrait les coordonnées
  }
  
  #unnest() --> Séparer les lignes 
  if ("values" %in% names(df) && "years" %in% names(df)) {
    df <- unnest(df, cols = c(values, years))
  }
  
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
}


# Définir le répertoire de travail
setwd("~/BIO500/series_temporelles/series_temporelles/series_nettoyées")

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

# Combiner tous les fichiers en un seul dataframe
combined_df <- do.call(rbind, df_list)

# Afficher les premières lignes du dataframe combiné
head(combined_df)
View(combined_df)

# Assurez-vous que les deux colonnes existent
if ("lisense" %in% names(combined_df) && "license" %in% names(combined_df)) {
  # Identifier les valeurs non numériques dans 'lisense' (celles qui ne sont pas purement numériques)
  non_numeric_values <- !grepl("^[0-9]+$", combined_df$lisense)  # Regex qui vérifie que la valeur n'est pas uniquement numérique
  
  # Transférer les valeurs non numériques dans 'license'
  combined_df$license[non_numeric_values] <- combined_df$lisense[non_numeric_values]
  
  combined_df$lisense <- NULL
}

# Afficher
View(combined_df)

# Si nécessaire, enregistrer le dataframe combiné dans un nouveau fichier CSV
write.csv(combined_df, "données_combinées.csv", row.names = FALSE)




