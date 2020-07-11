# Packages & Initialize Setup ---------------------------------------------

# Vignettes - https://cran.r-project.org/web/packages/rnoaa/vignettes
# Install GDAL - https://www.kyngchaos.com/software/frameworks/

pkgs <-
  c("tidyverse",
    "ggplot2",
    "rnoaa",
    "rgdal")

installed_packages <- pkgs %in%
  rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
invisible(lapply(pkgs, library, character.only = TRUE))


# API Setup ---------------------------------------------------------------

options(noaakey = "JoGQdxAFzjcEzDNlZluQzfZkHJfMexyE")

# NOAA Functions ----------------------------------------------------------

ncdc_locs(
  locationcategoryid = 'CITY',
  sortfield = 'name',
  sortorder = 'desc'
)
