#! /usr/bin/env Rscript

library(getopt)
library(parallel)
library(matrixStats)
library(seqinr)
library(ape)
library(phangorn)
library(expm)

E <- expm::expm

######################################
get_v_freq <- function(v){
	u <- lapply(v, function(x){paste(x, collapse='!')})
	t <- table(unlist(u))
	t_names_split <- lapply(names(t), function(x){unlist(strsplit(x,"!"), use.name=F)})
	l <- vector("list", length(rownames(t)))
	for(i in 1:length(rownames(t))){
		l[[i]] <- list(as.integer(t_names_split[[i]]), t[[i]])
	}
	l
}

read_traits <- function(d){
	v <- list()
	name <- unlist(d$V1)
	for(i in 2:ncol(d)){
		v[[i-1]] <- unlist(d[,i])
		names(v[[i-1]]) <- name
	}
	return(v)
}

rename_trait <- function(x){
	if (!is.null(names(x))) {
		if (all(names(x) %in% phy$tip.label))
			x <- x[phy$tip.label]
		else stop("the names of 'x' and the tip labels of the tree do not match: the former were ignored in the analysis.")
	}
	if (!is.factor(x)) {
		x <- factor(x)
		nl <- nlevels(x)
		x <- as.integer(x)
	}
	x
}

######################################
# phylo construction functions
do_phylo_log_lk <- function(param) {
	liks_ori <- liks
	bl <- param
	log_lk <- 0
	j <- 0
	liks <- liks_ori
	comp <- numeric(nb.tip + nb.node)
	for (anc in (nb.node + nb.tip):(1 + nb.tip)) {
		children <- all_children[[anc-nb.tip]]
		m <- matrix(0, nl, length(children))
		for(i in 1:length(children)){
			j <- j + 1L
			m[,i] <- E(Q * (bl[j])) %*% liks[children[i], ]
		}
		m_prod <- rowProds(m)
		comp[anc] <- sum(m_prod)
		if(anc == (1 + nb.tip)){ comp[anc] <- rep(1/nl,nl) %*% m_prod }
		liks[anc, ] <- m_prod / comp[anc]
	}
	log_lk <- rowSums(log(matrix(comp[-TIPS],1)))
	return (ifelse(is.na(log_lk), Inf, -log_lk)) # note here -log_lk
}

format_do_phylo_log_lk <- function(x, param){
	liks <- matrix(0, nb.tip + nb.node, nl)
	liks[cbind(TIPS, x[[1]])] <- 1
	environment(do_phylo_log_lk) <- environment()
	do_phylo_log_lk(param) * x[[2]]
}

sum_phylo_log_lk <- function(param){
	s <- sum( unlist (mclapply(v, format_do_phylo_log_lk, c(param=param), mc.cores=cpu) ) )
	s
}

######################################
phy <- NULL
s <- NULL
cpu <- 1

######################################
spec <- matrix(c(
	'tree', 't', 2, 'character',
	'traits', 's', 2, 'character',
	'inv', 'i', 0, 'logical',
	'cpu', 'n', 2, 'integer'
	), ncol=4, byrow=T
)
opts <- getopt(spec)
if(!is.null(opts$tree)){phy <- read.tree(opts$tree)}
if(!is.null(opts$traits)){s <- read.fasta(opts$traits)}
if(!is.null(opts$cpu)){cpu <- opts$cpu}
stopifnot(class(phy) != "Phylo")

######################################
# read and parse the seq
if(var(getLength(s)) != 0){
	stop(paste("seqfile", "seq of diff lengths"))
}
seq <- getSequence(s)
v <- list()
for(i in 1:getLength(s)[1]){
	v[[i]] <- sapply(s, function(x) x[i])
	names(v[[i]]) <- names(s)
}
nl <- nlevels(factor(unlist(v, use.names=F)))
v <- lapply(v, rename_trait)
cat("Alignment length:", length(v), "\n")

######################################
v <- get_v_freq(v)
nb.tip <- length(phy$tip.label)
nb.node <- phy$Nnode
TIPS <- 1:nb.tip

# create the rate matrix Q
p <- rep(1, 4)
Q <- matrix(rep(p, 4), nl, nl); diag(Q) <- 0
Q <- apply(Q, 1, function(x){x/sum(x)}); diag(Q) <- -rowSums(Q)

all_children <- Children(phy, (1 + nb.tip):(nb.node + nb.tip) )
df <- length(phy$edge.length)
bl <- rep(0.1, df)

# employ nlminb to find the parameters (branch length estimates) that minimize the target function sum_phylo_log_lk
opt <- nlminb(bl, function(p) sum_phylo_log_lk(p), lower = 1e-6, upper = Inf, control=list(iter.max=500, eval.max=500, trace=1))
print(opt$par)
