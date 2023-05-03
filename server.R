shinyServer(function(input, output){
  
  refugee_data <- reactive({
    refugee <- REFUGEE %>% filter(!is.na(country_origin) & year == input$year)
    prepare_data(refugee = refugee, types=input$refugee_types)
  })
  
  output$plot <- renderPlotly({
    plot_treemap(data=refugee_data())
  })
  
})