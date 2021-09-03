data {
  int<lower=0> N; // Trials
  int<lower=0> S; // Subjects
  int<lower=0, upper=S> subj[N]; // subject ID variable
  int Kv;
  int Kz;
  int Ka;
  int Kt;
  // vector[N] highValue; // value of higher ranked target
  // vector[N] lowValue;  // value of lower ranked target
  real rt[N];
  int<lower=0, upper=1> resp[N]; // 1 if higher ranked target is chosen
  // vector[N] context1; // Hh (1) vs No context 
  // vector[N] context2; // Hl (1) vs No context 
  matrix[Ka, N] a_x;
  matrix[Kt, N] t_x;
  matrix[Kv, N] v_x;
  matrix[Kz, N] z_x;
  int subj_start[S];
  int subj_end[S];
}

parameters {
  // Group level parameters 
  // Boundary separation 
  vector[Ka] a_beta_mu; 
  vector<lower=0>[Ka] a_beta_sd;
  // Nondecision time
  matrix[Kt,1] t_beta_mu_raw; 
  vector<lower=0>[Kt] t_beta_sd;
  // starting point 
  vector[Kz] z_beta_mu;
  vector<lower=0>[Kz] z_beta_sd;
  // Drift rate
  vector[Kv] v_beta_mu;
  vector<lower=0>[Kv] v_beta_sd;

  //subject level parameters
  matrix[Ka,S] a_beta_raw;
  matrix[Kt,S] t_beta_raw;
  matrix[Kz,S] z_beta_raw;
  matrix[Kv,S] v_beta_raw;
}

transformed parameters {

  vector[Kt] t_beta_mu; 
  matrix[Ka, S] a_beta;
  matrix[Kt, S] t_beta;
  matrix[Kz, S] z_beta;
  matrix[Kv, S] v_beta;  
  t_beta_mu = to_vector(t_beta_mu_raw);
  a_beta = rep_matrix(a_beta_mu,S) + diag_pre_multiply(a_beta_sd, a_beta_raw);
  t_beta = rep_matrix(t_beta_mu,S) + diag_pre_multiply(t_beta_sd, t_beta_raw);
  v_beta = rep_matrix(v_beta_mu,S) + diag_pre_multiply(v_beta_sd, v_beta_raw);
  z_beta = rep_matrix(z_beta_mu,S) + diag_pre_multiply(z_beta_sd, z_beta_raw);
}

model {
  
  vector[N] a;
  vector[N] t;
  vector[N] v;
  vector[N] z;
  
  for (s in 1:S){
    a[subj_start[s]:subj_end[s]] = exp((a_beta[, s]' * a_x[, subj_start[s]:subj_end[s]])');
    t[subj_start[s]:subj_end[s]] = exp((t_beta[, s]' * t_x[, subj_start[s]:subj_end[s]])');
    v[subj_start[s]:subj_end[s]] = (v_beta[, s]' * v_x[, subj_start[s]:subj_end[s]])' ;
    z[subj_start[s]:subj_end[s]] = inv_logit((z_beta[, s]' * z_x[, subj_start[s]:subj_end[s]])');
  }
  
  // Priors 
  // Group level parameters (Mean)
  // boundary separation (should be positive)
  a_beta_mu ~ std_normal(); 
  // non-decision time (should be positive)
  t_beta_mu[1] ~ normal(-1, 0.4); 
  if(Kt > 1) {t_beta_mu[2:Kt] ~ std_normal();}
  // starting point 
  z_beta_mu ~ std_normal();
  // drift rate
  v_beta_mu ~ std_normal();

  // Group level parameters (standard deviation)
  for (i in 1:Ka) a_beta_sd[i] ~ normal(0, 1) T[0,];
  for (i in 1:Kt) t_beta_sd[i] ~ normal(0, 1) T[0,];
  for (i in 1:Kz) z_beta_sd[i] ~ normal(0, 1) T[0,];
  for (i in 1:Kv) v_beta_sd[i] ~ normal(0, 1) T[0,];

  // Subject level parameters (Sampled from group level parameter) 
  for (i in 1:Ka) a_beta_raw[i] ~ std_normal(); 
  for (i in 1:Kt) t_beta_raw[i] ~ std_normal(); 
  for (i in 1:Kz) z_beta_raw[i] ~ std_normal(); 
  for (i in 1:Kv) v_beta_raw[i] ~ std_normal(); 
  
  // Likeliood of data : following wiener process 
  for (n in 1:N) {
    if (resp[n] == 1) {
      target += wiener_lpdf(rt[n]|a[n], t[n], z[n], v[n]);
    }
    else {
      target += wiener_lpdf(rt[n]|a[n], t[n], 1-z[n], -v[n]);  
    }
  }
}

generated quantities {
  vector[S] a_mean_subj;
  vector[S] t_mean_subj;
  vector[S] v_mean_subj;
  vector[S] z_mean_subj;  
  real a_mean_grand;
  real t_mean_grand;
  real v_mean_grand;
  real z_mean_grand;
  
  vector[N] log_lik;  // log pointwise predictive density
  real dev;
  

  {  
    
    vector[N] a;
    vector[N] t;
    vector[N] v;
    vector[N] z;
  
    for (s in 1:S){
      a[subj_start[s]:subj_end[s]] = exp((a_beta[, s]' * a_x[, subj_start[s]:subj_end[s]])');
      t[subj_start[s]:subj_end[s]] = exp((t_beta[, s]' * t_x[, subj_start[s]:subj_end[s]])');
      v[subj_start[s]:subj_end[s]] = (v_beta[, s]' * v_x[, subj_start[s]:subj_end[s]])';
      z[subj_start[s]:subj_end[s]] = inv_logit((z_beta[, s]' * z_x[, subj_start[s]:subj_end[s]])');
    }
    
    for (s in 1:S){
      a_mean_subj[s] = mean(a[subj_start[s]:subj_end[s]]);
      t_mean_subj[s] = mean(t[subj_start[s]:subj_end[s]]);
      z_mean_subj[s] = mean(z[subj_start[s]:subj_end[s]]);
      v_mean_subj[s] = mean(v[subj_start[s]:subj_end[s]]);
    }
    
    a_mean_grand = mean(a_mean_subj);
    t_mean_grand = mean(t_mean_subj);
    z_mean_grand = mean(z_mean_subj);
    v_mean_grand = mean(v_mean_subj);
    
    
    dev = 0;
    for (n in 1:N) {
      if (resp[n] == 1) {
        log_lik[n] = wiener_lpdf(rt[n]|a[n], t[n],  z[n],  v[n]);
      }
      else {
        log_lik[n] = wiener_lpdf(rt[n]|a[n], t[n], 1-z[n], -v[n]);
      }
      dev = dev - 2*log_lik[n];
    }
  }
}
