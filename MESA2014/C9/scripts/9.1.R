#! /usr/bin/env Rscript
library(ape)
library(phangorn)
coalescent_tree <- rcoal(10)
simSeq(coalescent_tree, type="DNA", l=1000) # need to further check if the default model is JC69.
