#Dépendance
library(targets)
library(rmarkdown)
library(tidyr)
library(dplyr)
library(RSQLite)
library(pbapply)
library(tarchetypes)

#Script R
source('R/Unnest.R')
source('R/Positif.R')
source('R/Null.R')
source('R/Separe_geom.R')
source('R/Combine.R')
source('R/Cor_geom.R')
source('R/Cor_license.R')
source('R/enl_col_vide.R')
source('R/division_table.R')
source('R/creer_table.R')
source('R/open_corr.R')
source('R/tracer_pop.R')

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
    creer_sources,
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
    valeurs                     INTEGER,
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
  ),
  
  #Section 3: Requête de pour la sélection des données qui nous serviront pour l'analyse
  #3.1 Requête pour la sélection des données utiles concernant les loups (Canis lupus)
  #(on fait une moyenne des données d'abondance pour chaque année, car il peut y en avoir plusieurs pour une année)
  tar_target(
    canis_lupus_data,
    {
      abondance  # force la dépendance
      dbGetQuery(connection, "
      SELECT observed_scientific_name, years, AVG(CAST(valeurs AS REAL)) AS moyenne_valeurs, longitude, latitude, unit
      FROM abondance
      WHERE observed_scientific_name = 'Canis lupus'
      GROUP BY years
      ORDER BY years ASC;
    ")
    }
  ),
  
  #3.2 Requête pour la sélection des données utiles concernant les cerfs de Virginie (Odocoileus virginianus)
  tar_target(
    odocoileus_virginianus_data,
    {
    abondance # force la dépendance 
    dbGetQuery(connection, "
      SELECT years, valeurs, observed_scientific_name, latitude, longitude, unit
      FROM abondance
      WHERE observed_scientific_name = 'Odocoileus virginianus'
        AND unit IN ('Number of individuals')
        AND years BETWEEN 1983 AND 2001
      ORDER BY years ASC;")
    }
  ),
  
  #Section 4: Création des figures à partir des données sélectionnées
  #4.1 Figure 1 -> variation de la moyenne du nombre de loups à travers le temps dans la zone d'étude
  tar_target(
    fig1_loup,
    {
      png("figures/graph_loup.png", width = 800, height = 600)
      plot(
        canis_lupus_data$years,
        canis_lupus_data$moyenne_valeurs,
        type = "o",
        col = "steelblue",
        pch = 16,
        lwd = 2,
        xlab = "Année",
        ylab = "Nombre moyen de loup par 100 km2",
        main = "Moyenne annuelle des observations de loups"
      )
      dev.off()
      "figures/graph_loup.png"
    }
  ),
  
  #4.2 Figure 2 -> variation de l'abondance des cerfs de Virginie à travers le temps dans la zone d'étude
  tar_target(
    fig2_cerf,
    {
      png("figures/graph_cerf.png", width = 800, height = 600)
      plot(
        odocoileus_virginianus_data$years,
        odocoileus_virginianus_data$valeurs,
        type = "o",
        col = "orange",
        pch = 16,
        lwd = 2,
        xlab = "Année",
        ylab = "Nombre d'individu",
        main = "Observations annuelles de cerfs de Virginie"
      )
      dev.off()
      "figures/graph_cerf.png"
    }
  ),
  
  #4.3 Figure 3 -> variation des valeurs d'abondance normalisées des cerfs et des loups à travers le temps dans la zone d'étude
  # Normalisation des données d'abondance pour les loups (Canis lupus = Cl)
  tar_target(
    Cl_norm,
    canis_lupus_data %>%
      mutate(valeurs_norm = (moyenne_valeurs - min(moyenne_valeurs)) / (max(moyenne_valeurs) - min(moyenne_valeurs)))
  ),
  
  # Normalisation des données d'abondance pour les cerfs (Odocoileus virginianus = Ov)
  tar_target(
    Ov_norm,
    odocoileus_virginianus_data %>%
      mutate(valeurs_norm = (valeurs - min(valeurs)) / (max(valeurs) - min(valeurs)))
  ),
  
  #Réalisation de la figure
  tar_target(
    fig3_ClOv,
    {
      png("figures/graph_ClOv.png", width = 800, height = 600)
      tracer_populations(Cl_norm, Ov_norm)
      dev.off()
      "figures/graph_ClOv.png"
    }
  ),
  
  #Section 5: Création du rapport finale avec Rmarkdown
  tar_render(
    rapport,
    path = "rapport/rapport.Rmd"
  )
)
