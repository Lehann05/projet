
traiter_coords_geom <- function(df, geom_col = "geom") {
  separer_coords <- function(coords) {
    coords_clean <- gsub("MULTIPOINT\\(|\\)", "", coords)
    coords_clean <- gsub("\\s+", " ", coords_clean)
    coords_clean <- gsub("\\(|\\)", "", coords_clean)
    split_coords <- strsplit(coords_clean, " ")[[1]]
    
    if (length(split_coords) == 2) {
      longitude <- as.numeric(split_coords[1])
      latitude  <- as.numeric(split_coords[2])
      if (is.na(longitude) | is.na(latitude)) return(c(NA, NA))
      return(c(longitude, latitude))
    } else {
      return(c(NA, NA))
    }
  }
  
  coords_list <- lapply(df[[geom_col]], separer_coords)
  
  df$longitude <- sapply(coords_list, `[`, 1)
  df$latitude  <- sapply(coords_list, `[`, 2)
  df[[geom_col]] <- NULL
  
  return(df)
}


