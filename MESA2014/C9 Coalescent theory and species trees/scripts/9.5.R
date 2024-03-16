# 9.5.R
#! /usr/bin/env Rscript
library(expm)
g <- function(m,theta){
    matrix(c(-2*m-2/theta,m,0,0,0, 2*m,-2*m,2*m,0,0, 0,m,-2*m-2/theta,0,0, 2/theta,0,0,-m,m, 0,0,2/theta,m,-m), ncol=5)
}
h0 <- function(t){
    theta<-0.005; m<-4*M/theta
    sum(sapply(c(1,3), function(x){ init * 2/theta * expm(g(m=m,theta=theta)*t)[1:3,x]}))
}
h1 <- function(t) {
    theta <- 0.005; theta_a <- 0.003; m <- 4*M/theta; m_a <- 4*M/theta_a
    dexp(t-tau, 2/theta_a) * sum(sapply(c(1,2,3), function(x){ init * expm(g(m=m,theta=theta)*tau)[1:3,x]}))
}
h <- function(t, tau=0.005) if(t<tau){h0(t)} else{h1(t)}

###########################################
pdf("9.5.pdf")
par(mfrow=c(1,2)); tau <- 0.005
inits <- data.frame(c(0.5,0,0.5), c(0,1,0)) # (0.5,0,0.5) -> f0, (0,1,0) -> f1
for(i in 1:ncol(inits)){
    init <- inits[,i]
    p <- Vectorize(h)
    M <- 0.01
    curve(p, from=0, to=2*tau, col="blue")
    integrate(p, lower=0, upper=1)
    M <- 100000
    curve(p, from=0, to=2*tau, add=T, col="red")
    legend(x = "topright", legend=c("M=0.01", "M=10"),  
           fill = c("blue","red")
    )
}
dev.off()
