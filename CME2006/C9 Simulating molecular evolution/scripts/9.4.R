sample2 <- function(d, base, nsamples=1){
    p0 <- 1/4 + 3/4*exp(-4*d/3)
    p1 <- (1-p0)/3
    bases <- c(base, setdiff(BASES, base))
    sample(bases, nsamples, prob=c(p0,rep(p1,3)), replace=T)
}

sim_seq <- function(l){
    seq <-  matrix(0, nrow=4, ncol=l)
    dimnames(seq) = list(paste0('S',1:4), paste0('site',1:l))
    for (i in 1:l){
        for(s0 in sample(BASES, 1, prob=rep(0.25,4), replace=T)){
            list2env( setNames(as.list(sample2(d=0.1, s0, nsamples=2)), paste0('s', c(1,5))), envir = .GlobalEnv )
            s3 <- sample2(d=0.5, s0)
            s2 <- sample2(d=0.1, s5)
            s4 <- sample2(d=0.5, s5)
            seq[1,i] <- s1
            seq[2,i] <- s2
            seq[3,i] <- s3
            seq[4,i] <- s4
        }
    }
    return(seq)
}

determine_mp <- function(x){
    if(identical(as.integer(table(x)), as.integer(c(2,2)))){
        if(x[1] == x[3]){
            'xxyy'
        } else if(x[1] == x[2]){
            'xyxy'
        } else if(x[1] == x[4]){
            'xyyx'
        }
    } else{
        return(NA)
    }
}

> BASES <- c("T", "C", "A", "G")

> for(l in c(100,1000,10000)){
    c_total <- numeric(3)
    names(c_total) <- c('xxyy', 'xyxy', 'xyyx')
    for(n in 1:100){
        seq_matrix <- sim_seq(l=l)
        pattern <- apply(seq_matrix, 2, determine_mp)
        count <- table(pattern[!is.na(pattern)])
        mp_index <- which(count == max(count))
        for(i in names(count[mp_index]) ){
            c_total[i] <- c_total[i] + 1/length(mp_index)
        }
    }
    print(c_total)
}
