generate_pair_sequence_k80 <- function(d,k,l){
    p0<-1/4+1/4*exp(-4*d/(k+2))+1/2*exp(-2*d*(k+1)/(k+2))
    p1<-1/4+1/4*exp(-4*d/(k+2))-1/2*exp(-2*d*(k+1)/(k+2))
    p2<-1/4-1/4*exp(-4*d/(k+2))

    P<-matrix(c(p0,p1,p2,p2,p1,p0,p2,p2,p2,p2,p0,p1,p2,p2,p1,p0),ncol=4,byrow=T)
    freq<-rep(0.25,4)
    A <- freq*P

    dna <- c("T","C","A","G")
    dna_pair <- expand.grid(dna,dna)
    dna_pair_char<-paste(dna_pair[,1], dna_pair[,2], sep="")

    sample(dna_pair_char, l, prob=A, replace=T);
}
estimate_d_k_from_seq <- function(sequence){
    n_s <- 0; n_v <- 0
    transition <- c("TC", "CT", "AG", "GA")
    transversion <- c("TA", "TG", "CA", "CG", "AC", "AT", "GC", "GT")
    for(i in names(table(sequence))){
        num <- as.numeric(unname(table(sequence)[i]))
        if(i %in% transition){
            n_s <- n_s + num 
        } else if(i %in% transversion){
            n_v <- n_v + num 
        }   
    }   
    s <- n_s/length(sequence)
    v <- n_v/length(sequence)
    d_hat = -1/2*log(1-2*s-v) - 1/4*log(1-2*v)
    k_hat = 2*log(1-2*s-v)/log(1-2*v) - 1
    return(c(d_hat,k_hat))
}

> for(d in seq(0.01,2,0.01)){
    k_hats <- sapply(1:1000, function(i){
        sequence <- generate_pair_sequence_k80(d=d,k=2,l=500)
        x <- estimate_d_k_from_seq(sequence)
        return(x[2])
    })
    k_hats <- k_hats[!is.na(k_hats) & !is.infinite(k_hats)]
    cat(mean(k_hats), var(k_hats), "\n")
}
