#! /usr/bin/env Rscript

suppressPackageStartupMessages({
  library(getopt)
  library(seqinr)
  library(ape)
})

# ---------------------------
# Helpers
# ---------------------------

read_alignment_matrix <- function(fasta_file, tip_order) {
  s <- read.fasta(fasta_file, seqtype = "DNA", as.string = FALSE, forceDNAtolower = FALSE)
  if (length(s) == 0) stop("No sequences found in FASTA.")
  if (!all(tip_order %in% names(s))) stop("Some tree tips are missing in FASTA.")
  if (!all(names(s) %in% tip_order)) warning("Some FASTA names are not in tree tips; they will be ignored.")

  s <- s[tip_order]  # reorder by tree tips
  lens <- vapply(s, length, integer(1))
  if (length(unique(lens)) != 1) stop("Sequences have different lengths.")
  L <- lens[1]

  # matrix: ntip x L (characters)
  aln <- do.call(rbind, lapply(s, function(x) toupper(as.character(x))))
  rownames(aln) <- tip_order
  aln
}

compress_patterns <- function(aln) {
  # aln: ntip x nsite character matrix
  key <- apply(aln, 2, paste, collapse = "|")
  tab <- table(key)
  uniq_keys <- names(tab)
  idx <- match(uniq_keys, key)
  pat <- aln[, idx, drop = FALSE]
  w <- as.numeric(tab)
  list(patterns = pat, weights = w)
}

encode_states <- function(pat) {
  states <- sort(unique(as.vector(pat)))
  map <- setNames(seq_along(states), states)
  pat_int <- matrix(map[pat], nrow = nrow(pat), ncol = ncol(pat))
  list(pat_int = pat_int, states = states, nl = length(states))
}

make_equal_rates_Q <- function(nl) {
  # Symmetric equal-rates model over nl states
  Q <- matrix(1, nl, nl)
  diag(Q) <- 0
  Q <- Q / rowSums(Q)
  diag(Q) <- -rowSums(Q)
  Q
}

build_fast_objective <- function(phy, pat_int, weights, Q) {
  phy <- reorder.phylo(phy, order = "postorder")

  ntip <- length(phy$tip.label)
  nnode <- phy$Nnode
  N <- ntip + nnode
  edge <- phy$edge
  nedge <- nrow(edge)

  children_by_parent <- split(edge[, 2], edge[, 1])
  edges_by_parent <- split(seq_len(nedge), edge[, 1])

  internal_nodes <- sort(as.integer(names(children_by_parent)), decreasing = TRUE)
  root <- ntip + 1L  # ape convention for rooted phylo objects

  nl <- nrow(Q)
  npat <- ncol(pat_int)
  pi_root <- rep(1 / nl, nl)

  # Precompute tip partial likelihoods once: each is nl x npat one-hot matrix
  tip_liks <- vector("list", ntip)
  for (i in seq_len(ntip)) {
    M <- matrix(0, nrow = nl, ncol = npat)
    M[cbind(pat_int[i, ], seq_len(npat))] <- 1
    tip_liks[[i]] <- M
  }

  # Storage reused each objective call
  L <- vector("list", N)
  for (i in seq_len(ntip)) L[[i]] <- tip_liks[[i]]
  for (i in (ntip + 1):N) L[[i]] <- matrix(0, nrow = nl, ncol = npat)
  log_scale <- numeric(npat)

  # Eigendecomposition of Q once
  eg <- eigen(Q)
  V <- eg$vectors
  Vinv <- solve(V)
  lam <- eg$values

  make_P <- function(t) {
    e <- exp(lam * t)
    # diag(e) %*% Vinv via row scaling
    tmp <- sweep(Vinv, 1, e, `*`)
    Re(V %*% tmp)
  }

  fn <- function(bl) {
    # transition matrix per edge
    P <- lapply(bl, make_P)

    log_scale[] <- 0

    for (anc in internal_nodes) {
      ch <- children_by_parent[[as.character(anc)]]
      ed <- edges_by_parent[[as.character(anc)]]

      part <- matrix(1, nrow = nl, ncol = npat)

      for (k in seq_along(ch)) {
        child <- ch[k]
        eidx <- ed[k]
        part <- part * (P[[eidx]] %*% L[[child]])
      }

      sc <- colSums(part)
      sc[sc < 1e-300] <- 1e-300
      L[[anc]][] <- sweep(part, 2, sc, `/`)
      log_scale <- log_scale + log(sc)
    }

    root_like <- colSums(L[[root]] * pi_root)
    root_like[root_like < 1e-300] <- 1e-300

    # Negative log-likelihood
    -sum(weights * (log(root_like) + log_scale))
  }

  fn
}

# ---------------------------
# CLI
# ---------------------------

spec <- matrix(c(
  "tree",   "t", 1, "character",
  "traits", "s", 1, "character",
  "cpu",    "n", 2, "integer"
), ncol = 4, byrow = TRUE)

opt <- getopt(spec)
if (is.null(opt$tree) || is.null(opt$traits)) {
  cat("Usage: script.R -t tree.nwk -s aln.fasta [-n cpu]\n")
  quit(status = 1)
}

phy <- read.tree(opt$tree)
if (!inherits(phy, "phylo")) stop("Input tree is not a valid 'phylo' object.")
if (is.null(phy$edge.length)) {
  warning("Tree has no edge lengths; initializing all to 0.1")
  phy$edge.length <- rep(0.1, nrow(phy$edge))
}

aln <- read_alignment_matrix(opt$traits, phy$tip.label)
cat("Alignment length:", ncol(aln), "\n")

cp <- compress_patterns(aln)
enc <- encode_states(cp$patterns)

cat("Unique site patterns:", ncol(enc$pat_int), "\n")
cat("Number of states:", enc$nl, "\n")

Q <- make_equal_rates_Q(enc$nl)
obj <- build_fast_objective(
  phy = phy,
  pat_int = enc$pat_int,
  weights = cp$weights,
  Q = Q
)

start_bl <- pmax(phy$edge.length, 1e-6)

fit <- nlminb(
  start = start_bl,
  objective = obj,
  lower = rep(1e-8, length(start_bl)),
  upper = rep(Inf, length(start_bl)),
  control = list(iter.max = 500, eval.max = 500, trace = 1)
)

cat("\nConvergence code:", fit$convergence, "\n")
cat("Final negative logLik:", fit$objective, "\n")
cat("Estimated branch lengths:\n")
print(fit$par)
