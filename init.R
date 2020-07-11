# Packages & Initialize Setup ---------------------------------------------

pkgs <-
  c("tidyverse",
    "ggplot2",
    "rnoaa"
  )

installed_packages <- pkgs %in%
  rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
invisible(lapply(pkgs, library, character.only = TRUE))