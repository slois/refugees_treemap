shinyUI(fluidPage(
  # Application title
  titlePanel("Refugees and people in a refugee-like situation, excluding asylum-seekers, and changes by origin and country of asylum", 
             windowTitle = "Refugees migration"),
  fluidRow(
    column(10, 
           includeMarkdown("markdown/about.md")
    )
  ),
  div(p(strong("Author:"), "Sergio Lois", a(icon("linkedin"), href="http://www.linkedin.com/in/slois"))),
  div(p(strong("Code available at GitHub:"), a(icon("github"), href="https://github.com/slois/refugees_treemap"))),
  div(p(strong("Data source:"), "The UN Refugee Agency (UNHCR). Refugee Data Finder")),
  div(p(strong("License:"), "CC-BY-4.0")),
  hr(),
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Select year:",
                  min = min(REFUGEE$year), 
                  max = max(REFUGEE$year), 
                  value = 2022),
      checkboxGroupInput("refugee_types", 
                         "Population types:", 
                         c("Refugees"="refugees_unhcr", 
                           "Asylum-seekers"="asylum_seekers",
                           "IDPs of concern to UHNCR"="idps_concern_unhcr",
                           "Stateless people"="stateless_persons",
                           "Others concerns to UHNCR"="others"),
                         selected = c("refugees_unhcr"))
    ),
    mainPanel(
      # Create a new row for the table.
      plotlyOutput('plot',width = 1000, height=800)
    )
  )
))