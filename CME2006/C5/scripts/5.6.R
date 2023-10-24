#! /usr/bin/env Rscript


########################################
lnl_JC69 <- function(d, n, n_diff){
    n_diff*log(3/4-3/4*exp(-4/3*d)) + (n-n_diff)*log(1/4+3/4*exp(-4/3*d))
}


lnl_K80 <- function(param, n, ns, nv){
    # f(d) = Exp(d|1/0.2); f(k) = Exp(k|1/5)
    d <- param[1]; k <- param[2]
    p0 <- 1/4+1/4*exp(-4*d/(k+2))+1/2*exp(-2*d*(k+1)/(k+2))
    p1 <- 1/4+1/4*exp(-4*d/(k+2))-1/2*exp(-2*d*(k+1)/(k+2))
    p2 <- 1/4-1/4*exp(-4*d/(k+2))
    log_prior <- log(dexp(d,1/0.2)) + log(dexp(k,1/5))
    lnl <- (n-ns-nv)*log(p0/4) + ns*log(p1/4) + nv*log(p2/4)
    return(log_prior + lnl)
}


do_mcmc <- function(w, nsample, n, ns, nv){
    w.k <- 10 # Mario used w.k=180 but note it's for a diff prior (https://github.com/thednainus/Bayesian_tutorial)
    posteriors <- matrix(0, nsample, 2)
    accepts <- matrix(0, nsample, 2)
    d <- 0.05; k <- 5
    param_new <- c(d, k)
    lnl <- lnl_K80(param_new, n, ns, nv)
    for(i in 2:nsample){
        d_new <- runif(1, d-w/2, d+w/2)
        d_new <- ifelse(d_new>=0, d_new, d)
        param_new[1] <- d_new
        lnl_new <- lnl_K80(param_new, n, ns, nv)
        alpha <- min(1, exp(lnl_new-lnl))
        if(runif(1) < alpha){
            d <- d_new
            lnl <- lnl_new
            accepts[i,1] <- 1
        }

        k_new <- runif(1, k-w.k/2, k+w.k/2)
        k_new <- ifelse(k_new>=0, k_new, k)
        param_new[2] <- k_new
        lnl_new <- lnl_K80(param_new, n, ns, nv)
        alpha <- min(1, exp(lnl_new-lnl))
        #cat(k, k_new, alpha, "\n")
        if(runif(1) < alpha){
            k <- k_new
            lnl <- lnl_new
            accepts[i,2] <- 1
        }

        posteriors[i-1,] <- c(d,k)
    }
    return(list(posteriors=posteriors, accepts=accepts))
}


########################################
ns <- 84; nv <- 6; n_diff <- ns+nv; n<-948
w <- NULL; nsample <- 10000; every <- 1

calculate_acceptance_ratio <- function(v){
    length(v[v==1])/length(v)
}

for(w in seq(0.02,0.5,0.04)){
    res <- do_mcmc(w=w, nsample=nsample, n=n, ns=ns, nv=nv)
    posteriors <- res$posteriors; accepts <- res$accepts
    burnin <- round(nsample/2)
    posteriors_after_burnin <- posteriors[seq(burnin,nsample,every), ]

    accepts_after_burnin <- accepts[seq(burnin,nsample,every),]
    acceptance_ratio <- apply(accepts_after_burnin, 2, calculate_acceptance_ratio)

    cat(w, apply(posteriors_after_burnin,2,mean), acceptance_ratio, '\n', sep="\t")
pdf("trace.pdf")
plot(posteriors_after_burnin[,2], ty = "l")
lines(posteriors_after_burnin[,2], col="red")
#plot(seq(1:length(posteriors_after_burnin[,2])), posteriors_after_burnin[,2])
dev.off()
}



