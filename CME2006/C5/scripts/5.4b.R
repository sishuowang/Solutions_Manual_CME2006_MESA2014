#! /usr/bin/env Rscript


########################################
lnl_JC69 <- function(d, n, x){
    x*log(3/4-3/4*exp(-4/3*d)) + (n-x)*log(1/4+3/4*exp(-4/3*d))
}

do_mcmc <- function(w, nsample, n, x){
    e <- w # epsilon
    ds <- numeric(nsample)
    accepts <- numeric(nsample)
    d <- 0.8; lnl <- lnl_JC69(d, n, x)
    for(i in 2:nsample){
        r <- runif(1,0,1)
        c <- exp(e*(r-0.5))
        d_new <- c * d
        d_new <- ifelse(d_new>=0, d_new, d)
        lnl_new <- lnl_JC69(d_new, n, x)
        alpha <- min(1, exp(lnl_new-lnl) * c)
        if(runif(1) < alpha){
            d <- d_new
            lnl <- lnl_new
            accepts[i] <- 1
        }
        ds[i] <- d
    }
    return(list(ds=ds, accepts=accepts))
}


########################################
x <- 90; n<-948
w <- 0.3; nsample <- 100000

for(w in seq(0.1,2,0.1)){
    res <- do_mcmc(w=w, nsample=nsample, n=n, x=x)
    ds <- res$ds; accepts <- res$accepts
    burnin <- round(nsample/2)
    ds_after_burnin <- ds[burnin:nsample]
    accepts_after_burnin <- accepts[burnin:nsample]
    acceptance_ratio <- length(accepts_after_burnin[accepts_after_burnin==1])/length(accepts_after_burnin)
    cat(w, mean(ds_after_burnin), acceptance_ratio, '\n', sep="\t")
}


