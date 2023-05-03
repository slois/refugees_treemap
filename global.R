library(shiny)
library(readr)
library(plotly)
library(markdown)

source("helper.R")

REFUGEE_DATA <- "data/query_data/population.csv"
UNSD_DATA <- "data/UNSD — Methodology.csv"

REFUGEE <- load_refugee_data(REFUGEE_DATA)
UNSD <- load_unsd_data(UNSD_DATA)

REFUGEE$country_origin <- code2name(UNSD, REFUGEE$iso_origin)
REFUGEE$country_asylum <- code2name(UNSD, REFUGEE$iso_asylum)
REFUGEE <- cbind(REFUGEE, code2hierarchy(UNSD, REFUGEE$iso_origin))
