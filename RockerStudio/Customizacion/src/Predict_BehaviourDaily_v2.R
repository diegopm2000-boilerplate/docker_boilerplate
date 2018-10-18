#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
options(warn=-1)

#-----------------------------------------------------------------------------------------
# GENERACION DE ESTADISTICAS ASOCIADAS A LOS MOVIMIENTOS DE UN CONJUNTO DE CUENTAS
#---------------------------

#Cargamos en el entorno las librerias y funciones
suppressMessages(library(data.table))
suppressMessages(library(zoo))
suppressMessages(library(forecast))

source("extract_infoTrans_type1.R")

#-----------------------------------------------------------------------------------------
# Recuperacion de parametros de invocacion 
#----------------------------------

if (length(args)<2) {
  stop("At least two argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==2) {
  # default until
  args[3] <- "-"
}

var_account <- args[1]
var_request <- args[2]
var_until <- args[3]

#cat("numero de argumentos: ", length(args), "\n")
#cat("cuenta: ", var_account, "\n")
#cat("until: ", var_until, "\n")
#cat("tipo de peticion: ", var_request, "\n")


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

var_since <- as.character(seq(as.Date(var_until), length = 2, by = "-9 months")[2])

#-----------------------------------------------------------------------------------------
# Recuperacion de los datos origen
#----------------------------------

dt_movc <- extract_infoTrans_type1(var_account, var_since, var_until)

#-----------------------------------------------------------------------------------------
# Transformaciones
#------------------

#---------------------------------------------------------------------------------
# calculamos el saldo inicial

tmp_movc <- dt_movc
tmp_movc$id <- rownames(tmp_movc)

tmp_movc$initialBalance <- round(tmp_movc$finalBalance - tmp_movc$amount,0)
tmp_movc$finalBalance <- round(tmp_movc$finalBalance,0)
tmp_movc <- merge(tmp_movc[,.(id, accountId, valueDate, initialBalance)],
                  tmp_movc[,.(id,accountId, finalBalance)],
                  by.x=c("accountId", "initialBalance"), by.y=c("accountId", "finalBalance"), all.x=TRUE)
tmp_movc <- tmp_movc[is.na(id.y),]
tmp_movc[,minDateByAccount := min(valueDate), by=accountId]
tmp_movc <- tmp_movc[valueDate==minDateByAccount,]
var_initialBalance <- sum(tmp_movc$initialBalance)


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
# Transformaciones de fechas 

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
# Nuevo data_table con informacion diaria
#-----------------------------------------

dt_infoDia <- dt_movc[]
dt_infoDia[, c("incomesDay", "expensesDay") :=
             list(sum(incomes), sum(expenses)), 
           by=valueDate]

dt_infoDia <- unique(dt_infoDia[,.(valueDate, year, yearMonth, month, monthC, day, incomesDay, expensesDay)])

# Variables asociadas al saldo

calcula_saldoIni = function (d) {
  var_saldoOld <- var_saldo
  var_saldo <<- var_saldo + d
  return (var_saldoOld)
}

var_saldo <<- var_initialBalance
dt_infoDia <- cbind(dt_infoDia, initialBalance= mapply(calcula_saldoIni, (dt_infoDia$incomesDay + dt_infoDia$expensesDay)))

dt_infoDia[, finalBalance := initialBalance + (incomesDay + expensesDay)]

#-----------------------------------------
# Empezamos a montar la salida
#-----------------------------------------
var_cabecera <- "{\"predict_dailyInf\": {"
var_cabFinalBalance <- "\"finalBalance\": "
var_cabIncomes <- "\"incomes\": "
var_cabExpenses <- "\"expenses\": "
var_sep <- ","
var_fin <- "}}"

#-----------------------------------------------------------------------------------------
#Aplicamos analisis de Series Temporales
#----------------------------------------------------------
var_request <- 0
# Prediccion de balance final si ha sido solicitado
if (var_request == 0 | var_request == 1) {
  zoo_daily <- read.zoo(dt_infoDia[,.(valueDate, finalBalance)], format = "%Y-%m-%d")
  zoo_daily <- merge(zoo_daily, 
                     zoo(,seq(start(zoo_daily),end(zoo_daily),by="day")), all=TRUE)
  zoo_daily <- na.approx(zoo_daily)
  ts_daily <- ts(zoo_daily, frequency = 365)
  
  daily_ets <- Arima(ts_daily,order = c(30,1,1))
  preds  <- forecast(daily_ets, 40)
  data_forecast <- as.data.frame(preds)
  data_forecast$valueDate <- seq(end(zoo_daily)+1, end(zoo_daily)+40,by="day")
  
  ifelse ((var_request==0),
          var_output <- paste0(var_cabecera, var_cabFinalBalance, toJSON(data_forecast, pretty=FALSE), var_sep, sep="" ),
          var_output <- paste0(var_cabecera, var_cabFinalBalance, toJSON(data_forecast, pretty=FALSE), sep="" )
  )
  
}

# Prediccion de ingresos si ha sido solicitado
if (var_request == 0 | var_request == 2) {
  zoo_daily <- read.zoo(dt_infoDia[,.(valueDate, incomesDay)], format = "%Y-%m-%d")
  zoo_daily <- merge(zoo_daily, 
                     zoo(,seq(start(zoo_daily),end(zoo_daily),by="day")), all=TRUE)
  zoo_daily <- na.approx(zoo_daily)
  ts_daily <- ts(zoo_daily, frequency = 365)
  
  daily_ets <- Arima(ts_daily,order = c(30,1,1))
  preds  <- forecast(daily_ets, 40)
  data_forecast <- as.data.frame(preds)
  data_forecast$valueDate <- seq(end(zoo_daily)+1, end(zoo_daily)+40,by="day")
  
  ifelse ((var_request==0),
          var_output <- paste0(var_output, var_cabIncomes, toJSON(data_forecast, pretty=FALSE), var_sep, sep="" ),
          var_output <- paste0(var_cabecera, var_cabIncomes, toJSON(data_forecast, pretty=FALSE), sep="" )
  )
  
}

# Prediccion de gastos si ha sido solicitado
if (var_request == 0 | var_request == 3) {
  zoo_daily <- read.zoo(dt_infoDia[,.(valueDate, expensesDay)], format = "%Y-%m-%d")
  zoo_daily <- merge(zoo_daily, 
                     zoo(,seq(start(zoo_daily),end(zoo_daily),by="day")), all=TRUE)
  zoo_daily <- na.approx(zoo_daily)
  ts_daily <- ts(zoo_daily, frequency = 365)
  
  daily_ets <- Arima(ts_daily,order = c(30,1,1))
  preds  <- forecast(daily_ets, 40)
  data_forecast <- as.data.frame(preds)
  data_forecast$valueDate <- seq(end(zoo_daily)+1, end(zoo_daily)+40,by="day")
  
  ifelse ((var_request==0),
          var_output <- paste0(var_output, var_cabExpenses, toJSON(data_forecast, pretty=FALSE), sep="" ),
          var_output <- paste0(var_cabecera, var_cabExpenses, toJSON(data_forecast, pretty=FALSE), sep="" )
  )
  
}

cat(var_output, "}}")
