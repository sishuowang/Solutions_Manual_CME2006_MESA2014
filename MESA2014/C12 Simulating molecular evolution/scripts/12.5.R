#! /usr/bin/env Rscript


#################################################
pdf()

par(mfrow=c(3,4))
for(d in seq(0.1, by=0.2, length.out=5)){
    d <- ifelse(d==1, format(d, nsmall=1), d)
    for(n in c(50,100,200,500)) {
        infile1 <- paste('jc69.', d, '-', n, '.lnl', sep='')
        infile2 <- paste('k80.', d, '-', n, '.lnl', sep='')
        a1 <- unlist(read.table(infile1))
        a2 <- unlist(read.table(infile2))
        print(infile2)
        hist(2*(a2-a1), breaks=50, freq=F, ylim=c(0,2), xlim=c(0,8), main=paste(paste0("distance:",d),paste0("length:",n),sep='\n'), xlab="", ylab="", lwd=1)
        curve(dchisq(x,df=1),add=T, col="RED")
    }
}

dev.off()

