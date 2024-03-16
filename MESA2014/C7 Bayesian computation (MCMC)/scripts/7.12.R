#! /usr/bin/env Rscript

# Number of iterations and chains
num_iterations <- 100000
num_chains <- 2

# Initialize chains
chains <- matrix(0, nrow = num_iterations, ncol = num_chains)

# Set initial values for each chain
chains[1, ] <- numeric(num_chains)

# Define temperatures for each chain
temperatures <- c(1, 10)  # Cold chain and hot chain

# Define the target distribution (mixture of normals)
target_distribution <- function(x) {
  weights <- c(0.2, 0.5, 0.3)
  means <- c(-2, 0, 1.5)
  sigma <- 0.1
  density <- sum(weights * sapply(means, function(mu) dnorm(x, mean = mu, sd = sigma)))
  return(log(density))  # Calculate the log density
}

# Function to perform a Metropolis-Hastings step
metropolis_hastings_step <- function(current, proposal, temperature, log_target) {
  log_acceptance_ratio <- (log_target(proposal) - log_target(current)) / temperature
  if (log(runif(1)) < log_acceptance_ratio) {
    return(proposal)
  } else {
    return(current)
  }
}

accepted_swap <- 0
# Perform Parallel Tempering MCMC
for (i in 2:num_iterations) {
  for (chain in 1:num_chains) {
    current_value <- chains[i-1, chain]
    proposal_value <- runif(1, current_value-0.5, current_value+0.5)
    
    # Adjust the proposal based on the chain's temperature
    temperature <- temperatures[chain]
    
    chains[i, chain] <- metropolis_hastings_step(
      current_value, proposal_value, temperature, target_distribution
    )
  }

  # Perform chain swapping with a certain probability
  if (i %% 100 == 1) {
    swap_chain <- c(1,2)
    chain1 <- swap_chain[1]
    chain2 <- swap_chain[2]
    current_values <- chains[i, c(chain1, chain2)]
    
    # Compute the Metropolis-Hastings acceptance ratio for swapping
    log_acceptance_ratio_swap <- (1/temperatures[chain2] - 1/temperatures[chain1]) * (target_distribution(current_values[chain1]) - target_distribution(current_values[chain2]))
    
    if (log(runif(1)) < log_acceptance_ratio_swap) {
      # Swap the values between chain1 and chain2
      chains[i, c(chain1, chain2)] <- chains[i, c(chain2, chain1)]
      accepted_swap <- accepted_swap + 1
    }
  }
}

# Plot
plot(density(chains[-(1:num_iterations/2), 1]), main = "MCMCMC", xlab = "", col = "purple", xlim=c(-5,5))
cat(paste("accepted swap:", accepted_swap), "\n")

