library(expm)

# important to note the following
t=1.1; tau=1; theta=1; m=10000 # (m as if infinite)

calc_Q <- function(m, t){
    matrix(c(-2*(m+1/theta), 2*m, 0, 2/t, 0,
             m, -2*m, m, 0, 0,
             0, 2*m, -2*(m+1/theta), 0, 2/theta,
             0, 0, 0, -m, m,
             0, 0, 0, m, -m
    ),
    byrow=T, ncol=5
    )
}

# assume m=10000 (big enough as if infinite), and theta=1 (i use symbol t in the code for simplicity)
Q <- calc_Q(m=10^4, t=1)
P = expm(Q)
rownames(P) = colnames(P) = c("S11", "S12", "S22", "S1", "S2")
print(P)

print(c("for f0", "Eq. 9.50 in Yang 2014", "analytical calculation based on our solutions"))
print(c("f0 (t<=tau):", 2/theta * (P[1,1]+P[1,3]), 1/theta*exp(-1/theta)))
print( c("f0 (t>tau):", sum(P[1,1:3]) * 2/theta * exp(-2/theta*(t-tau)), exp(-1/theta*tau)*2/theta*exp(-2*(t-tau)/theta)) )