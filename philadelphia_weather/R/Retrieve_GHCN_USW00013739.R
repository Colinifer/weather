library(readr)
library(dplyr)
library(tidyr)


# station readme
#   https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_station/readme-by_station.txt

# data readme
#   https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt

# ghcnd invenctory
#   https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-inventory.txt

# ghcnd stations
#   https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt

# download the zipped file
station_id <- 'USW00013739' # PHILADELPHIA INTL AP

temp <- tempfile()
download.file(glue::glue("https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_station/{station_id}.csv.gz"),temp)

# unzip and read
ghcn <- read_csv(temp,
                 col_names = c("id", "yearmoda", "element", "value",
                               "mflag", "qflag", "sflag", "obs_time"),
                 col_types = "cccncccc")

# delete the zipped file
unlink(temp)

ghcn |> 
  filter(element %in% c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")) |> 
  select(element) |> 
  unique()

# subset and format
ghcn.wide <- ghcn %>%
  select(yearmoda, element, value) %>%
  filter(element %in% c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")) %>%
  separate(col = yearmoda, sep = c(4,6), into = c("year", "month", "day")) %>%
  pivot_wider(names_from = element, values_from = value) %>%
  # convert from tenths of mm to inches
  mutate(PRCP = PRCP * 0.00393701,
         SNOW = SNOW * 0.00393701,
         SNWD = SNWD * 0.00393701) %>%
  # convert from tenths of degrees C to F
  mutate(TMAX = ((TMAX / 10) * (9/5)) + 32,
         TMIN = ((TMIN / 10) * (9/5)) + 32) %>%
  mutate(date = as.Date(paste(year, month, day, sep = "-")),
         day_of_year = lubridate::yday(date)) %>%
  select(year, month, day, date, day_of_year, PRCP, SNOW, SNWD,
         TMAX, TMIN)

write_csv(x = ghcn.wide, 
          file = glue::glue("philadelphia_weather/data/GHCN_{station_id}.csv"))

