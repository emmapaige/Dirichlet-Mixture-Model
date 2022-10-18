library(ggplot2)
# d saved in /FinalFixOne1.Rdata
#pdf(paste(name,"/plots/plot_noiseSet.pdf",sep=""))
load(savefile)
d1<-d

# save as data frame for ggplot
dat=as.data.frame(t(rbind(Cuts,noise.test)))

# plotting cutoff
ggplot(dat, aes(x=Cuts)) + 
  geom_line(aes(y = V2, colour="signal")) + 
  geom_line(aes(y = V3, colour="potential"))+
  geom_line(aes(y = V4, colour="noise"))+ 
  geom_vline(xintercept=d1) +
  xlim(c(max(mHts.pos),0)) +
  ylim(c(0,100)) +
  labs(title = "Visualizing cutoff",
       x = "threshold",
       y = "number of sites")+
  theme(plot.title  = element_text(hjust=0.5))+
  scale_color_manual(name='Key',
                     breaks=c('signal', 'potential', 'noise'),
                     values=c('signal'='red', 'potential'='blue', 'noise'='green'))

# saving
ggsave(paste("Tests/Visualizing_Cutoff_",copy,".pdf",sep=""))
