library(readr)
library(dplyr)
library(tidyr)
library(glue)
library(jsonlite)

# Load stations from JSON
stations <- fromJSON("../stations.json")

for (i in 1:nrow(stations)) {
  station_id <- stations$id[i]
  station_name <- stations$name[i]
  
  message(glue("Downloading data for {station_name} ({station_id})..."))
  
  data_url <- glue("https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_station/{station_id}.csv.gz")

  # Download and unzip
  ghcn <- data.table::fread(data_url,
                            col.names = c("id", "yearmoda", "element", "value",
                                          "mflag", "qflag", "sflag", "obs_time"),
                            colClasses = list(character=c(1:3,5:8),
                                              numeric=4)) |>
    as_tibble()

  # Subset and format
  # ghcn.wide <- ghcn |>
  #   select(yearmoda, element, value) |>
  #   filter(element %in% c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")) |>
  #   separate(col = yearmoda, sep = c(4,6), into = c("year", "month", "day")) |>
  #   pivot_wider(names_from = element, values_from = value) |>
  #   # convert from tenths of mm to inches
  #   mutate(PRCP = PRCP * 0.00393701,
  #          SNOW = SNOW * 0.00393701,
  #          SNWD = SNWD * 0.00393701) |>
  #   # convert from tenths of degrees C to F
  #   mutate(TMAX = ((TMAX / 10) * (9/5)) + 32,
  #          TMIN = ((TMIN / 10) * (9/5)) + 32) |>
  #   mutate(date = as.Date(paste(year, month, day, sep = "-")),
  #          day_of_year = lubridate::yday(date)) |>
  #   select(year, month, day, date, day_of_year, PRCP, SNOW, SNWD,
  #          TMAX, TMIN)
  
  ghcn.wide <- ghcn |>
    select(yearmoda, element, value) |>
    filter(element %in% c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")) |>
    separate(col = yearmoda, sep = c(4,6), into = c("year", "month", "day")) |>
    pivot_wider(names_from = element, values_from = value)
  
  # 1. Ensure all columns exist (prevents crash if a station lacks an element entirely)
  missing_cols <- setdiff(c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN"), names(ghcn.wide))
  if(length(missing_cols) > 0) ghcn.wide[missing_cols] <- NA_real_
  
  # 2. Use coalesce and perform unit conversion
  ghcn.wide <- ghcn.wide |>
    mutate(
      # Coalesce precip/snow to 0 so cumulative sums don't turn into NA for the whole year
      PRCP = coalesce(PRCP, 0) * 0.00393701,
      SNOW = coalesce(SNOW, 0) * 0.00393701,
      SNWD = coalesce(SNWD, 0) * 0.00393701,
      
      # Keep TMAX/TMIN as NA if missing (0 is not a safe default for temp)
      TMAX = ((TMAX / 10) * (9/5)) + 32,
      TMIN = ((TMIN / 10) * (9/5)) + 32
    ) |>
    mutate(date = as.Date(paste(year, month, day, sep = "-")),
           day_of_year = lubridate::yday(date)) |>
    select(year, month, day, date, day_of_year, PRCP, SNOW, SNWD,
           TMAX, TMIN)

  # Save to data folder
  write_csv(x = ghcn.wide, 
            file = glue("data/GHCN_{station_id}.csv"))
}
