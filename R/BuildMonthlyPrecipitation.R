library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(lubridate)
library(stringr)
library(showtext)
library(jsonlite)
source('R/gg_theme.R')

# Load stations from the central JSON file
stations_df <- fromJSON("stations.json")
filter_year <- as.numeric(format(Sys.Date(), '%Y'))

for (i in 1:nrow(stations_df)) {
  station_id <- stations_df$id[i]
  station_name <- stations_df$name[i]
  
  message(glue::glue("Building Monthly Precipitation Totals for {station_name} ({station_id})..."))
  
  file_path <- glue::glue('data/GHCN_{station_id}.csv')
  
  if (!file.exists(file_path)) {
    warning(glue::glue("Data file {file_path} not found. Skipping."))
    next
  }

  ghcn <- read_csv(file_path, show_col_types = FALSE) |> 
    filter(year <= filter_year)

  # 1. Calculate total precipitation for each month in every year
  monthly_totals <- ghcn %>%
    group_by(year, month) %>%
    summarise(total_precip = sum(PRCP, na.rm = TRUE), .groups = "drop") %>%
    mutate(month_name = factor(month.abb[as.numeric(month)], levels = month.abb))

  year.to.plot <- max(monthly_totals$year)
  this.year <- monthly_totals %>% filter(year == year.to.plot)

  # 2. Historical summary stats
  monthly.summary.stats <- monthly_totals %>%
    filter(year != year.to.plot) %>%
    group_by(month_name) %>%
    summarise(max = max(total_precip, na.rm = T) * 1.15,
              min = min(total_precip, na.rm = T),
              x5 = quantile(total_precip, 0.05, na.rm = T),
              x20 = quantile(total_precip, 0.2, na.rm = T),
              x40 = quantile(total_precip, 0.4, na.rm = T),
              x60 = quantile(total_precip, 0.6, na.rm = T),
              x80 = quantile(total_precip, 0.8, na.rm = T),
              x95 = quantile(total_precip, 0.95, na.rm = T),
              .groups = "drop")

  # 3. Create the graph
  monthly.plot <- monthly.summary.stats %>%
    ggplot(aes(x = month_name)) +
    geom_linerange(aes(ymin = min, ymax = max, color = "Historical Range (Min-Max)"), lwd = 12, alpha = 0.6) +
    geom_linerange(aes(ymin = x5, ymax = x95, color = "5th-95th Percentile"), lwd = 12, alpha = 0.6) +
    geom_linerange(aes(ymin = x20, ymax = x80, color = "20th-80th Percentile"), lwd = 12, alpha = 0.6) +
    geom_linerange(aes(ymin = x40, ymax = x60, color = "40th-60th Percentile"), lwd = 12) +
    
    # Current year line and points
    geom_line(data = this.year, aes(y = total_precip, group = 1), color = "black", lwd = 1) +
    geom_point(data = this.year, aes(y = total_precip), color = "black", size = 2) +
    
    scale_color_manual(name = "Historical Range",
                       values = c("Historical Range (Min-Max)" = "#bdc9e1",
                                  "5th-95th Percentile" = "#74a9cf",
                                  "20th-80th Percentile" = "#2b8cbe",
                                  "40th-60th Percentile" = "#045a8d"),
                       breaks = c("Historical Range (Min-Max)", 
                                  "5th-95th Percentile", 
                                  "20th-80th Percentile", 
                                  "40th-60th Percentile")
                       ) +
    
    # Increased top expansion to ensure the inset legend doesn't overlap high bars
    scale_y_continuous(labels = scales::unit_format(suffix = " in."), 
                       expand = expansion(mult = c(0, 0.2))) +
    
    labs(title = paste("Monthly Precipitation Totals at", station_name),
         subtitle = paste("The black line shows totals for", year.to.plot, 
                          ". Colored bars show the historical range of past years."),
         caption = paste0("Data: NOAA Global Historical Climatology Network (GHCN-Daily). ",
                          "Bars show the monthly distribution from ", min(ghcn$year), 
                          " to ", year.to.plot - 1, ". ",
                          "Updated: ", format(Sys.Date(), "%B %d, %Y.")),
         x = NULL, y = NULL) +
    theme_cw_light +
    theme(panel.grid.major.x = element_blank(),
          # Inset Legend settings
          legend.position = c(0.98, 0.98),
          legend.justification = c("right", "top"),
          legend.background = element_blank(),
          legend.key = element_blank(),
          legend.text = element_text(size = 7),
          legend.title = element_text(size = 8, face = "bold"),
          legend.margin = margin(0, 0, 0, 0)) +
    # Thinner legend keys (lwd = 4) to make it look "tiny bit smaller"
    guides(color = guide_legend(override.aes = list(lwd = 4)))

  # Save the graph
  ggsave(glue::glue('graphs/MonthlyPrecipitationTotals_{station_id}_{filter_year}.png'), 
         plot = monthly.plot, width = 8, height = 4)
}