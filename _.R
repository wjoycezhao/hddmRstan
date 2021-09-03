# # import(Rcpp)
# # import(methods)
# # importFrom(rstan,sampling)
# # useDynLib(hddmRstan, .registration = TRUE)
#
# pkgbuild::compile_dll(force = TRUE)
# devtools::install(quick = FALSE)
# devtools::install(quick = TRUE)
# roxygen2::roxygenise(clean = TRUE)
#
# usethis::use_package("plyr")
# usethis::use_package("dplyr")
# usethis::use_package("data.table")
# usethis::use_package("stringr")
# usethis::use_vignette("tutorial")
#
# data_example = read.csv('riskDDM_exp4.csv')
# data_example$gain = data_example$gain/100
# data_example$loss = data_example$loss/100
# data_example = dplyr::filter(data_example, subj_idx<9)
# data_example = dplyr::select(data_example, -leftV, -rightV, -keyPress, -up_accept, -keyPress, -gPlusLoss)
# usethis::use_data(data_example, data_example, overwrite = TRUE)
# head(data_example)

use_readme_rmd(open = rlang::is_interactive())

require(devtools)

require(hddmRstan)
require(dplyr)
test = 1
if (test) {
  seed = 1
  warmup = 0
  iter = 3
  chains = 2
} else {
  seed = 1
  warmup = 500
  iter = 1000
  chains = 1
}
stan_data_hddm = runModel(
  data = data_example,
  # or use the file name of the csv
  # file_name = 'risk_data.csv',
  a_coef = 'Intercept',
  t_coef = 'Intercept',
  z_coef = c('Intercept'),
  v_coef = c('Intercept', 'gain', 'loss'),
  seed = seed,
  warmup = warmup,
  iter = iter,
  chains = chains,
  sample_file = 'other/x.csv',
  csv_name_para = 'other/parax.csv',
  csv_name_diag = 'other/diagx.csv'
)
