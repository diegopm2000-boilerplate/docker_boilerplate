#!/usr/bin/env Rscript

#-------------------------------------------------------------------------------------
# Funcion que extrae los datos de interes
#----------------------
# 
extract_infoTrans_type1 <- function (my_account, my_since, my_until) {
    
  source("retrieve_transactions.R")
  
  extract_rawinfo <- function (my_lista) {
    res <- list()
    # obtenemos los datos basicos
    
    res$accountId <- my_lista$`_source`$transaction$accountId
    res$valueDate <- my_lista$`_source`$transaction$valueDate
    res$amount <- my_lista$`_source`$transaction$amount
    res$finalBalance <- my_lista$`_source`$transaction$finalBalance
    res$description <- my_lista$`_source`$transaction$description
    res$transType1 <- my_lista$`_source`$transaction$typology$typeLevel1$es
    res$transType2 <- my_lista$`_source`$transaction$typology$typeLevel2$es
    res$transType3 <- my_lista$`_source`$transaction$typology$typeLevel3$es
    
    return (res)
  }
  
  var_searchId <- "-"
  
  data_load <- list()
  i <- 0
  var_iter <- 1
  while (var_iter == 1) {
    i <- i + 1
    data_input <- retrieve_transactions(var_searchId,
                                        my_account,
                                        my_since,
                                        my_until)
    
    var_searchId <- data_input$"_scroll_id"
    
    res <- lapply(data_input$hits$hits, extract_rawinfo)
    
    res_1 <- t(as.data.table(res))
    ifelse (nrow(res_1) == 0, var_iter <- 0, data_load <- rbind(data_load, res_1))
    
  }
  
  fdt_movc <- as.data.table(data_load)
  colnames(fdt_movc) <- c("accountId", "valueDate", "amount", "finalBalance", "description", 
                          "transType1", "transType2", "transType3")
  fdt_movc$accountId <- unlist(fdt_movc$accountId)
  fdt_movc$valueDate <- unlist(fdt_movc$valueDate)
  fdt_movc$amount <- unlist(fdt_movc$amount)
  fdt_movc$finalBalance <- unlist(fdt_movc$finalBalance)
  fdt_movc$description <- unlist(fdt_movc$description)
  fdt_movc$transType1 <- unlist(fdt_movc$transType1)
  fdt_movc$transType2 <- unlist(fdt_movc$transType2)
  fdt_movc$transType3 <- unlist(fdt_movc$transType3)
  return(fdt_movc)  

}
