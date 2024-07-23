# Define the proposal function for x and y
proposal_function_x <- function(x, step=10) {
  return(runif(1, x - step/2, x + step/2))
}

proposal_function_y <- function(y, step=10) {
  return(runif(1, y - step/2, y + step/2))
}

# Initialize the chain
chain <- matrix(0, nrow=10000, ncol=2)
chain[1,] <- c(10000, 0)

# Metropolis-Hastings algorithm
for (i in 2:nrow(chain)) {
  # Propose moves for x and y separately
  proposal_x <- proposal_function_x(chain[i-1, 1])
  proposal_y <- proposal_function_y(chain[i-1, 2])

  # Calculate log likelihood ratios for x and y separately
  log_likelihood_ratio_x <- log_likelihood(proposal_x, chain[i-1, 2]) - log_likelihood(chain[i-1, 1], chain[i-1, 2])
  log_likelihood_ratio_y <- log_likelihood(chain[i-1, 1], proposal_y) - log_likelihood(chain[i-1, 1], chain[i-1, 2])

  # Accept or reject proposals for x and y separately
  if (runif(1) < min(1, exp(log_likelihood_ratio_x))) {
    chain[i, 1] <- proposal_x
  } else {
    chain[i, 1] <- chain[i-1, 1]
  }

  if (runif(1) < min(1, exp(log_likelihood_ratio_y))) {
    chain[i, 2] <- proposal_y
  } else {
    chain[i, 2] <- chain[i-1, 2]
  }
}

accepted <- chain[-1, ] != chain[-nrow(chain), ]
accepted_fraction <- mean(accepted)

print(accepted_fraction)
apply(chain[-c(1:8000),], 2, mean)
