#!/usr/bin/env Rscript

#-------------------------------------------------------------------------------------
# Funcion que recupera la informacion de los movimientos que cumplen las condiciones
#----------------------

retrieve_transactions <- function (my_searchId,
                                   my_accounts,
                                   my_since, my_until) {

  library(httr)
  library(jsonlite)

  if (my_searchId != '-') qf <-list( searchId = paste("searchID", my_searchId, sep = "=") )
  else {
    qf <- list( account = paste("account", my_accounts, sep = "="))

    qf_s <- list( since = paste("since", my_since, sep = "=") )
    qf_u <- list(until = paste("until", my_until, sep = "=") )

    if (my_since != '-') qf <- append(qf, qf_s )
    if (my_until != '-') qf <- append(qf, qf_u )
  }

  qf <- paste(qf, collapse = "&")
  url <- "http://poc-domesticayc:8080/domaycfeed/transactions/_scroll"
  url <- paste(url, qf, sep="?")

  trans_or <- GET(url)
  stop_for_status(trans_or)
  trans_or <- content(trans_or, "parsed", encoding = "UTF-8")

  return (trans_or)

}
