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
source('open_corr.R')

#Pipeline
list(
  #Section 1: ouverture, uniformisation, correction et séparation des données en table
  #1.1 ouverture des données
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
    combiner_csv(path_series, "taxonomie.csv", "dossier_comb.csv", "values", "valeurs")
  ),
  
  #1.2 Uniformisation des donnees
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
  
  #Arranger colonne years et valeurs pour qu'il n'y ait qu'une donnée par ligne pour chaque colonne
  tar_target(
    comb_unnest,
    unnest_col(comb_sans_vide, "years", "valeurs")
  ),
  #1.3 correction des donnéees
  #Vérifier que years et valeurs ont données positifs
  tar_target(
    comb_positif,
    justePositif(comb_unnest)
  ),
  
  #Transformer NULL en NA
  tar_target(
    comb_NA,
    NoNull(comb_positif)
  ),
  
  #traitement des coordonnées géographiques -> ajout colonnes longitude et latitude, séparation des coordonnées, et suppression de la colonne geom
  tar_target(
    comb_finales,
    traiter_coords_geom(comb_NA)
  ),
  
  #1.4 Séparation du dataframe comb_finales en 2 tables -> sources et abondance
  #Sources: séparer les colonnes voulues du dataframe et les stocker dans un objet intermédiaire
  tar_target(
    col_sources,
    c("original_source", "title", "publisher", "license", "owner")
  ),
  
  tar_target(
    sources_inter,
    division_table(comb_finales, col_sources)
  ),
  
  #Sources: enlever les lignes dupliquées (owner, license, publisher et original_source toujours similaire pour un même titre)
  tar_target(
    sources_inject,
    sources_inter %>% distinct()
  ),
  
  tar_target(
    col_abondance,
    c("observed_scientific_name", "years", "unit", "valeurs", "title", "longitude", "latitude")
  ),
  
  #Abondance: séparer les colonnes voulues du dataframe
  tar_target(
    abondance_inject,
    division_table(comb_finales, col_abondance)
  ),
  
  #Section 2: création de tables SQL et injection des dataframes taxonomie_inject, sources_inject et abondance_inject dans celles-ci
  #2.1 Connection à utiliser
  tar_target(
    connection, 
    dbConnect(SQLite(), dbname="réseau.db")
  ),
  
  #2.2 Requête de création des tables SQL
  #Requête pour table taxonomie
  tar_target(
    creer_taxo,
    "CREATE TABLE taxonomie(
    observed_scientific_name    VARCHAR(75),
    valid_scientific_name       VARCHAR(75),
    rank                        VARCHAR(20),
    vernacular_fr               VARCHAR(55),
    kingdom                     VARCHAR(15),
    phylum                      VARCHAR(15),
    class                       VARCHAR(30),
    taxo_order                  VARCHAR(35),
    family                      VARCHAR(35),
    genus                       VARCHAR(35),
    species                     VARCHAR(55),
    PRIMARY KEY(observed_scientific_name)
  );"
  ),
  
  #Requête pour table sources
  tar_target(
    creer_source,
    "CREATE TABLE sources(
    title                   VARCHAR(500) PRIMARY KEY, 
    original_source         VARCHAR(50),
    publisher               VARCHAR(100),
    license                 VARCHAR(50),
    owner                   VARCHAR(100)
  );"
  ),
  
  #Requête pour table abondance
  tar_target(
    creer_abondance,
    "CREATE TABLE abondance(
    id                          INTEGER PRIMARY KEY AUTOINCREMENT,
    observed_scientific_name    VARCHAR(75),
    years                       INTEGER,
    unit                        VARCHAR(75),
    valeurs                      INTEGER,
    title                       VARCHAR(500),
    longitude                   DOUBLE,
    latitude                    DOUBLE,
    FOREIGN KEY(observed_scientific_name)  REFERENCES taxonomie(observed_scientific_name),
    FOREIGN KEY(title)  REFERENCES sources(title)
  );"
  ), 
  
  #2.3 Création des tables et injection des données
  #Table taxonomie
  tar_target(
    taxonomie,
    creer_table(connection, creer_taxo, "taxonomie", taxonomie_inject)
  ),
  
  #Table sources
  tar_target(
    sources,
    creer_table(connection, creer_sources, "sources", sources_inject)
  ),
  
  #Table abondance
  tar_target(
    abondance,
    creer_table(connection, creer_abondance, "abondance", abondance_inject)
  )
)
