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
  message(glue::glue("Processing {station_name} ({station_id})..."))
  
  # Construct the file path
  file_path <- glue::glue('data/GHCN_{station_id}.csv')
  
  # Check if data file exists before processing
  if (!file.exists(file_path)) {
    warning(glue::glue("Data file not found for {station_id}. Skipping."))
    next
  }

  ghcn <- read_csv(file_path, show_col_types = FALSE) |> 
    filter(year <= filter_year) |> 
    group_by(year) |> 
    arrange(day_of_year) |> 
    mutate(cum_precip = cumsum(PRCP)) |> 
    ungroup()

  year.to.plot <- max(ghcn$year)
  last.date <- max(ghcn$date)
  start.date <- min(ghcn$date)

  this.year <- ghcn %>% filter(year == year.to.plot)
  past.years <- ghcn %>% group_by(year) %>% filter(n() > 300) %>% ungroup()

  daily.summary.stats <- past.years %>%
    filter(year != year.to.plot) %>%
    select(day_of_year, cum_precip) %>%
    group_by(day_of_year) %>%
    summarise(max = max(cum_precip, na.rm = T),
              min = min(cum_precip, na.rm = T),
              x5 = quantile(cum_precip, 0.05, na.rm = T),
              x20 = quantile(cum_precip, 0.2, na.rm = T),
              x40 = quantile(cum_precip, 0.4, na.rm = T),
              x60 = quantile(cum_precip, 0.6, na.rm = T),
              x80 = quantile(cum_precip, 0.8, na.rm = T),
              x95 = quantile(cum_precip, 0.95, na.rm = T)) %>%
    ungroup()

  # month breaks
  month.breaks <- ghcn %>%
    filter(year == filter_year - 1) %>%
    group_by(month) %>%
    slice_min(order_by = day_of_year, n = 1) %>%
    ungroup() %>%
    select(month, day_of_year) %>%
    mutate(month_name = month.abb)

  # pctile labels
  pctile.labels <- daily.summary.stats %>% 
    filter(day_of_year == 365) %>% 
    pivot_longer(cols = -day_of_year, names_to = "pctile", values_to = "precip") %>% 
    mutate(pctile = ifelse(str_sub(pctile, 1, 1) == "x", 
                           paste0(str_sub(pctile, 2, -1), "th"), pctile))

  cum.precip.graph <- daily.summary.stats %>%
    filter(day_of_year < 366) %>%
    ggplot(aes(x = day_of_year)) +
    geom_vline(xintercept = c(month.breaks$day_of_year, 365), linetype = "dotted", lwd = 0.2) +
    geom_ribbon(aes(ymin = min, ymax = max), fill = "#bdc9e1") +
    geom_ribbon(aes(ymin = x5, ymax = x95), fill = "#74a9cf") +
    geom_ribbon(aes(ymin = x20, ymax = x80), fill = "#2b8cbe") +
    geom_ribbon(aes(ymin = x40, ymax = x60), fill = "#045a8d") +
    geom_hline(yintercept = seq(0, 50, 5), color = "white", lwd = 0.1) +
    geom_line(data = this.year, aes(y = cum_precip), lwd = 1.2) +
    ggrepel::geom_label_repel(data = filter(this.year, day_of_year == max(day_of_year)),
                              aes(y = cum_precip, label = round(cum_precip, 1)),
                              point.padding = 5, direction = "y", alpha = 0.5) +
    geom_segment(data = pctile.labels, aes(x = 365, xend = 367, y = precip, yend = precip)) +
    geom_text(data = pctile.labels, aes(367.5, precip, label = pctile),
              hjust = 0, family = "Montserrat", size = 3) +
    scale_y_continuous(breaks = seq(-10, 100, 10), labels = scales::unit_format(suffix = "in."),
                       expand = expansion(0.01), name = NULL) +
    scale_x_continuous(expand = expansion(c(0, 0.04)), breaks = month.breaks$day_of_year + 15,
                       labels = month.breaks$month_name, name = NULL) +
    labs(title = paste("Cumulative annual precipitation at", station_name),
         subtitle = paste("The line shows precipitation for", lubridate::year(last.date), 
                          "The ribbons cover the historical range. The last date shown is", 
                          format(last.date, "%b %d, %Y.")),
         caption = paste("Records begin on", format(start.date, "%B %d, %Y."),
                         "Updated on", format(Sys.Date(), "%B %d, %Y."))) +
    theme_cw_light + 
    theme(panel.background = element_blank(), panel.border = element_blank(),
          panel.grid = element_blank(), plot.title.position = "plot",
          plot.title = element_text(face = "bold", size = 16), axis.ticks = element_blank())

  # Save the graph
  ggsave(glue::glue('graphs/AnnualCumulativePrecipitation_{station_id}_{filter_year}.png'), 
         plot = cum.precip.graph, width = 8, height = 4)
}
