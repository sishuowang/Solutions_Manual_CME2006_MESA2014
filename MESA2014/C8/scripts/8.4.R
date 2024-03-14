get_lnl <- function(p, n, x){
    lnl <- x*log(p) + (n-x)*log(1-p)
}
integrand <- function(k) exp(get_lnl(k,n=n,x=x))
###########################################
p <- 0.5
n <- 1000
n_sim <- 1000

marginal_lks <- numeric(n_sim)

for(i in 1:n_sim){
    x <- rbinom(1, n, p)
    i1 <- integrate(integrand, 0,1/2)
    i2 <- integrate(integrand, 1/2,1)
    marginal_lk <- i1$value/(i1$value+i2$value)
    marginal_lks[i] <- marginal_lk
}

pdf("8.4-1.pdf")
hist(marginal_lks, breaks=30)
dev.off()
