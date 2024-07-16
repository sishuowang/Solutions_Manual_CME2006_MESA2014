proposal_function <- function(x, y, step=10) {
  return(c(runif(1, x - step/2, x + step/2), runif(1, y - step/2, y + step/2)))
}

# Initialize the chain
chain <- matrix(0, nrow=10000, ncol=2)
chain[1,] <- c(10000, 0)


######################################################
######################################################
# Define the log-likelihood function
log_likelihood <- function(x, y) {
  return(-(x^2 + y^2 + x^2 * y^2))
}

# Metropolis-Hastings algorithm
for (i in 2:nrow(chain)) {
  proposal <- proposal_function(chain[i-1, 1], chain[i-1, 2])

  log_likelihood_ratio <- log_likelihood(proposal[1], proposal[2]) - log_likelihood(chain[i-1, 1], chain[i-1, 2])

  if (runif(1) < min(1, exp(log_likelihood_ratio))) {
    chain[i,] <- proposal
  } else {
    chain[i,] <- chain[i-1,]
  }
}

accepted <- chain[-1, ] != chain[-nrow(chain), ]
accepted_fraction <- mean(accepted)

print(accepted_fraction)
apply(chain[-c(1:8000),], 2, mean)
