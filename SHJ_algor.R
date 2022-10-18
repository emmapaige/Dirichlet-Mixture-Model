# Algorithm (preprocess, processing, and post-process)
# need this library for str_count
# install.packages("stringr",lib="/nas/longleaf/home/weiyq/ms/Rpackages", repos='http://cran.us.r-project.org')
# library(stringr,lib.loc="/nas/longleaf/home/weiyq/ms/Rpackages")
#library(stringr,lib.loc="/nas/longleaf/home/weiyq/R/x86_64-redhat-linux-gnu-library/3.6")  
library(stringr)

# Step1: Preprocess
    rawdata=unconcatenate(tests, PostD, rawdata) # Emma added this for generalization
    conso=consoData(rawdata)  # consoData is in Allfcns.R
    Data=conso[[1]]
    G0=conso[[2]]
    save(Data,G0,file=paste(name,"/Data.Rdata",sep=""))



# Step2: Processsing
    # Hierarchical SCMH
        dir.create(paste(name,"/Outputs",sep=""))
        dir.create(paste(name,"/SLURMouts",sep=""))
       # starttree=paste("bsub -J tree.", Jname," -o ", "~/LSFouts/", Jname, ".out
       #                 R CMD BATCH --vanilla --args  --copy=", copy," --name=",name,
       #                 " --Jname=", Jname," --current=1 Tree.R ", name,"/Outputs/Tree_1.out",sep="")
       # system(starttree) 
        starttree = paste("sbatch --constraint=rhel8 -t 1-  -N 1 -n 1 -J ",Jname," -o ", name, "/SLURMouts/", Jname,
		       ".out.1  --wrap=\"R  CMD BATCH --vanilla --args --copy=", copy,
		       " --name=",name, " --Jname=", Jname, " --current=1 Tree.R ", name, "/Outputs/tree1.Rout \"",sep="" )
	print (" ")
	print (paste("sbatch command:",starttree))
	print (" ")
	system(starttree)
	#        Sys.sleep(60) #Check if the divisible tree step finishes every 60 seconds
	#system(paste("bjobs -J tree.", Jname, " > JOB_",Jname,sep=""))
	#jobsize=file.info(paste("JOB_", Jname,sep=""))$size
	#print(jobsize) 
	#while(jobsize > 0){
	#  Sys.sleep(60) 
	#  system(paste("bjobs -J tree.", Jname, " > JOB_", Jname,sep=""))
	#  jobsize=file.info(paste("JOB_", Jname,sep=""))$size
	#  print(jobsize)
	#}
	#system(paste("rm JOB_", Jname, sep="" ))
	
	state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE) 
	# collapse character vector into on long string
	state <- paste(state,collapse=" ")
	print("printing state")
	print(state)
	isInQueue <- str_detect(state, Jname)
	print (paste("isInQueue=",isInQueue))
	while (isInQueue) {
	  Sys.sleep(60)
	  state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE) 
	  state <- paste(state,collapse=" ")
	  isInQueue <- str_detect(state, Jname)
	  print (paste("whiling away isInQueue=",isInQueue))
	}
	
	
	SplitList=list() #Summarize tree result.
	print (paste("1 spl=",SplitList))
	run=T
	i=0
	endInd=3
	print ("doing while")
	while(run==T){
	  i=i+1
	  print (paste("i=",i))
	  if(1==i){  
	    load(paste(name,"/Tree_",i,".Rdata", sep=""))
	    test=old.result    
	    SplitList[[i]]<-SplitNode(left=2*i,right=2*i+1,parent=NA,curent=i,LP=test$LP,
	                              ind=sort(c(test$left,test$right)))    #SplitNode is in source.R
	    if(0!=length(test$left) & 0!=length(test$right)){
	      SplitList[[2*i]]<-SplitNode(left=4*i,right=4*i+1,curent=2*i,parent=i,LP=NULL,ind=test$left)
	      SplitList[[2*i+1]]<-SplitNode(left=2*(2*i+1),right=2*(2*i+1)+1,curent=2*i+1,parent=i,
	                                    LP=NULL,ind=test$right)
	    }
	    if(0==length(test$left) | 0==length(test$right)){
	      noLeft(SplitList[[i]])    #noLeft is in source.R
	      noRight(SplitList[[i]])  #noRight is in source.R
	    }
	  }
	  else if(is.Node(SplitList[[i]])){  
	    load(paste(name,"/Tree_",i,".Rdata", sep=""))
	    test=old.result 
	    updateLP(SplitList[[i]],test$LP)  #updateLP is in source.R
	    if(0!=length(test$left) & 0!=length(test$right)){
	      SplitList[[2*i]]<-SplitNode(left=4*i,right=4*i+1,curent=2*i,parent=i,LP=NULL,ind=test$left) #Function is in source.R
	      SplitList[[2*i+1]]<-SplitNode(left=2*(2*i+1),right=2*(2*i+1)+1,curent=2*i+1,parent=i,
	                                    LP=NULL,ind=test$right)
	    }else{
	      noLeft(SplitList[[i]])
	      noRight(SplitList[[i]])
	      SplitList[[2*i]]=NULL
	      SplitList[[2*i+1]]=NULL
	    }
	  }else{
	    SplitList[[2*i]]=NULL
	    SplitList[[2*i+1]]=NULL
	  }        
	  if (i==endInd){  
	    st=stopSplit(i)
	    if(0==st){run=F}
	    endInd=2*endInd+1
	    SplitList[[2*endInd+1]]=NA
	  }
	}
	print ("end while T")
	Gp=groupIndex()
	save(Gp, file=paste(name,"/TreeResult.Rdata",sep="")) 
	
	
	print ("Block MH section")
	# Block MH
	Z0=grpData(Data,Gp)
	combgrp=blockcomb(Z0,Gp,50000,a,1000)  #others 10000
	save(Z0,combgrp, file=paste(name,"/BlockResult.Rdata",sep=""))
	save(Z0,combgrp, file=paste(name,"/BlockResult.Rdata",sep=""))
	
	#        system(paste("rm ", name, "/Tree_*.Rdata", sep="" )) #remove tree node data
	
	
	print ("Gibbs mod section")
	# Gibbs modification
	# why seq(1,10000,100)
	BCs=combgrp[[1]][seq(1,10000,100),] #Thin-out the chain by every 100 iteratisions. 
	C0s=GibbsC0(BCs,Gp,Data) #Assign group label to each sequence position. 100*1175 matrix
	newC0s=t(apply(C0s,1,renameC)) #Rename the labels. 
	save(newC0s, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )
	# I add this line
	save(newC0s, file = paste( name, "/GibbsResult.Rdata", sep = "" ) )
	numC0=nrow(newC0s)
	# sub=paste("bsub -q week -J Gibbs.", Jname,"[1-",numC0,"] -o ~/LSFouts/Gibbs.out R CMD BATCH --vanilla --args --name=",
	#           name," --isGibbs=",0," --copy=",copy," --Ci=\\\u0024LSB_JOBINDEX GibbsMC.R ", name,"/Outputs/Gibbs\\\u0024LSB_JOBINDEX.out", sep="")
	
	#sub=paste("sbatch -t 1- -N 1 -n 1 -J Gibbs.", Jname, "[1-",numC0,"] -o  ", name, "/SLURMouts/Gibbs%a.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
	#          " --isGibbs=",0," --copy=",copy, " --Ci=SLURM_ARRAY_TASK_ID GibbsMC.R ", name,"/Outputs/Gibbs%a.out\"", sep="")
	for(C0 in 1:numC0){
	  sub=paste("sbatch -t 1- -N 1 -n 1 -J Gibbs.", Jname, "[",C0,"] -o  ", name, "/SLURMouts/Gibbs%a.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
	            " --isGibbs=",0," --copy=",copy, " --Ci=",C0," GibbsMC.R ", name,"/Outputs/Gibbs",C0,".out\"", sep="")
	  system(sub)
	  Sys.sleep(1)
	}
	for(C0 in 1:numC0){
	  # sub = paste("bsub -q week -n ", CORE, " -R \u0022span[hosts=1]\u0022 -J Gibbs.", Jname,"[", c0,"] -o ~/LSFouts/Gibbs.out R CMD BATCH --vanilla --args --name=",
	  #             name," --copy=", copy," --core=", CORE," --Ci=\\\u0024LSB_JOBINDEX FixGibbsMC.R ", name,
	  #             "/Outputs/Gibbs\\\u0024LSB_JOBINDEX.out", sep="")
	  
	  # sub = paste("sbatch -p general -N 1 -n ", CORE, " -J FixGibbs.",
	  # Jname,"[", c0,"] -o ", name, "/SLURMouts/FixGibbs.out --wrap=\"R CMD BATCH --vanilla --args --name=",name," --copy=", copy,"--core=", CORE," --Ci=", c0, " FixGibbsMC.R ", name,
	  # "/Outputs/FixGibbs", c0, ".out\"", sep="")
	  # subFix=paste("sbatch -t 1- -N 1 -n ", CORE, " -J FixGibbs.", Jname, "[1-",numC0,"] -o  ", name, "/SLURMouts/FixGibbs%a.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
	  #            " --copy=",copy, " --core=", CORE, " --Ci=SLURM_ARRAY_TASK_ID FixGibbsMC.R ", name,"/Outputs/FixGibbs%a.out\"", sep="")
	  subFix=paste("sbatch --constraint=rhel8 -t 1- -N 1 -n ", CORE, " -J FixGibbs.", Jname, "[",C0,"] -o  ", name, "/SLURMouts/FixGibbs%a.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
	               " --copy=",copy, " --core=", CORE, " --Ci=",C0," FixGibbsMC.R ", name,"/Outputs/FixGibbs",C0,".out\"", sep="")  
	  system(subFix)           
	  Sys.sleep(1)            
	}
	
	#Sys.sleep(60) #Check if all Gibbs chain have finished every 60 seconds
	#system(paste("bjobs -J Gibbs.", Jname, " > JOB_", Jname, sep=""))
	#system(paste("squeue -n Gibbs.", Jname, " > JOB_", Jname, sep=""))
	#jobsize=file.info(paste("JOB_", Jname,sep=""))$size  
	#while(jobsize > 0){
	#Sys.sleep(60) 
	#system(paste("bjobs -J Gibbs.", Jname, "* > JOB_", Jname,sep=""))
	#system(paste("squeue -n Gibbs.", Jname, "* > JOB_", Jname,sep=""))
	#jobsize=file.info(paste("JOB_", Jname,sep=""))$size
	#print(jobsize)
	#}
	#system(paste("rm JOB_", Jname, sep="" ))
	
	state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE) 
	# collapse character vector into on long string
	state <- paste(state,collapse=" ")
	print("printing state")
	print(state)
	isInQueue <- str_detect(state, Jname)
	print (paste("isInQueue=",isInQueue))
	while (isInQueue) {
	  Sys.sleep(60)
	  system(paste("squeue -u emmamit -O  name:40"))
	  state <- system(paste("squeue -u emmamit -O  name:40"),intern=TRUE) 
	  state <- paste(state,collapse=" ")
	  isInQueue <- str_detect(state, Jname)
	  print (paste("whiling away isInQueue=",isInQueue))
	}
	#I add this line
	system(paste("rm ", name, "/FixGibbsMC*temp.Rdata", sep="" ))  
	#  Gibbs=Gibbsresult(newC0s,name,rawdata, GibbsMC = T)  
	Gibbs=Gibbsresult2(newC0s,name,rawdata, GibbsMC = T) #Gather Gibbs results #without 2?
	save( newC0s, Gibbs, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )
	
	
	print ("Step 3")
	
	# Step 3: Postprocess
	HtMed( Gibbs$FinalCs, rawdata, a, PostD, n, name, Control = T, mHtsFile = "/mHtsFixOne.Rdata" )
	#Catch_Error(HtMed( Gibbs$FinalCs, rawdata, a, PostD, n, name, Control = T, mHtsFile = "/mHtsFixOne.Rdata" ))
	inffile = paste( name, "/mHtsFixOne.Rdata", sep = "" )
	resultfile =  paste( name, "/ResultLocalFixOne.Rdata", sep = "" ) 
	load(inffile); Cuts = seq(0, max(mHts.pos), by = .001) 
	noise.test = sapply(Cuts, function(y){
	  result = freaksite0(inffile, Pairs, PostD, y, Control = T )
	  noise.l = c( length(result$Substitution), length(result$potential), 
	               length(result$noise))
	  return( noise.l )
	})
	save( Pairs, PostD, Cuts, noise.test, file = resultfile ) 
	savefile =  paste( name, "/FinalFixOne1.Rdata", sep = "" )     
	result = freak.result1( inffile, resultfile, savefile, delta = 3, Control = T, alpha = .05 )
	
	save(Gibbs, result, file = paste( name, "/InferenceFix1.Rdata",sep=""))
	
	plotNiDi(inffile,resultfile,savefile,SavePlot=F) 
	freqplot1(paste("Tests/Data/TestData_",copy,".Rdata",sep=""), result$Substitution, "Tests/Data/", M = 100 )
	


	
	
	
	                                
	
	
	
