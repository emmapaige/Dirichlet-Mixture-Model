# d saved in /FinalFixOne1.Rdata
pdf(paste(name,"/plots/plot_noiseSet.pdf",sep=""))
load(savefile)
d1<-d
max(mHts.pos)
plot(Cuts, noise.test[1,], cex= .3, col = "red", xlim = c(max(mHts.pos),0), ylim = c(0,100), # change xlim
     font.lab = 2, main = "Test 1 (3 steps)", xlab = "Threshold d", ylab = "# of sites" ) # signal
points(Cuts, noise.test[2,], cex= 0.1, col = "green") # potential
points(Cuts, noise.test[3,], cex= 0.2, col = "blue") # noise
abline(v=d1, lty = 2) 

savefile2 <-paste( name, "/FinalFixOne2.Rdata", sep = "" )
result = freak.result2( inffile, resultfile, savefile2, delta = 3, Control = F, alpha = .25 )
load(savefile2)
d2<-d
abline(v=d2, lty = 3) 

text.legend = c(expression(paste(alpha, " = 0.5")),expression(paste(alpha, " = 0.25")))
legend(11,100,legend=text.legend,lty=c(2,3),bty="n")
text(10,85,"signal",col="red")
text(10,80,"potential",col="green")
text(10,75,"noise",col="blue")
dev.off()
