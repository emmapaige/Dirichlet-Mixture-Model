source("library_cmdline.R")
source("source.R")
source("Allfcns.R")
library(tidyverse)
library(readr)
#shortname<-cmdline.strings("shortname") #For simulated data, shortname = Test 
#copy<-cmdline.numeric("copy") #For possible multiple tests 
#CORE<-cmdline.numeric("core") #Number of cores needed for mclapply


shortname = "test"
copy = 36  # change it

CORE = 1



# Create a folder "Tests" and a subfolder "Tests/Data" for the simulated data sets
dir.create("Tests/Data", recursive = TRUE)
PostD = 4; #J = 5; K.mut = 10; m = 5000
rawdata <- get(load("~/H1N1 Data/H1N1data Processed/S1_5tE1Data.Rdata"))

#Add a row of zeros for missing nucleotides
if(dim(rawdata)[1] < 5){
  rawdata=rbind(rawdata,rep(0,dim(rawdata)[2]))
}

set.seed(copy*10)
load(paste("Tests/Data/TestData_",copy,".Rdata",sep=""))
n = ncol(rawdata)/PostD; 
Pairs = c( "t1t2", "t1t3", "t2t3", "t1t3_D", "t2t3_D" )
a=1/(nrow(rawdata)^2)  #nrow(rawdata)=J number of possible reads
Jname = paste(shortname, copy, "_a",1/a,sep="") #e.g. Jname = Test1_25
name = paste( "Tests/", Jname, sep = "" )
dir.create(name)

source("SHJ_algor.R")