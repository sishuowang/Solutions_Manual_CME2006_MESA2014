#! /usr/bin/env Rscript


########################################
# assume branch_length ~ Uniform(0,10)
lnprior_unif <- function(d){
	log(dunif(d,0,10))
}

lnl_JC69 <- function(d, n, x){
    x*log(3/4-3/4*exp(-4/3*d)) + (n-x)*log(1/4+3/4*exp(-4/3*d))
}

do_mcmc <- function(w, nsample, n, x){
    ds <- numeric(nsample)
    accepts <- numeric(nsample)
    d <- 0.8
	
	# log-prior
	lnprior <- lnprior_unif(d)
	
	# log-likelihood
	lnl <- lnl_JC69(d, n, x)
	
	# log-posterior
	lnposterior <- lnprior + lnl
	
    for(i in 2:nsample){
        d_new <- runif(1, d-w/2, d+w/2)
        d_new <- ifelse(d_new>=0, d_new, d)
		
        lnposterior_new <- lnprior_unif(d_new) + lnl_JC69(d_new, n, x)
        alpha <- min(1, exp(lnposterior_new-lnposterior))
        if(runif(1) < alpha){
            d <- d_new
            lnposterior <- lnposterior_new
            accepts[i] <- 1
        }
        ds[i] <- d
    }
    return(list(ds=ds, accepts=accepts))
}


########################################
x <- 90; n<-948
w <- 0.3; nsample <- 10000

for(w in seq(0.02,0.5,0.04)){
    res <- do_mcmc(w=w, nsample=nsample, n=n, x=x)
    ds <- res$ds; accepts <- res$accepts
    burnin <- round(nsample/2)
    ds_after_burnin <- ds[burnin:nsample]
    accepts_after_burnin <- accepts[burnin:nsample]
    acceptance_ratio <- length(accepts_after_burnin[accepts_after_burnin==1])/length(accepts_after_burnin)
    cat(w, mean(ds_after_burnin), acceptance_ratio, '\n', sep="\t")
}


