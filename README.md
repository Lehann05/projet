# projet
Travail de session
├── data                  # Dossier de données
│   ├── 1 à 267.csv       # Jeux de données
│   └── taxonomie.csv     # Jeu de données
│ 
├── R                     # Dossier de scripts R
│   ├── Unnest.R          # Fonction utilisée comme targets, sert à séparé les colonnes years et valeurs
│   ├── Positif.R         # Fonction utilisée comme targets, s'assure qu'il y a juste des chiffres positifs
│   ├── Null.R            # Fonction utilisée comme targets, remplace les cases vide pas des NA
│   ├── Separe_geom.R     #Fonction utilisée comme targets, separe les données géographiques
│   ├── Combine.R         #Fonction utilisée comme targets, combine les csv et corrige les noms des colonnes
│   ├── Cor_geom.R        #Fonction utilisée comme targets, la colonne géométrie devient la colonne geom
│   ├── Cor_licence.R     #Fonction utilisée comme targets, corrige la colonne lisence pour devenir la colonne licence
│   ├── Creer_table.R     #Fonction utilisée comme targets, créer les tables de donnée SQL et injecter les données correspondantes
│   ├── Division_table.R  #Fonction utilisée comme targets, créer les tables de données pour les SQL
│   ├── enl_col_vide.R    #Fonction utilisée comme targets, enlève les colonnes qui contiennent seulement des NA
│   ├── open_corr.R       #Fonction utilisée comme targets, corrige les noms de colonnes
│   └── ScriptTout.R      #Script principal, à utiliser en cas de bug dans target
│ 
├── _targets.R            # Fichier targets qui définit le pipeline
│ 
├── rapport/
│   ├── rapport.Rmd
│   └── rapport.html
│ 
├── .gitignore
│
└── README.md
