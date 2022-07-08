
extrafont::loadfonts(quiet = TRUE)

color_cw <-
  c(
    "#1D2329",
    "#2C343A",
    "#38424B",
    "#16191C",
    "#e0e0e0",
    "#1AB063",
    "#0580DC",
    "#D64964",
    "#959595"
  )  


# main cw theme
theme_cw_dark <-  theme(
  line = element_line(lineend = 'round', color = color_cw[1]),
  text = element_text(family = "Montserrat", color = color_cw[5]),
  plot.background = element_rect(fill = color_cw[1], color = 'transparent'),
  panel.border = element_rect(color = color_cw[1], fill = NA),
  panel.background = element_rect(fill = color_cw[2], color = 'transparent'),
  axis.ticks = element_line(color = color_cw[5], size = 0.5),
  axis.ticks.length = unit(2.75, 'pt'),
  axis.title = element_text(family = "Chivo", face = "bold", size = 8),
  axis.title.y = element_text(angle = 90, vjust = 0.5),
  axis.text = element_text(size = 7, color = color_cw[5]),
  plot.title = element_text(family = "Chivo", face = "bold", size = 14),
  plot.subtitle = element_text(size = 8),
  plot.caption = element_text(family = "Montserrat", size = 5),
  legend.background = element_rect(fill = color_cw[2], color = color_cw[5]),
  legend.key = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(color = color_cw[4], size = 0.3),
  strip.background = element_rect(fill = color_cw[3]),
  strip.text = element_text(size = 6, color = color_cw[5], family = "Chivo"),
  legend.position = 'bottom',
  panel.spacing.y = unit(0, 'lines'),
  panel.spacing.x = unit(0.1, 'lines')
)

theme_cw_light <-  theme(
  line = element_line(lineend = 'round', color = color_cw[5]),
  text = element_text(family = "Montserrat", color = color_cw[1]),
  plot.background = element_rect(fill = '#fcfcfc', color = 'transparent'),
  panel.border = element_rect(color = color_cw[5], fill = NA),
  panel.background = element_rect(fill = color_cw[5], color = 'transparent'),
  axis.ticks = element_line(color = color_cw[1], size = 0.5),
  axis.ticks.length = unit(2.75, 'pt'),
  axis.title = element_text(family = "Chivo", face = "bold", size = 8, color = color_cw[3]),
  axis.title.y = element_text(angle = 90, vjust = 0.5),
  axis.text = element_text(size = 7, color = color_cw[1]),
  plot.title = element_text(family = "Chivo", face = "bold", size = 14),
  plot.subtitle = element_text(size = 8, color = color_cw[3]),
  plot.caption = element_text(family = "Montserrat", size = 5),
  legend.background = element_rect(fill = color_cw[5], color = color_cw[5]),
  legend.key = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(color = '#fcfcfc', size = 0.3),
  strip.background = element_rect(fill = color_cw[5]),
  strip.text = element_text(size = 6, color = color_cw[3], family = "Chivo"),
  legend.position = 'bottom',
  panel.spacing.y = unit(0, 'lines'),
  panel.spacing.x = unit(0.1, 'lines')
)
