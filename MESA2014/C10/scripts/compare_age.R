#! /usr/bin/env Rscript


######################################################################
library('getopt')


######################################################################
circle_cex <- 0.5
pch <- 16
point_col <- 'black'


######################################################################
spec = matrix(
	c(
		'infile1', 'i', 1, 'character',
		'infile2', 'j', 1, 'character',
		'outfile', 'o', 1, 'character',
		'minmax', 'm', 1, 'character',
		'color', 'c', 1, 'character',
		'list', 'l', 1, 'character',
		'noCI', 'n', 0, 'logical'
	),
	byrow=T, ncol=4
)

opts = getopt(spec)
infile1 = opts$infile1
infile2 = opts$infile2
outfile = opts$outfile
minmax = opts$minmax
color = opts$color
noCI = opts$noCI

lineages <- list()
lineage_list_s = opts$list

if (is.null(infile1) | is.null(infile2) | is.null(outfile)){
	print("infile or outfile not given! Exiting ......"); q()
}
if (is.null(minmax)){
	print("minmax not given! Exiting ......"); q()
}
if (is.null(noCI)){
	noCI <- F
}
if (!is.null(lineage_list_s)){
	for(lineage_list in unlist(strsplit(lineage_list_s, ','))){
		lineages[[length(lineages)+1]] <- read.table(lineage_list, stringsAsFactors=F)$V1
	}
}
if(!is.null(color)){
	colors <- unlist(strsplit(color, ","))
}

min = as.numeric(unlist(strsplit(minmax, ","))[1])
max = as.numeric(unlist(strsplit(minmax, ","))[2])


######################################################################
#Make up data
d1 <- read.table(infile1, header=T)
d2 <- read.table(infile2, header=T)

d <- merge(d1, d2, by='node')
age1<-d$age.x
age2<-d$age.y
age1_min<-d$min.x
age2_min<-d$min.y
age1_max<-d$max.x
age2_max<-d$max.y


if (is.null(col)){
	col1<-as.character(d1$V5)
	col2<-as.character(d2$V5)
} else{
	col1<-colors[1]
	col2<-colors[1]
}

if (noCI){
	circle_cex <- 1
	pch <- 16
	#point_col <- rgb(255, 0, 0, max = 255, alpha = 175, names = "blue50")
	point_col <- rep(adjustcolor(colors[1], alpha.f = 0.75), length(d$node))
}


if( length(lineages) != 0 ){
	for( i in 1:length(lineages) ){
		point_col[ which(d$node %in% lineages[[i]] ) ] <- adjustcolor(colors[i+1], alpha.f = 0.75)
	}
}


######################################################################
#The plot
pdf(outfile)

#plot(age1, age2, pch=pch, cex=0.8, col="black", cex.axis=1.1, cex.lab=1.2)
#print(age1)
plot(age1, age2, pch=pch, cex=circle_cex, col=point_col, ylim=c(min,max), xlim=c(min,max), cex.axis=1.1, cex.lab=1.2, 
	ylab='', xlab=''
)

if(! noCI){
	segments(age1_max, age2, age1_min, age2, lwd=0.5, col=col1)
	segments(age1, age2_max, age1, age2_min, lwd=0.5, col=col2)
	#legend("topright", legend=paste("Study",1:10),col=rainbow(length(pop.size)), pt.cex=1.5, pch=16)
}

abline(0,1,col="darkgrey", lty=2, lwd=2)

#axis(1,seq(0, 3000, 1000))
#axis(2,seq(0, 3000, 1000))

dev.off()


