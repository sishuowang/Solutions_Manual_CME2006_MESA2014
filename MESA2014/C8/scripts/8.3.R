get_lnl <- function(p, n, x){
    lnl <- x*log(p) + (n-x)*log(1-p)
}
###########################################
p <- 0.5
n <- 10000
n_sim <- 1000

marginal_lks <- numeric(n_sim)
for(i in 1:n_sim){
    x <- rbinom(1, n, p)
    ps <- c(0.4, 0.6)
    lnls <- sapply(ps, get_lnl, n=n, x=x)
    #print(c(lnls[2]-lnls[1], 1/(1 + exp(lnls[2] - lnls[1]))))
    lk <- 1/(1 + exp(lnls[2] - lnls[1]))
    marginal_lks[i] <- lk
}
pdf("8.3-1.pdf")
hist(marginal_lks, breaks=30)
dev.off()
