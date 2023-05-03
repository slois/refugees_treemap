# Load refugee data from 
load_refugee_data <- function(data_file){
  population <- read_csv(data_file, 
                         col_types = cols(`Country of origin` = col_skip(), 
                                          `Country of asylum` = col_skip(), 
                                          `Other people in need of international protection` = col_skip(), 
                                          `Host Community` = col_skip()), skip = 14)
  names(population) <- c("year", "iso_origin", "iso_asylum", "refugees_unhcr", "asylum_seekers", "idps_concern_unhcr", "stateless_persons", "others")
  return(population)
}

load_unsd_data <- function(data_file){
  unsd <- read_delim(data_file,
                     delim = ";", 
                     escape_double = FALSE, 
                     col_types = cols(`Least Developed Countries (LDC)` = col_skip(), 
                                      `Land Locked Developing Countries (LLDC)` = col_skip(), 
                                      `Small Island Developing States (SIDS)` = col_skip()), 
                     trim_ws = TRUE)
  names(unsd) <- c("global_code", "global_name", "region_code", "region_name", "subregion_code", "subregion_name", "intermediate_code", "intermediate_name", "country", "m49_code", "iso2_code", "iso3_code")
  return(unsd[,c("iso3_code", "country", names(unsd)[grep(pattern="_name", names(unsd))])])
}

code2name <- function(unsd, code){
  return(unsd[match(code, unsd$iso3_code), "country", drop=TRUE])
}

code2hierarchy <- function(unsd, code){
  return(unsd[match(code, unsd$iso3_code), c("global_name", "region_name", "subregion_name", "intermediate_name")])
}

prepare_data <- function(refugee, types='refugees_unhcr'){
  refugee <- refugee %>% filter(!is.na(country_origin))
  refugee$total <- apply(refugee[,types,drop=F], 1, sum)
  
  lv_0 <- refugee %>% 
    dplyr::group_by(country_asylum, country_origin) %>% 
    dplyr::summarize(value=sum(total)) %>% 
    dplyr::rename("item"="country_asylum", 
                  "parent"="country_origin") %>%
    tidyr::unite('item', parent:item, sep=" to ", remove=FALSE) %>%
    filter(value > 0) %>%
    as.data.frame()
  
  lv_1 <- refugee %>% 
    dplyr::group_by(country_origin, subregion_name) %>% 
    dplyr::summarize(value=sum(total)) %>% 
    dplyr::rename("item"="country_origin", 
                  "parent"="subregion_name") %>%
    filter(value > 0) %>%
    as.data.frame()
  
  lv_2 <- refugee %>% 
    dplyr::group_by(subregion_name, region_name) %>% 
    dplyr::summarize(value=sum(total)) %>% 
    dplyr::rename("item"="subregion_name", 
                  "parent"="region_name") %>%
    filter(value > 0) %>%
    as.data.frame()
  
  lv_3 <- refugee %>% 
    dplyr::group_by(region_name, global_name) %>% 
    dplyr::summarize(value=sum(total)) %>% 
    dplyr::rename("item"="region_name", 
                  "parent"="global_name") %>%
    filter(value > 0) %>%
    as.data.frame()
  
  dd <- rbind(lv_3, lv_2, lv_1, lv_0)
  return(dd)
}

plot_treemap <- function(data){
  tm <- plot_ly(data=data, 
                type="treemap",
                branchvalues="total",
                labels=~item, 
                values=~value, 
                parents=~parent,
                textinfo="label+value+percent parent+percent entry+percent root+text",
                marker=list(colorscale='Reds'))
  return(tm)
}



