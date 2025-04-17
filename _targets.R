#Dépendance
library(targets)
library(rmarkdown)
library(tidyr)
library(dplyr)
library(RSQLite)
library(pbapply)

#Script R
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
source('open_corr')

#Pipeline
list(
  #Chemin du fichier taxonomie
  tar_target(
    name = path_taxo,
    command = "series_temporelles/taxonomie.csv",
    format = "file"
  ),
  
  #Ouverture dossier taxonomie.csv et changement nom order -> taxo_order
  tar_target(
    taxonomie_inject,
    ouverture(path_taxo, "order", "taxo_order")
  ),
  
  #Chemin vers fichier series_temporelles
  tar_target(
    name = path_series,
    command = "./series_temporelles",
    format = "file"
  ),
  
  #Ouverture combiner les données dossier series_temporelles + ouverture dossier_comb + changement values -> valeurs
  tar_target(
    dossier_comb,
    combine_csv(path_series, "taxonomie.csv", "dossier_comb.csv", "values", "valeurs")
  ),
  
  #Uniformiser nom colonne pour donnees geo
  tar_target(
    donnees_comb,
    corriger_geom(dossier_comb)
  ),
  
  #Uniformiser nom colonne pour donnees license
  tar_target(
    comb_nom_corr,
    corriger_license(donnees_comb)
  ),
  
  #Retirer colonne vide
  tar_target(
    comb_sans_vide,
    enlever_colonnes_vides(comb_nom_corr)
  ),
  
  #Arranger colonne years et valeurs
  tar_target(
    comb_unnest,
    unnest_col(comb_sans_vide, "years", "valeurs")
  ),
  
  #Vérifier que years et valeurs ont données positifs
  tar_target(
    comb_positif,
    justePositif(comb_unnest)
  ),
  
  #Transformer NULL en NA
  tar_target(
    comb_NA,
    NoNull(comb_positif)
  )
)
