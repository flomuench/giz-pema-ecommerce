### POWER SIMULATION FOR INTERACTION EFFECTS OF BINARY VARIABLES ###
### Adapted from here: https://egap.org/resource/script-power-analysis-simulations-in-r/
### Created by Teo Firpo on 29.10.2021

# This power simulation assumes a binary outcome variable, binary treatment and 
# binary covariates (e.g. gender); it can be used to estimate the power achieved  
# when estimating the interaction between the treatment and the binary covariate.

# HOW TO USE IT: A key input is how much does the outcome varies by the covariate. 
# Delta and lambda add to the main effect for each group, respectively. 
# Delta varies while lambda is fixed.
# beta0 is the expected effect for the control group. Tau is the main effect. 

possible.deltas <- seq(from=0.03, to=0.1, by=0.0025)  # The deltas we'll be considering
powers <- rep(NA, length(possible.deltas))            # Empty object to collect simulation estimates
alpha <- 0.025                                        # Standard significance level
sims <- 500                                           # Number of simulations to conduct for each N

#### Outer loop to vary the number of subjects ####
for (j in 1:length(possible.deltas)){
  delta <- possible.deltas[j]                      # Pick the jth value for delta
  significant.experiments <- rep(NA, sims)         # Empty object to count significant experiments
  
  #### Inner loop to conduct experiments "sims" times over for each beta0 ####
  for (i in 1:sims){
    Nm <- 2728                                            # Set N for men
    Nw <- 500                                             # Set N for women
    N <- Nm+Nw                                            # Set total N
    beta0 <- 0.025                                        # Set baseline rate (for control group)
    tau <- 0.00                                           # Set main effect size
    lambda <- 0.00                                        # Set whether outcome changes for men
    men <- rep(0, times = Nm)                             # Create vector for men
    women <- rep(1, times = Nw)                           # ... and women
    gender <- c(men, women)                               # and join them into a gender vector
    Y0 <-  rbinom(n=N, size=1, prob=beta0)                # Control potential outcome
    Ym <-  rbinom(n=N, size=1, prob=(beta0+tau-lambda))   # Outcome for treated men
    Yw <-  rbinom(n=N, size=1, prob=(beta0+tau+delta))    # Outcome for treated women
    Y1 <- gender*Ym + Yw*(1-gender)                       # Potential treatment outcomes depending to gender 
    Z.sim <- rbinom(n=N, size=1, prob=.5)                 # Do a random assignment
    Y.sim <- Y1*Z.sim + Y0*(1-Z.sim)                      # Reveal outcomes according to assignment
    fit.sim <- lm(Y.sim ~ Z.sim + gender + gender:Z.sim)  # Do analysis (Simple regression)
    p.value <- summary(fit.sim)$coefficients[4,4]         # Extract p-values
    significant.experiments[i] <- (p.value <= alpha)      # Determine significance according to p <= 0.05
  }
  
  powers[j] <- mean(significant.experiments)       # store average success rate (power) for each N
}
### Make a nice plot
subtitle =paste("Main effect size =", tau*100, "pp, control group =", beta0*100)
plot(possible.deltas, powers, ylim=c(0,1), 
     main = "Achieved power by size of interaction effect" ,
     mtext(subtitle),
     xlab = "Size of delta (interaction effect)",
     ylab = "Power",
     cex.main=1.2)
grid(ny=NULL, lty="dotted")
segments(x0=0, y0=0.8, x1=0.8, lty=2)