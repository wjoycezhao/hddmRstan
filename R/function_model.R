#' Fit the hddm
#'
#' @param file_name Name of the .csv data file. Columns needed include subj_idx, resp, rt, and all coefficient columns.
#' @param data A data frame. Columns needed include subj_idx, resp, rt, and all coefficient columns.
#' @param a_coef Coefficients for DDM threshold. Default: Intercept.
#' @param t_coef Coefficients for DDM non-decision time. Default: Intercept.
#' @param z_coef Coefficients for DDM starting point. Default: Intercept.
#' @param v_coef Coefficients for DDM drift rate. Default: Intercept.
#' @param seed Seed number
#' @param warmup Warm-up or burn-in number. Default 0.
#' @param iter Iteration number. Default 10.
#' @param chains Chain number. Default 1.
#' @param cores Number of cores to be used. Default = chain number.
#' @param sample_file Save model details
#' @param init_r Default 1.
#' @param refresh Default 500
#' @param adapt_delta Default 0.99
#' @param stepsize Default 0.05
#' @param max_treedepth Default 20
#' @export

runModel = function(file_name =NULL,
                    data = NULL,
                    a_coef = 'Intercept',
                    t_coef = 'Intercept',
                    z_coef = 'Intercept',
                    v_coef = 'Intercept',
                    seed = sample(1e+5,1), warmup = warmup, iter = iter, chains = chains, cores = chains,
                    csv_name_para = NULL, csv_name_diag = NULL,
                    sample_file = NULL,
                    init_r = 1, refresh = 500,
                    adapt_delta = 0.99, stepsize = 0.05, max_treedepth = 20){
  if (is.null(file_name) & is.null(data)) stop('Sorry but there is no data...')
  if (!is.null(file_name) & !is.null(data)) stop('Please specify one data source only :)')
  if (is.null(data)){data = data.table::fread(file_name)}
  stan_data = getRstanData(file_name = file_name,
                           data = data,
                           a_coef = a_coef,
                           t_coef = t_coef,
                           z_coef = z_coef,
                           v_coef = v_coef)

  stan_hddm = getFit(stan_data, stanmodels$hddm,
                     warmup = warmup, iter = iter, chains = chains, cores = cores,
                     seed = seed, sample_file = sample_file,
                     init_r = init_r, refresh = refresh,
                     adapt_delta = adapt_delta, stepsize = stepsize, max_treedepth = max_treedepth)

  para = getParaSummary(stan_data, stan_hddm, csv_name = csv_name_para)
  diag = getModelDiag(stan_hddm, csv_name = csv_name_diag)
  return(list(stan_data = stan_data, stan_hddm = stan_hddm,
              para = para, diag = diag))
}



#' Get stanfit
#'
#' @param stan_data Formmated rstan data. Output of getRstanData().
#' @param stan_model_compiled stan model.
#' @param save_model_file Specify a name if you want to save the RStan samples and diagnostics to a csv file.
#' @inheritParams runModel
#' @export
getFit = function(stan_data, stan_model_compiled,
                  warmup = 0, iter = 10, chains = 1, cores = chains,
                  seed = sample(1e+5,1), sample_file = NULL,
                  init_r = 1, refresh = 500,
                  adapt_delta = 0.99, stepsize = 0.05, max_treedepth = 20){
  initf <- function() {
    list(
      t_beta_mu_raw = matrix(c(log(min(stan_data$rt)/2), rep(0, each = nrow(stan_data$t_x) - 1)), nrow = nrow(stan_data$t_x), ncol = 1),
      t_beta_raw = matrix(0, nrow = nrow(stan_data$t_x), ncol = stan_data$S),
      t = matrix(min(stan_data$rt)/2, nrow = nrow(stan_data$t_x), ncol = stan_data$S))
  }
  stan_hddm = rstan::sampling(stan_model_compiled,
                              sample_file = sample_file,
                              data = stan_data,
                              seed = seed,
                              init_r = init_r,
                              init = initf,
                              refresh = refresh,
                              warmup = warmup, iter = iter, chains = chains, cores = cores,
                              control=list(adapt_delta=adapt_delta, stepsize = stepsize, max_treedepth = max_treedepth))
  return(stan_hddm)
}


#' Get formatted data for rstan
#'
#' @inheritParams runModel
#' @export
getRstanData = function(file_name =NULL,
                        data = NULL,
                        a_coef = 'Intercept',
                        t_coef = 'Intercept',
                        z_coef = 'Intercept',
                        v_coef = 'Intercept'){
  data = dplyr::arrange(data, subj_idx)
  data = dplyr::mutate(data, Intercept = 1)
  S = length(unique(data$subj_idx))
  N = nrow(data)
  subj = data$subj_idx
  print(paste0('Range of RT: [', min(data$rt), ', ', max(data$rt), ']'))
  if(max(data$rt) > 50) {stop('There are large RTs in the data (>50 seconds). Please rescale.')}

  getX = function(coef){
    return(t(as.matrix(dplyr::select(data, coef))))
  }
  a_x = getX(a_coef)
  t_x = getX(t_coef)
  v_x = getX(v_coef)
  z_x = getX(z_coef)
  stan_data = list(
    N = N, # number of trials
    S = S, # number of subjects
    subj = subj, # vector of subject id
    rt = data$rt,  # RT in seconds
    resp = data$resp, # 1 if high ranked target was chosen
    a_x = a_x,
    t_x = t_x,
    z_x = z_x,
    v_x = v_x,
    Ka = nrow(a_x),
    Kt = nrow(t_x),
    Kz = nrow(z_x),
    Kv = nrow(v_x),
    subj_start = sapply(1:S, function(x) min(which(subj == x))),
    subj_end = sapply(1:S, function(x) max(which(subj == x))),
    a_coef = a_coef,
    t_coef = t_coef,
    z_coef = z_coef,
    v_coef = v_coef
  )
  return(stan_data)
}



#' Change variable names
#'
#' @param names A vector of characters. Variables taken from rstan outputs.
#' @inheritParams getStanFit
#' @param Q Number of questions
#' @param S Number of participants
#' @export
changeBetaNames = function(names, para, para_coef, S) {
  for (x in 1:length(para_coef)) {
    names = plyr::mapvalues(
      names,
      warn_missing = FALSE,
      from = c(
        paste0(para, '_', 'beta_mu[', x, ']'),
        paste0(para, '_', 'beta_sd[', x, ']'),
        paste0(para, '_', 'beta[', x, ',', 1:S, ']'),
        paste0(para, '_', 'beta_mu.', x, '.'),
        paste0(para, '_', 'beta_sd.', x, '.'),
        paste0(para, '_', 'beta.', x, '.', 1:S, '.')),
      to = c(
        paste0(para, '_', para_coef[x], '_mu'),
        paste0(para, '_', para_coef[x], '_sd'),
        paste0(para, '_', para_coef[x], '_subj.', 1:S),
        paste0(para, '_', para_coef[x], '_mu'),
        paste0(para, '_', para_coef[x], '_sd'),
        paste0(para, '_', para_coef[x], '_subj.', 1:S))
    )
  }
    names = plyr::mapvalues(
      names,
      warn_missing = FALSE,
      from = c(paste0(para, "_mean_subj[",1:S,"]"),
               paste0(para, "_mean_subj.",1:S, '.')),
      to = c(paste0(para, "_mean_subj.",1:S),
             paste0(para, "_mean_subj.",1:S)))
    # names = plyr::mapvalues(
    #   names,
    #   warn_missing = FALSE,
    #   from = c(
    #     paste0('beta_mu[', x, ']'),
    #     paste0('beta[', x, ']'),
    #     paste0('beta_q_sd[', x, ']'),
    #     paste0('beta_s_sd[', x, ']'),
    #     paste0('beta_qmean[', x, ',', 1:Q, ']'),
    #     paste0('beta_smean[', x, ',', 1:S, ']'),
    #     paste0('beta_qdev[', x, ',', 1:Q, ']'),
    #     paste0('beta_sdev[', x, ',', 1:S, ']'),
    #     unlist(lapply(1:Q, function(y)
    #       paste0('beta.', y, '.', x, '.', 1:S)))
    #   ),
    #   to = c(
    #     paste0('beta_', beta[x], '_mu'),
    #     paste0('beta_', beta[x]),
    #     paste0('beta_', beta[x], '_q_sd'),
    #     paste0('beta_', beta[x], '_s_sd'),
    #     paste0('beta_', beta[x], '_qmean_', 1:Q),
    #     paste0('beta_', beta[x], '_smean_', 1:S),
    #     paste0('beta_', beta[x], '_qdev_', 1:Q),
    #     paste0('beta_', beta[x], '_sdev_', 1:S),
    #     unlist(lapply(1:Q, function(y)
    #       paste0('beta_', beta[x], '_', y, '_', 1:S)))
    #   )
    # )
  return(names)
}

#' Parameter summary.
#'
#' \code{getParaSummary} returns parameter summaries for group and individual level parameters,
#' including means, percentiles, and sd.
#' It also saves the results to a .csv file when \code{csv_name} is specified
#'
#' @param stan_hddm model outputs obtained from getStanFit
#' @param csv_name if specified then outputs will be saved in a .csv file starting with this name
#' @inheritParams getStanFit
#' @export
getParaSummary = function(stan_data, stan_hddm, csv_name = NULL) {
  para_name = colnames(as.data.frame(stan_hddm))
  parameters0 = para_name[stringr::str_detect(para_name,'a_|t_|z_|v_')]
  parameters0 = parameters0[!stringr::str_detect(para_name,'subj|mean|raw')]
  parameters0 = sort(parameters0)
  parameters0 = c(parameters0,
                  para_name[stringr::str_detect(para_name,'mean_grand')],
                  para_name[stringr::str_detect(para_name,'mean_subj')])

  df = t(sapply(as.data.frame(
    rstan::extract(stan_hddm, pars = parameters0)
  ), quantile1))

  for (i in c('a', 't', 'z', 'v')){
    rownames(df) = changeBetaNames(rownames(df), i, stan_data[[paste0(i,'_coef')]], stan_data$S)
  }

  if (!is.null(csv_name)) {
    write.table(
      df,
      csv_name,
      sep = ",",
      append = FALSE,
      quote = FALSE,
      col.names = NA,
      row.names = TRUE
    )
  }
  return(df)
}

#' Model diagnostics.
#'
#' \code{getModelDiag} returns model diagnostics,
#' and save the results to a .csv file when \code{csv_name} is specified
#'
#' @param dev_name string. name for dev in rstan codes
#' @inheritParams getParaSummary
#' @inheritParams getWAIC
#'
#' @return A dataframe indicating DIC, WAIC, model running time,
#' maximum rhat, minimum effective sample size,
#' number of divergent transitions and number of max treedepth hit.
#' @export

getModelDiag = function(stan_hddm,
                        csv_name = NULL,
                        dev_name = 'dev',
                        logName = 'log_lik') {
  time = getTime(stan_hddm)
  rhat = getRhat(stan_hddm)
  ess = getESS(stan_hddm)
  ess = ess[!grepl('X_acc', names(ess))]
  df = cbind.data.frame(
    getWAIC(stan_hddm, logName = logName),
    elapsed_time_min = min(time),
    elapsed_time_max = max(time),
    rhat_max = max(rhat, na.rm = T),
    ess_min = min(ess, na.rm = T),
    divergent = rstan::get_num_divergent(stan_hddm),
    max_tree = rstan::get_num_max_treedepth(stan_hddm)
  )
  if (!is.null(csv_name)) {
    write.table(
      df,
      csv_name,
      sep = ",",
      append = FALSE,
      quote = FALSE,
      col.names = NA,
      row.names = TRUE
    )
  }
  return(df)
}
