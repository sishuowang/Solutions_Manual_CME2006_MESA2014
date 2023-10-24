#! /usr/bin/env Rscript


################################################
library(seqinr)


################################################
args = commandArgs(trailingOnly=TRUE)
seq_file <- args[1]
s <- read.fasta(seq_file)

v <- list()
for(i in 1:getLength(s)[1]){
    v[[i]] <- sapply(s, function(x) x[i])
    names(v[[i]]) <- names(s)
}

m <- t(sapply(v, unlist, list(use.names=F)))
dimnames(m) <- NULL

h <- apply(m, 1, function(x){paste(x,collapse="")})
t <- table(h)
n <- sum(t)

lnl <- 0
for(n_i in table(h)){
    lnl <- lnl + n_i * log(n_i/n)
}

cat(lnl,"\n")

