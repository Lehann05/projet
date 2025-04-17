# Définir le directory

# Ouvrir les bibliothèques nécessaires 
library(tidyr)
library(dplyr)
library(RSQLite)
library(rlang)

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

# Modifier le nom de la colonne order dans taxonomie, parce qu'il est problématique 
# Prendre le bon directory 
taxonomie <- read.csv('series_temporelles/taxonomie.csv')

colnames(taxonomie)[colnames(taxonomie) == "order"] <- "taxo_order"


# Utiliser la fonction qui combine les csv (sauf taxonomie)
# Étape 1 - Combiner
combiner_csv(dossier_principal = "./series_temporelles", 
             exclusion = "taxonomie.csv", 
             nom_sortie = "dossier_comb.csv")

dossier_comb <- read.csv('dossier_comb.csv')


# Étape 2 - Corriger geom
donnees_comb <- corriger_geom(dossier_comb)

# Étape 3 - Corriger license
donnees_comb <- corriger_license(donnees_comb)

# Étape 4 - Enlever les colonnes vides
donnees_comb <- enlever_colonnes_vides(donnees_comb)

# Étape 5 -Unnest les colonnes years et values

donnees_comb <- unnest_col(donnees_comb, 'years', 'values') 

# Étape 6 - Valider

View(donnees_comb)

# Vérifier que tout est positifs (sauf les données géographique)
donnees_comb <- justePositif(donnees_comb)
  
# Transformer les null en NA
donnees_comb <- NoNull(donnees_comb)

# Gérer les données géom (séparation des latitudes et des longitudes)
# Utiliser la fonction separer_coords. Ajout d'une barre de progression
coords_list <- pblapply(donnees_comb$geom, separer_coords)

# Créer la colonne longitude et latitude
donnees_comb$longitude <- sapply(coords_list, `[`, 1)
donnees_comb$latitude  <- sapply(coords_list, `[`, 2)

# Enlever la colonne geom 
donnees_comb$geom <- NULL

# Modification du nom de la colonne values parce qu'elle cause problème aussi 

colnames(donnees_comb)[colnames(donnees_comb) == "values"] <- "valeurs"

#Séparation de la table "donnees_comb" en 3 dataframes distincts pour analyse
#1ere table -> dataframe taxonomie_inject
taxonomie_inject <- taxonomie 

#2e table -> sources à partir de donnees_comb
sources_int <- division_table(donnees_comb, c('original_source', 'title', 'publisher', 'license', 'owner')) #séparer les colonnes voulues du dataframe
sources_inject <- sources_int %>% distinct() #enlever les lignes dupliquées (owner, license, publisher et original_source toujours similaire pour un même)

#3e table -> abondance à partir de donnees_comb
abondance_inject <- division_table(donnees_comb, c('observed_scientific_name', 'years', 'unit', 'valeurs', 'title', 'longitude', 'latitude'))



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
    taxo_order                  VARCHAR(35),
    family                      VARCHAR(35),
    genus                       VARCHAR(35),
    species                     VARCHAR(55),
    PRIMARY KEY(observed_scientific_name)
  );"

#2.2. sources
creer_sources <- 
  "CREATE TABLE sources(
    title                   VARCHAR(500) PRIMARY KEY, 
    original_source         VARCHAR(50),
    publisher               VARCHAR(100),
    license                 VARCHAR(50),
    owner                   VARCHAR(100)
  );"

#2.3. abondance
creer_abondance <-
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

#3. Création et injection des données dans les tables avec fonction creer_table
#3.1. taxonomie
creer_table(con, creer_taxo, "taxonomie", taxonomie_inject)

#3.2. sources
creer_table(con, creer_sources, "sources", sources_inject)

#3.3. abondance
creer_table(con, creer_abondance, "abondance", abondance_inject)

#Aller chercher les données utiles concernant les coyotes

canis_lupus_data <- dbGetQuery(con, "
  SELECT years, valeurs, observed_scientific_name, latitude, longitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Canis lupus'
  ORDER BY years ASC;
")

View(canis_lupus_data)

#Aller chercher les données utiles concernant les cerfs de Virginie 
odocoileus_virginianus_data <- dbGetQuery(con, "
  SELECT years, valeurs, observed_scientific_name, latitude, longitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Odocoileus virginianus'
   AND unit IN ('Number of individuals')
   AND years BETWEEN 1983 AND 2001
  ORDER BY years ASC;
")

View(odocoileus_virginianus_data)

#Calculer la moyenne des valeurs par année pour Canis lupus 
Cl_moyenne <- dbGetQuery(con, "
  SELECT observed_scientific_name, years, AVG(CAST(valeurs AS REAL)) AS moyenne_valeurs, longitude, latitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Canis lupus'
  GROUP BY years
  ORDER BY years ASC;
")

View(Cl_moyenne)



ggplot(Cl_moyenne, aes(x = years, y = moyenne_valeurs)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "darkblue", size = 2) +
  labs(
    title = "Moyenne annuelle des observations de Canis lupus",
    x = "Année",
    y = "Valeur moyenne"
  ) +
  theme_minimal()

ggplot(odocoileus_virginianus_data, aes(x = years, y = valeurs)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "darkblue", size = 2) +
  labs(
    title = "Observations annuelles de cerfs de virginie",
    x = "Année",
    y = "Valeur"
  ) +
  theme_minimal()


#Premier essai pour le troisième graphique 

# On définit un facteur d’échelle pour ramener les valeurs des cerfs sur l’échelle des loups
facteur <- max(odocoileus_virginianus_data$valeurs) / max(Cl_moyenne$moyenne_valeurs)

# Fusion des deux pour faire un seul graphique (si utile pour la légende)
ggplot() +
  # Série des cerfs
  geom_line(data = odocoileus_virginianus_data,
            aes(x = years, y = valeurs / facteur, color = "Odocoileus virginianus"),
            size = 1) +
  geom_point(data = odocoileus_virginianus_data,
             aes(x = years, y = valeurs / facteur, color = "Odocoileus virginianus"),
             size = 2) +
  
  # Série des loups
  geom_line(data = Cl_moyenne,
            aes(x = years, y = moyenne_valeurs, color = "Canis lupus"),
            size = 1) +
  geom_point(data = Cl_moyenne,
             aes(x = years, y = moyenne_valeurs, color = "Canis lupus"),
             size = 2) +
  
  scale_y_continuous(
    name = "Nombre de loups",
    sec.axis = sec_axis(~ . * facteur, name = "Nombre de cerfs de Virginie")
  ) +
  scale_color_manual(values = c("Canis lupus" = "darkblue", "Odocoileus virginianus" = "steelblue")) +
  labs(
    title = "Évolution des populations : Loups et Cerf de Virginie",
    x = "Année",
    color = "Espèce"
  ) +
  theme_minimal()

#2e essai pour le dernier graphique 
library(dplyr)
library(ggplot2)

# Normalisation
Cl_moyenne_norm <- Cl_moyenne %>%
  mutate(valeurs_norm = (moyenne_valeurs - min(moyenne_valeurs)) /
           (max(moyenne_valeurs) - min(moyenne_valeurs)))

cerf_norm <- odocoileus_virginianus_data %>%
  mutate(valeurs_norm = (valeurs - min(valeurs)) /
           (max(valeurs) - min(valeurs)))

# Fusion (optionnel mais pratique pour ggplot avec une légende)
Cl_moyenne_norm$espece <- "Canis lupus"
cerf_norm$espece <- "Odocoileus virginianus"

donnees_norm <- bind_rows(
  Cl_moyenne_norm %>% select(years, valeurs_norm, espece),
  cerf_norm %>% select(years, valeurs_norm, espece)
)

# Graphique
ggplot(donnees_norm, aes(x = years, y = valeurs_norm, color = espece)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "Évolution normalisée des populations",
    x = "Année",
    y = "Valeurs normalisées",
    color = "Espèce"
  ) +
  theme_minimal()


#Se déconnecter de la connection avec dbDisconnect() si pas d'analyse, SVP
dbDisconnect(con)
