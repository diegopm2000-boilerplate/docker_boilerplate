#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
options(warn=-1)

#-----------------------------------------------------------------------------------------
# GENERACION DE ESTADISTICAS ASOCIADAS A LOS MOVIMIENTOS DE UN CONJUNTO DE CUENTAS
#---------------------------

#Cargamos en el entorno las librerias y funciones
suppressMessages(library(data.table))
suppressMessages(library(zoo))
suppressMessages(library(plyr))

source("extract_infoTrans_type1.R")

#-----------------------------------------------------------------------------------------
# Recuperacion de parametros de invocacion 
#----------------------------------

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default since and until
  args[2] <- "-"
}

var_account <- args[1]
var_until <- args[2]

#cat("numero de argumentos: ", length(args), "\n")
#cat("cuenta: ", var_account, "\n")
#cat("since: ", var_since, "\n")
#cat("until: ", var_until, "\n")


#-----------------------------------------------------------------------------------------
# Variables Globales
#--------------------

var_monthC <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dic")

input_month <- as.numeric(substr(var_until, 6, 7))
input_monthC <- var_monthC[[input_month]]
input_year <- substr(var_until, 1, 4)
input_day <- substr(var_until, 9, 10)
input_yearMonth <- as.numeric(paste(input_year, sprintf("%02d", input_month), sep=""))
input_yearPrev <- as.numeric(input_year) - 1
input_yearMonthPrev <- ifelse (input_month==1, 
                               as.numeric(paste(input_yearPrev, "12", sep="")),
                               input_yearMonth - 1)
input_yearPrevMonth <- paste(input_yearPrev, sprintf("%02d", input_month), sep="")

var_minyearMonth <- paste(input_year, "01", sep="")

var_since <- paste(input_yearPrev, sprintf("%02d", input_month), "01", sep="-")


#-----------------------------------------------------------------------------------------
# Recuperacion de los datos origen
#----------------------------------

dt_movc <- extract_infoTrans_type1(var_account, var_since, var_until)

#-----------------------------------------------------------------------------------------
# Transformaciones
#------------------

#---------------------------------------------------------------------------------
# neutralizamos los traspasos entre cuentas que se tienen en cuenta en el analisis

dt_movc$id <- rownames(dt_movc)

tmp_movc <- dt_movc
setorder(tmp_movc, valueDate)
tmp_movc$dateAmount <- paste(tmp_movc$valueDate, abs(tmp_movc$amount), sep="/")
tmp_movc <- merge(tmp_movc[amount>0,.(id,dateAmount, accountId, amount)],
                  tmp_movc[amount < 0,.(id,dateAmount, accountId, amount)],
                  by="dateAmount")
tmp_movc <- tmp_movc[(accountId.x != accountId.y & amount.x == -amount.y),]

lt_ids <- append(tmp_movc$id.x, tmp_movc$id.y)
dt_movc <- dt_movc[!id %in% lt_ids,]
dt_movc$id <- NULL
#------------------------------------------------------------------------------

dt_movc$year <- substr(dt_movc$valueDate, 1, 4) 
dt_movc$month <- as.numeric(substr(dt_movc$valueDate, 6, 7))
dt_movc$monthC <- lapply(dt_movc$month, function(x) {return (var_monthC[[x]])})
dt_movc$yearMonth <- as.numeric(paste(dt_movc$year, sprintf("%02d", dt_movc$month), sep=""))

dt_movc$day <- substr(dt_movc$valueDate, 9, 10)

dt_movc$monthC <- unlist(dt_movc$monthC)


dt_movc$incomes<- dt_movc$amount
dt_movc$expenses <- dt_movc$amount
dt_movc[transType1 == "Gasto", c("incomes", "transType1") := list(0, "expense")]
dt_movc[transType1 == "Ingreso",  c("expenses", "transType1") := list(0, "income")]


# ordenamos por fecha de movimiento

setorder(dt_movc, valueDate)

#-----------------------------------------------------------------------------------------
#Nuevo data_table con informacion mensual, meses completos
#----------------------------------------------------------

dt_infoMes <- dt_movc[yearMonth==input_yearMonth,]

dt_infoMes[, c("incomesMonth", "expensesMonth") :=
             list( sum(incomes), sum(expenses)),
           by=.(yearMonth)]

dt_infoMes[, c("amountMonth", 
               "detTrans_accountId", "detTrans_valueDate", "detTrans_amount", "detTrans_concept") :=
             list( sum(amount), list(paste("'",accountId,"'", sep="")),
                   list(valueDate), list(amount), 
                   list(paste("'",description,"'", sep=""))),
           by=.(yearMonth, transType1, transType2)]

dt_infoMes$detTrans_accountId <- sapply(dt_infoMes$detTrans_accountId,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_valueDate <- sapply(dt_infoMes$detTrans_valueDate,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_amount <- sapply(dt_infoMes$detTrans_amount,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_concept <- sapply(dt_infoMes$detTrans_concept,function(x) paste(unlist(x),collapse="|"))

dt_infoMes <- unique(dt_infoMes[,.(year, yearMonth, month, monthC, transType1, transType2, 
                                   amountMonth, incomesMonth, expensesMonth,
                                   detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)])

# Generamos informacion de desglose de ingresos/gastos en un unico registro
dt_infoMesTmp<- dcast(dt_infoMes, 
                   yearMonth~transType1+transType2, value.var = c("amountMonth"), fun.aggregate=sum)

dt_infoMesDef <- merge(unique(dt_infoMes[,.(year, yearMonth, month, monthC, 
                                            incomesMonth, expensesMonth)]),
                    dt_infoMesTmp,
                    by="yearMonth")

dt_infoMes$newType <- with(dt_infoMes, paste(transType1, transType2, sep="_"))
dt_infoMes <- dt_infoMes[,.(yearMonth, newType,
                            detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)]

dt_infoMesNew <- reshape(dt_infoMes,
                         idvar="yearMonth", timevar = "newType",
                         direction="wide")

dt_infoMesDef <- merge(dt_infoMesDef,
                       dt_infoMesNew,
                       by="yearMonth")

#-----------------------------------------------------------------------------------------
#Nuevo data_table con informacion del mismo periodo año anterior
#--------------------------------------------------------------------------------------

dt_infoMes <- dt_movc[yearMonth==input_yearPrevMonth,]

dt_infoMes[, c("incomesMonth", "expensesMonth") :=
             list( sum(incomes), sum(expenses)),
           by=.(yearMonth)]

dt_infoMes[, c("amountMonth", 
               "detTrans_accountId", "detTrans_valueDate", "detTrans_amount", "detTrans_concept") :=
             list( sum(amount), list(paste("'",accountId,"'", sep="")),
                   list(valueDate), list(amount), 
                   list(paste("'",description,"'", sep=""))),
           by=.(yearMonth, transType1, transType2)]

dt_infoMes$detTrans_accountId <- sapply(dt_infoMes$detTrans_accountId,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_valueDate <- sapply(dt_infoMes$detTrans_valueDate,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_amount <- sapply(dt_infoMes$detTrans_amount,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_concept <- sapply(dt_infoMes$detTrans_concept,function(x) paste(unlist(x),collapse="|"))

dt_infoMes <- unique(dt_infoMes[,.(year, yearMonth, month, monthC, transType1, transType2, 
                                   amountMonth, incomesMonth, expensesMonth,
                                   detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)])

# Generamos informacion de desglose de ingresos/gastos en un unico registro
dt_infoMesTmp<- dcast(dt_infoMes, 
                      yearMonth~transType1+transType2, value.var = c("amountMonth"), fun.aggregate=sum)

dt_infoMesPrevDef <- merge(unique(dt_infoMes[,.(year, yearMonth, month, monthC, 
                                            incomesMonth, expensesMonth)]),
                       dt_infoMesTmp,
                       by="yearMonth")

dt_infoMes$newType <- with(dt_infoMes, paste(transType1, transType2, sep="_"))
dt_infoMes <- dt_infoMes[,.(yearMonth, newType,
                            detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)]

dt_infoMesNew <- reshape(dt_infoMes,
                         idvar="yearMonth", timevar = "newType",
                         direction="wide")

dt_infoMesPrevDef <- merge(dt_infoMesPrevDef,
                       dt_infoMesNew,
                       by="yearMonth")

#-----------------------------------------------------------------------------------------
#Nuevo data_table con informacion anual
#------------------------------------------

dt_infoMes <- dt_movc[year==input_year,]

dt_infoMes[, c("incomes", "expenses") :=
             list( sum(incomes), sum(expenses)),
           by=.(year)]

dt_infoMes[, c("amount", 
               "detTrans_accountId", "detTrans_valueDate", "detTrans_amount", "detTrans_concept") :=
             list( sum(amount), list(paste("'",accountId,"'", sep="")),
                   list(valueDate), list(amount), 
                   list(paste("'",description,"'", sep=""))),
           by=.(year, transType1, transType2)]

dt_infoMes$detTrans_accountId <- sapply(dt_infoMes$detTrans_accountId,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_valueDate <- sapply(dt_infoMes$detTrans_valueDate,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_amount <- sapply(dt_infoMes$detTrans_amount,function(x) paste(unlist(x),collapse="|"))
dt_infoMes$detTrans_concept <- sapply(dt_infoMes$detTrans_concept,function(x) paste(unlist(x),collapse="|"))

dt_infoMes <- unique(dt_infoMes[,.(year, transType1, transType2, 
                                   amount, incomes, expenses,
                                   detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)])

# Generamos informacion de desglose de ingresos/gastos en un unico registro
dt_infoMesTmp<- dcast(dt_infoMes, 
                      year~transType1+transType2, value.var = c("amount"), fun.aggregate=sum)

dt_infoAnnioDef <- merge(unique(dt_infoMes[,.(year, incomes, expenses)]),
                      dt_infoMesTmp,
                      by="year")

dt_infoMes$newType <- with(dt_infoMes, paste(transType1, transType2, sep="_"))
dt_infoMes <- dt_infoMes[,.(year, newType,
                            detTrans_accountId, detTrans_valueDate, detTrans_amount, detTrans_concept)]

dt_infoAnnioNew <- reshape(dt_infoMes,
                         idvar="year", timevar = "newType",
                         direction="wide")

dt_infoAnnioDef <- merge(dt_infoAnnioDef,
                           dt_infoAnnioNew,
                           by="year")

#-----------------------------------------------------------------------------------------
#Creamos la salida
#------------------------------------------

cabecera <- "{\"typeTrans_stats\": {"
cab_infoMes <- "\"monthStats\": "
cab_infoPartialMes <- "\"previousMonthStats\": "
cab_infoAnnio <- "\"yearStats\": "
fin <- "}}"
json_infoMes <- toJSON(dt_infoMesDef, pretty=FALSE)
json_infoPreviousMonth <- toJSON(dt_infoMesPrevDef, pretty=FALSE)
json_infoAnnio <- toJSON(dt_infoAnnioDef, pretty=FALSE)

cat(cabecera, cab_infoMes, json_infoMes, ",", cab_infoPartialMes, json_infoPreviousMonth, ",", cab_infoAnnio, json_infoAnnio, fin)

