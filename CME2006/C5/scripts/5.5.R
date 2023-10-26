#! /usr/bin/env Rscript


########################################
lnl_JC69 <- function(mu, t, n, x){
    d <- 2 * mu * t
    lnprior <- log(dexp(mu, 1)) + log(dexp(t,1/0.15))
    #lnl <- x*log(3/4-3/4*exp(-4/3*d)) + (n-x)*log(1/4+3/4*exp(-4/3*d))
    lnl <- x*log(3/4-3/4*exp(-4*d/3)) + (n-x)*log(1/4+3/4*exp(-4*d/3))
    return(lnprior+lnl)
}

do_mcmc <- function(w, nsample, n, x){
    mus <- ts <- numeric(nsample)
    accepts.mu <- accepts.t <- numeric(nsample)
    mu <- 0.5; t<-1; lnl <- lnl_JC69(mu, t, n, x)
    for(i in 2:nsample){
        mu_new <- runif(1, mu-w/2, mu+w/2)
        mu_new <- ifelse(mu_new>=0, mu_new, mu)
        lnl_new <- lnl_JC69(mu_new, t, n, x)
        alpha <- min(1, exp(lnl_new-lnl))
        if(runif(1) < alpha){
            mu <- mu_new
            lnl <- lnl_new
            accepts.mu[i] <- 1
        }
        mus[i] <- mu

        t_new <- runif(1, t-w/2, t+w/2)
        t_new <- ifelse(t_new>=0, t_new, t)
        lnl_new <- lnl_JC69(mu, t_new, n, x)
        alpha <- min(1, exp(lnl_new-lnl))
        if(runif(1) < alpha){
            t <- t_new
            lnl <- lnl_new
            accepts.t[i] <- 1
        }
        ts[i] <- t
    }
    return(list(mus=mus, ts=ts, accepts.mu=accepts.mu, accepts.t=accepts.t))
}


########################################
x <- 90; n<-948
w <- 0.3; nsample <- 1e6

for(w in seq(0.1,1,0.1)){
    res <- do_mcmc(w=w, nsample=nsample, n=n, x=x)
    mus <- res$mus; ts<-res$ts ; accepts.mu <- res$accepts.mu;  accepts.t <- res$accepts.t
    burnin <- round(nsample/2)
    mus_after_burnin <- mus[burnin:nsample]
    ts_after_burnin <- ts[burnin:nsample]

    accepts_mu_after_burnin <- accepts.mu[burnin:nsample]; accepts_t_after_burnin <- accepts.t[burnin:nsample]
    acceptance_ratio <- c(
        length(accepts_mu_after_burnin[accepts_mu_after_burnin==1])/length(accepts_mu_after_burnin),
        length(accepts_t_after_burnin[accepts_t_after_burnin==1])/length(accepts_t_after_burnin)
    )
    cat(w, mean(mus_after_burnin), mean(ts_after_burnin), acceptance_ratio, '\n', sep="\t")
}
