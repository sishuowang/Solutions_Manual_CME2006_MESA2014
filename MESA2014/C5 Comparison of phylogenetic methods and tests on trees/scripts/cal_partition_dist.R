#! /usr/bin/env Rscript

##########################################
suppressWarnings({
    library(ape)
})

##########################################
args <- commandArgs(trailingOnly=TRUE)
tree1 <- read.tree(args[1])
tree2 <- read.tree(args[2])
dist <- dist.topo(tree1,tree2)
cat(ifelse(dist[1]==0, "T", "F"),"\n")

