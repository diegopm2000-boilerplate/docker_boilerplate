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
  args[3] <- "-"
} else if (length(args) == 2) { args[3] <- "-"}

var_account <- args[1]
var_until <- args[2]
var_since <- args[3]

#cat("numero de argumentos: ", length(args), "\n")
#cat("cuenta: ", var_account, "\n")
#cat("since: ", var_since, "\n")
#cat("until: ", var_until, "\n")

var_initialBalance <- (3381.71+19274.11)*0.2813

dt_movc <- extract_infoTrans_type1(var_account, var_since, var_until)

#-----------------------------------------------------------------------------------------
# Variables Globales
#--------------------
var_monthC <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dic")

if (var_until=="-") { var_until <- as.character(Sys.Date())}

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
dt_movc$period <- lapply(as.numeric(dt_movc$day), function(x) { return (min(trunc((x-1)/5+1, 0),6)) })

dt_movc$monthC <- unlist(dt_movc$monthC)
dt_movc$period <- unlist(dt_movc$period)

dt_movc$incomes<- dt_movc$amount
dt_movc$expenses <- dt_movc$amount
dt_movc[transType1 == "Gasto", incomes := 0]
dt_movc[transType1 == "Ingreso",  expenses := 0]

# ordenamos por fecha de movimiento

setorder(dt_movc, valueDate)

#-----------------------------------------------------------------------------------------
# Nuevo data_table con información diaria
#-----------------------------------------

dt_infoDia <- dt_movc[]
dt_infoDia[, c("incomesDay", "expensesDay") :=
               list(sum(incomes), sum(expenses)), 
             by=valueDate]

dt_infoDia <- unique(dt_infoDia[,.(valueDate, year, yearMonth, month, monthC, day, period, incomesDay, expensesDay)])

# Variables asociadas al saldo

calcula_saldoIni = function (d) {
  var_saldoOld <- var_saldo
  var_saldo <<- var_saldo + d
  return (var_saldoOld)
}

var_saldo <<- var_initialBalance
dt_infoDia <- cbind(dt_infoDia, initialBalance= mapply(calcula_saldoIni, (dt_infoDia$incomesDay + dt_infoDia$expensesDay)))

dt_infoDia[, finalBalance := initialBalance + (incomesDay + expensesDay)]

#-----------------------------------------------------------------------------------------
#Nuevo data_table con información mensual, meses completos
#----------------------------------------------------------

dt_infoMes <- dt_infoDia
dt_infoMes$quarter <- format(as.yearqtr(dt_infoMes$valueDate, format="%Y-%m-%d"), format = "%Y-Q%q")
dt_infoMes[, c("incomesMonth", "expensesMonth", "minDay", "maxDay") :=
             list( sum(incomesDay),
                   sum(expensesDay),
                   min(valueDate),
                   max(valueDate)),
           by=yearMonth]
dt_infoMes[valueDate != minDay, initialBalance := 0]
dt_infoMes$finalBalance = dt_infoMes$initialBalance + dt_infoMes$incomesMonth + dt_infoMes$expensesMonth

dt_infoMes <- dt_infoMes[valueDate == minDay,.(year, yearMonth, month, monthC, quarter, minDay, initialBalance, finalBalance, incomesMonth, expensesMonth )]
dt_infoMes[, meanBalance := mean(finalBalance), by=quarter]
dt_infoMes[, c("cumIncomesMonth", "cumExpensesMonth", 
               "incomesYear", "expensesYear") :=
             list( cumsum(incomesMonth),
                   cumsum(expensesMonth),
                   sum(incomesMonth),
                   sum(expensesMonth)),
           by=year]

# Añadimos información de gastos por semana
dt_infoSem<- dcast(dt_infoDia[,.(yearMonth, period, incomesDay, expensesDay)], 
                      yearMonth~period, value.var = c("incomesDay","expensesDay"), fun.aggregate=sum)

dt_infoMes <- merge(dt_infoMes, dt_infoSem, by=intersect(names(dt_infoSem), names(dt_infoMes)))
dt_infoMes <- rename(dt_infoMes,c("incomesDay_1" = "incFrom01to05", 
                                  "incomesDay_2" = "incFrom06to10",
                                  "incomesDay_3" = "incFrom11to15",
                                  "incomesDay_4" = "incFrom16to20",
                                  "incomesDay_5" = "incFrom21to25",
                                  "incomesDay_6" = "incFrom25",
                                  "expensesDay_1" = "expFrom01to05", 
                                  "expensesDay_2" = "expFrom06to10",
                                  "expensesDay_3" = "expFrom11to15",
                                  "expensesDay_4" = "expFrom16to20",
                                  "expensesDay_5" = "expFrom21to25",
                                  "expensesDay_6" = "expFrom25"))


#-----------------------------------------------------------------------------------------
#Nuevo data_table con información mensual, solo los dias anteriores al dia de la fecha
#--------------------------------------------------------------------------------------

dt_infoPartialMes <- dt_infoDia[day <= input_day,]
dt_infoPartialMes$quarter <- format(as.yearqtr(dt_infoPartialMes$valueDate), format = "%Y-Q%q")
dt_infoPartialMes$quarter <- gsub(" ", "-", dt_infoPartialMes$quarter)
dt_infoPartialMes[, c("incomesMonth", "expensesMonth", "minDay", "maxDay") :=
                    list( sum(incomesDay),
                          sum(expensesDay),
                          min(valueDate),
                          max(valueDate)),
                  by=yearMonth]

dt_infoPartialMes <- dt_infoPartialMes[valueDate == minDay,.(yearMonth, year, month, monthC, quarter, minDay, incomesMonth, expensesMonth )]

#-----------------------------------------------------------------------------------------
#Nuevo data_table con información anual
#------------------------------------------

dt_infoAnnio <- dt_infoMes[,.(year, incomesMonth, expensesMonth)]
dt_infoAnnio[, c("incomesYear", "expensesYear") := 
                list(sum(incomesMonth),
                     sum(expensesMonth)), 
              by=year]
dt_infoAnnio <- unique(dt_infoAnnio[,.(year, incomesYear, expensesYear)])

#Creamos la salida
cabecera <- "{\"stats\": {"
cab_infoDia <- "\"dailyStats\": "
cab_infoMes <- "\"monthlyStats\": "
cab_infoPartialMes <- "\"partialMonthlyStats\": "
cab_infoAnnio <- "\"yearlyStats\": "
fin <- "}}"
json_infoDia <- toJSON(dt_infoDia, pretty=FALSE)
json_infoMes <- toJSON(dt_infoMes, pretty=FALSE)
json_infoPartialMes <- toJSON(dt_infoPartialMes, pretty=FALSE)
json_infoAnnio <- toJSON(dt_infoAnnio, pretty=FALSE)

cat(cabecera, cab_infoDia, json_infoDia, ",", cab_infoMes, json_infoMes, ",", cab_infoPartialMes, json_infoPartialMes, ",", cab_infoAnnio, json_infoAnnio, fin)

