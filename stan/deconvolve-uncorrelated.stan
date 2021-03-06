data {
  // Smallest (most negative) delay
  int delay_min;
  
  // Length of delay distribution
  int n_delay;
  
  // PMF of delay distribution
  simplex[n_delay] pmf_delay;
  
  // Initial time of observed time series
  int t_obs_min;
  
  // Length of observed, delayed time series
  int n_obs;
  
  // Delayed observations
  int<lower=0> y_obs[n_obs];
  
  // Initial time of unobserved, undelayed time series
  int t_unobs_min;
  
  // Length of unobserved, undelayed time series
  int n_unobs;
  
  // Scale of observations, used to scale prior for unobserved states
  real<lower=0> scale_scale_x;
}

parameters {
  // An inferred scale for the half-normal prior on unobserved states
  real<lower=0> scale_x;
  
  // Unobserved states
  vector<lower=0>[n_unobs] x_unobs;
}

transformed parameters {
  vector[n_obs] lambda_obs = rep_vector(1e-10, n_obs);
  
  // Compute lambda_obs by directly looping over all unobserved states
  // and all delays.
  for(i_unobs in 1:n_unobs) {
    int t_unobs = t_unobs_min + i_unobs - 1;
    for(i_delay in 1:n_delay) {
      int delay = delay_min + i_delay - 1;
      int t_obs = t_unobs + delay;
      int i_obs = t_obs - t_obs_min + 1;
      if(i_obs >= 1 && i_obs <= n_obs) {
        lambda_obs[i_obs] += pmf_delay[i_delay] * x_unobs[i_unobs];
      }
    }
  }
}

model {
  scale_x ~ normal(0, scale_scale_x);
  x_unobs ~ normal(0, scale_x);
  y_obs ~ poisson(lambda_obs);
}
