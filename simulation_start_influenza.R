source("Allfcns.R")
library(stringr)
library(bmixture)
copy=211 # needs to change for each run
set.seed(copy*10)

### Simulation only for PostD=1
### Add cases for other PostD

#Initialize parameters to simulation 
## J = number of read types
## postD = test with mutations
## K.mut = number of mutations
## sitect = multinomial(sitect,P)

J = 5 
PostD = 1 
K.mut = 5 
sitect = 5000
tests=4


## H3N2 reference genome


genome.ch <-"AGCAAAAGCAGGTCAATTATATTCAGTATGGAAAGAATAAAAGAACTACGGAACCTGATGTCGCAGTCTC
GCACTCGCGAGATACTGACAAAAACCACAGTGGACCATATGGCCATAATTAAGAAGTACACATCGGGGAG
ACAGGAAAAGAACCCGTCACTTAGGATGAAATGGATGATGGCAATGAAATACCCAATCACTGCTGACAAA
AGGATAACAGAAATGGTTCCGGAGAGAAATGAACAAGGACAAACTCTATGGAGTAAAATGAGTGATGCTG
GATCAGATCGAGTGATGGTATCACCTTTGGCTGTAACATGGTGGAATAGAAATGGACCCGTGGCAAGTAC
GGTCCATTACCCAAAAGTATACAAGACTTATTTTGACAAAGTCGAAAGGTTAAAACATGGAACCTTTGGC
CCTGTTCATTTTAGAAATCAAGTCAAGATACGCAGAAGAGTAGACATAAACCCTGGTCATGCAGACCTCA
GTGCCAAAGAGGCACAAGATGTAATTATGGAAGTTGTTTTTCCCAATGAAGTGGGAGCCAGGATACTAAC
ATCAGAATCGCAATTAACAATAACTAAAGAGAAAAAAGAAGAACTCCGAGATTGCAAAATTTCTCCCTTG
ATGGTTGCATACATGTTAGAGAGAGAACTTGTCCGAAAAACAAGATTTCTCCCAGTTGCTGGCGGAACAA
GCAGTATATACATTGAAGTCTTACATTTGACTCAAGGAACGTGTTGGGAACAAATGTACACTCCAGGTGG
AGAAGTGAGGAATGACGATGTTGACCAAAGCCTAATTATTGCGGCCAGGAACATAGTAAGAAGAGCTGCA
GTATCAGCAGATCCACTAGCATCTTTATTGGAGATGTGCCACAGCACACAAATTGGCGGGACAAGGATGG
TGGACATTCTTAGACAGAACCCGACTGAAGAACAAGCTGTGGATATATGCAAGGCTGCAATGGGATTGAG
AATCAGCTCATCCTTCAGCTTTGGTGGGTTTACATTTAAAAGAACAAGCGGGTCATCAGTCAAAAAAGAG
GAAGAAGTGCTTACAGGCAATCTCCAAACATTGAAGATAAGAGTACATGAGGGGTATGAGGAGTTCACAA
TGGTGGGGAAAAGAGCAACAGCTATACTCAGAAAAGCAACCAGAAGATTGGTTCAGCTCATAGTGAGTGG
AAGAGACGAACAGTCAATAGCCGAAGCAATAATCGTGGCCATGGTGTTTTCACAAGAGGATTGCATGATA
AAAGCAGTTAGAGGTGACCTGAATTTCGTCAACAGAGCAAATCAACGGTTGAACCCCATGCATCAGCTTT
TAAGGCATTTTCAGAAAGATGCGAAAGTGCTTTTTCAAAATTGGGGAATTGAACACATCGACAGTGTGAT
GGGAATGGTTGGAGTATTACCAGATATGACTCCAAGCACAGAGATGTCAATGAGAGGAATAAGAGTCAGC
AAAATGGGTGTGGATGAATACTCCAGTACAGAGAGGGTGGTGGTTAGCATTGATCGGTTTTTGAGAGTTC
GAGACCAACGCGGGAATGTATTATTGTCTCCTGAGGAGGTCAGTGAAACACAGGGAACTGAAAGATTGAC
AATAACATATTCATCGTCGATGATGTGGGAGATTAACGGTCCTGAGTCGGTTTTGGTCAATACCTATCAA
TGGATCATCAGAAATTGGGAAGCTGTCAAAATTCAATGGTCTCAGAATCCTGCAATGTTGTACAACAAAA
TGGAATTTGAACCATTTCAATCTTTAGTCCCCAAGGCCATTAGAAGCCAATACAGTGGGTTTGTCAGAAC
TCTATTCCAACAAATGAGAGACGTACTTGGGACATTTGACACCACCCAGATAATAAAGCTTCTCCCTTTT
GCAGCCGCTCCACCAAAGCAAAGCAGAATGCAGTTCTCTTCACTGACTGTAAATGTGAGGGGATCAGGGA
TGAGAATACTTGTAAGGGGCAATTCTCCTGTATTCAACTACAACAAGACCACTAAAAGACTAACAATTCT
CGGAAAAGATGCCGGCACTTTAATTGAAGACCCAGATGAAAGCACATCCGGAGTGGAGTCCGCCGTCTTG
AGAGGGTTTCTCATTATAGGTAAGGAAGACAGAAGATACGGACCAGCATTAAGCATCAATGAACTGAGTA
ACCTTGCAAAAGGGGAAAAGGCTAATGTGCTAATCGGGCAAGGAGACGTGGTGTTGGTAATGAAACGAAA
ACGGGACTCTAGCATACTTACTGACAGCCAGACAGCGACCAAAAGAATTCGGATGGCCATCAATTAATGT
TGAATAGTTTAAAAACGACCTTGTTTCTACT"



## Remove \n from string and display nucleotides individually

genome.ch <- str_remove_all(genome.ch,"\n")
genome.vec <- strsplit(genome.ch,split="")[[1]]
genome.vec <- genome.vec[1:300]
table(genome.vec)



# generate probability priors a dirichlet distribution
## np = number of probability priors
## p = probability priors 

np <- 100
p <- rdirichlet(np,rep(1/J^2,J))


## divide probability priors into J groups
## for the case of J=5
# 1:A
# 2:C
# 3:G
# 4:T
# 5:M

pgroup <- rep(NA,np)

for (i in 1:J)
{pgroup[p[,i]>0.5] <-i}

sum(is.na(pgroup))

pgroup[is.na(pgroup)] <- J+1

num <- rep(NA,J+1)
for (i in 1:(J+1)) 
{num[i] <- sum(pgroup==i)}

num   #number of each nucleotide
sum(num)   #should be np
pgroup  #which group each prob. prior is in


# getP: inputs counts and generates assignment indicators that denote which probability parameter is associated with which genomic site from uniform distribution

getP <- function(read){
  if(read == "A") {
    n <- ceiling(runif(1)*num[1])
    return(p[pgroup==1,][n,])
  }
  else if(read == "C") {
    n <- ceiling(runif(1)*num[2])
    return(p[pgroup==2,][n,])
  }
  else if(read == "G") {
    n <- ceiling(runif(1)*num[3])
    return(p[pgroup==3,][n,])
  }
  else if(read == "T") {
    n <- ceiling(runif(1)*num[4])
    return(p[pgroup==4,][n,])
  }
  else if(read == "M") {
    n <- ceiling(runif(1)*num[5])
    return(p[pgroup==5,][n,])
  }
}

P <- sapply(genome.vec,getP) 


# repeat P J-1 times
## PP= probs. for multinom(sitect,PP)

PP <- NULL
for (j in 1:tests){    #Problem here
  PP <- cbind(PP,P) 
}

# generate reads from multinom(sitect,PP)

getReads <- function(x) {rmultinom(1,sitect,x)}
rawdata <- apply(PP,2,getReads)  # rawdata without mutation
str(rawdata)


# select the K.mut mutation positions

n = ncol(rawdata)/tests
mutSites <- ceiling(runif(K.mut)*length(genome.vec))

if (PostD==1) {
  rawdata[,mutSites] 
  rmutReads <- colnames(rawdata[,mutSites]) # nucleotides at each mutation position
} else 
  rawdata[,length(genome.vec)*(PostD-1)+mutSites] 
  mutReads <- colnames(rawdata[,length(genome.vec)*(PostD-1)+mutSites])


#rawdata[,mutSites+rep((PostD-1)*n,K.mut)]   # I think I should change this to rawdata[,mutSites]
#mutReads <- colnames(rawdata[,mutSites+rep((PostD-1)*n,K.mut)]) # nucleotides at each mutation position

#The mutation sites are 
print(mutSites)
#The above table shows the orginal counts at each of the J sites


# Create new probability parameters for each of the `r K.mut` mutation positions

pmut <- rdirichlet(np,rep(1/J^2,J))

pgroupmut <- rep(NA,np)

for (i in 1:J)
{pgroupmut[pmut[,i]>0.5] <-i}

pgroupmut[is.na(pgroupmut)] <- J+1

nummut <- rep(NA,J+1)

for (i in 1:(J+1)) 
{nummut[i] <- sum(pgroup==i)}



# mutP: inputs counts and changes the probability prior at each mutation position

mutP <- function(read){
  if(read == "A") {
    nmut <- ceiling(runif(1)*(np-nummut[1]))
    return(pmut[pgroupmut!=1,][nmut,])
  }
  else if(read == "C") {
    nmut <- ceiling(runif(1)*(np-nummut[2]))
    return(pmut[pgroupmut!=2,][nmut,])
  }
  else if(read == "G") {
    nmut <- ceiling(runif(1)*(np-nummut[3]))
    return(pmut[pgroupmut!=3,][nmut,])
  }
  else if(read == "T") {
    nmut <- ceiling(runif(1)*(np-nummut[4]))
    return(pmut[pgroupmut!=4,][nmut,])
  }
  else if(read == "M") {
    nmut <- ceiling(runif(1)*(np-nummut[5]))
    return(pmut[pgroupmut!=5,][nmut,])
  }
}


# generate new multinomial(sitect, mutP) data for mutation positions

mutP <- sapply(mutReads,mutP) 
mutP

if (PostD==1) {
rawdata[,mutSites] <- apply(mutP,2,getReads) 
rawdata[,mutSites] #final product
} else 
rawdata[,length(genome.vec)*(PostD-1)+mutSites] <- apply(mutP,2,getReads) 
rawdata[,length(genome.vec)*(PostD-1)+mutSites] #final product


# Move Test 1 to the end of the data matrix 

#T1<-rawdata[,c(1:300)]
#rawdata_nomut <- rawdata[,-c(1:300)]
#rawdata <- cbind(rawdata_nomut,T1)


# save final rawdata with mutations 

#rawdata=unconcatenate(tests, PostD, rawdata) # Emma added this for generalization
save(rawdata,file=paste("Tests/Data/TestData_",copy,".Rdata",sep=""))
print("saved influenza rawdata!")




