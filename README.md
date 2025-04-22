Travail de session
 ├── series_temporelles    # Dossier de données
 │   ├── 1 à 267.csv       # Jeux de données
 │   └── taxonomie.csv     # Jeu de données
 │ 
 │   ├── division_table.R  #Fonction utilisée comme targets, créer les tables de données pour les SQL
 │   ├── enl_col_vide.R    #Fonction utilisée comme targets, enlève les colonnes qui contiennent seulement des NA
 │   ├── open_corr.R       #Fonction utilisée comme targets, corrige les noms de colonnes
 │   ├── tracer_pop.R      #Fonction utilisée comme targets, permet de tracer le graphique combinant les loups et les cerfs 
 │   ├── Combine.R         #Fonction utilisée comme targets, permet d'ouvrir et de combiner les csv 
 │   ├── Cor_geom.R        #Permet de fusionner la colonne geometry à la colonne geom. 
 │   ├── Cor_license.R     #Permet de fusionner la colonne lisense à la colonne license 
 │   ├── creer_table.R     #Fonction utilisée comme targets, permet de créer les tables à injecter dans SQL 
 │   ├── Null.R            #Fonction utilisée comme targets, permet de transformer les valeurs nulles en NA 
 │   ├── Positif.R         #Fonction utilisée comme targets, permet de s'assurer que les valeurs sont positives 
 │   ├── Separe_geom.R     #Fonction utilisée comme targets, permet de prendre la colonne geom et de la séparer en latitude et longitude. Tout en enlevant le superflu 
 │   ├── Unnest.R          #Fonction utilisée comme targets, permet de séparer les listes en valeurs uniques (une rangée par valeur) 
 │   └── ScriptTout.R      #Script principal, à utiliser en cas de bug dans target
 │ 
 ├── _targets.R            # Fichier targets qui définit le pipeline
 │ 
 ├── figures               # Fichier où les graphiques sont enregistrés 
 │ 
 ├── rapport/
 │   ├── rapport.Rmd
 │   ├── BIO500 rapport.bib
 │   └── rapport.html
 │ 
 ├── .gitignore
 │
 └── README.md
