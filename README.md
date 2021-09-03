
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hddmRstan

<!-- badges: start -->
<!-- badges: end -->

The goal of hddmRstan is to provide a convenient way to fit hierarchical
drift diffusion models (DDM) using Rstan. Additionally, each of the DDM
parameters can be linearly dependent on some variables.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("wjoycezhao/hddmRstan")
```

## Load package

``` r
require(hddmRstan)
#> Loading required package: hddmRstan
```

## Format data

-   **subj\_idx**: subject IDs; start from 1 and be consecutive.
-   **response**: binary, 1 (upper boundary) or 0 (lower boundary).
-   **rt**: response time in seconds.
-   **other columns**: variables that DDM parameters are linearly
    dependent on.

``` r
unique(data_example$subj_idx) 
#> [1] 1 2 3 4 5 6 7 8
head(data_example)
#>   subj_idx response       rt trialNum gain loss
#> 1        1        1 8.310281        1  0.7 -0.6
#> 2        1        1 0.798285        2  0.6 -0.3
#> 3        1        0 1.017669        3  0.3 -1.0
#> 4        1        0 1.332322        4  0.3 -0.6
#> 5        1        0 1.946687        5  0.1 -0.2
#> 6        1        0 0.704754        6  0.1 -0.7
```

Scale data when possible:

``` r
data_example$trialNum = data_example$trialNum/200
head(data_example)
#>   subj_idx response       rt trialNum gain loss
#> 1        1        1 8.310281    0.005  0.7 -0.6
#> 2        1        1 0.798285    0.010  0.6 -0.3
#> 3        1        0 1.017669    0.015  0.3 -1.0
#> 4        1        0 1.332322    0.020  0.3 -0.6
#> 5        1        0 1.946687    0.025  0.1 -0.2
#> 6        1        0 0.704754    0.030  0.1 -0.7
```

## Run model

``` r
test = 1
if(test){
  seed = 1
  warmup = 0
  iter = 10
  chains = 2
} else {
  seed = 1
  warmup = 500
  iter = 1000
  chains = 4
}

stan_data_hddm = runModel(
  data = data_example,
  #### or read from a .csv file
  ## file_name = 'data_sample.csv', 
  a_coef = 'Intercept',
  t_coef = 'Intercept',
  z_coef = c('Intercept', 'trialNum'),
  v_coef = c('Intercept', 'gain', 'loss'),
  refresh = 2,
  seed = seed,
  warmup = warmup,
  iter = iter,
  chains = chains,
  csv_name_para = NULL,
  csv_name_diag = NULL
)
#> [1] "Range of RT: [0.400293, 9.482172]"
#> Warning: There were 20 divergent transitions after warmup. See
#> http://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
#> to find out why this is a problem and how to eliminate them.
#> Warning: Examine the pairs() plot to diagnose sampling problems
#> Warning: The largest R-hat is NA, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> http://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> http://mc-stan.org/misc/warnings.html#bulk-ess
```

## Details about the runModel function

``` r
?runModel
```

<table width="100%" summary="page for runModel {hddmRstan}">
<tr>
<td>
runModel {hddmRstan}
</td>
<td style="text-align: right;">
R Documentation
</td>
</tr>
</table>
<h2>
Fit the hddm
</h2>
<h3>
Description
</h3>
<p>
Fit the hddm
</p>
<h3>
Usage
</h3>
<pre>
runModel(
  file_name = NULL,
  data = NULL,
  a_coef = "Intercept",
  t_coef = "Intercept",
  z_coef = c("Intercept", "context1", "context2"),
  v_coef = c("Intercept", "highValue", "lowValue", "context1", "context2"),
  seed = sample(1e+05, 1),
  warmup = warmup,
  iter = iter,
  chains = chains,
  cores = chains,
  csv_name_para = NULL,
  csv_name_diag = NULL,
  sample_file = NULL,
  init_r = 1,
  refresh = 500,
  adapt_delta = 0.99,
  stepsize = 0.05,
  max_treedepth = 20
)
</pre>
<h3>
Arguments
</h3>
<table summary="R argblock">
<tr valign="top">
<td>
<code>file\_name</code>
</td>
<td>
<p>
Name of the .csv data file. Columns needed include subj\_idx, resp, rt,
and all coefficient columns.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>data</code>
</td>
<td>
<p>
A data frame. Columns needed include subj\_idx, resp, rt, and all
coefficient columns.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>a\_coef</code>
</td>
<td>
<p>
Coefficients for DDM threshold. Default: Intercept.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>t\_coef</code>
</td>
<td>
<p>
Coefficients for DDM non-decision time. Default: Intercept.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>z\_coef</code>
</td>
<td>
<p>
Coefficients for DDM starting point. Default: Intercept.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>v\_coef</code>
</td>
<td>
<p>
Coefficients for DDM drift rate. Default: Intercept.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>seed</code>
</td>
<td>
<p>
Seed number
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>warmup</code>
</td>
<td>
<p>
Warm-up or burn-in number. Default 0.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>iter</code>
</td>
<td>
<p>
Iteration number. Default 10.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>chains</code>
</td>
<td>
<p>
Chain number. Default 1.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>cores</code>
</td>
<td>
<p>
Number of cores to be used. Default = chain number.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>sample\_file</code>
</td>
<td>
<p>
Save model details
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>init\_r</code>
</td>
<td>
<p>
Default 1.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>refresh</code>
</td>
<td>
<p>
Default 500
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>adapt\_delta</code>
</td>
<td>
<p>
Default 0.99
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>stepsize</code>
</td>
<td>
<p>
Default 0.05
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>max\_treedepth</code>
</td>
<td>
<p>
Default 20
</p>
</td>
</tr>
</table>
<hr />

<div style="text-align: center;">

\[Package <em>hddmRstan</em> version 0.0.0.9000
<a href="00Index.html">Index</a>\]

</div>

## Results

To get the stanfit object, use the following

``` r
stan_data_hddm$stan_hddm
```

Show model diagnostics

``` r
stan_data_hddm$diag
#>     waic   p_waic      lppd p_waic_1 elapsed_time_min elapsed_time_max rhat_max
#> 1 817899 398747.1 -10202.41 22957.19         0.036337         0.039341      Inf
#>    ess_min divergent max_tree
#> 1 1.052632        20        0
```

Show posteror distribution summary

``` r
stan_data_hddm$para[,c(1:3,13)]
#>                            mean       median        2.5%       97.5%
#> a_Intercept_mu     -0.112511065 -0.112511065 -0.19238189 -0.03264025
#> a_Intercept_sd      1.029210232  1.029210232  1.00296342  1.05545705
#> a_Intercept_subj.1  0.183270561  0.183270561 -0.06791412  0.43445524
#> a_Intercept_subj.2 -0.855641021 -0.855641021 -1.01376575 -0.69751629
#> a_Intercept_subj.3 -0.622758255 -0.622758255 -0.99214914 -0.25336737
#> a_Intercept_subj.4 -0.400704488 -0.400704488 -0.70241837 -0.09899061
#> a_Intercept_subj.5 -0.136689155 -0.136689155 -0.25613766 -0.01724065
#> a_Intercept_subj.6 -0.027169181 -0.027169181 -0.14237262  0.08803426
#> a_Intercept_subj.7 -0.022397114 -0.022397114 -0.55508402  0.51028979
#> a_Intercept_subj.8 -0.403486737 -0.403486737 -1.00115138  0.19417790
#> t_Intercept_mu     -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_sd      0.901499248  0.901499248  0.41212100  1.39087750
#> t_Intercept_subj.1 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.2 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.3 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.4 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.5 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.6 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.7 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> t_Intercept_subj.8 -1.608705681 -1.608705681 -1.60870568 -1.60870568
#> v_Intercept_mu      0.086162960  0.086162960 -0.21569213  0.38801805
#> v_gain_mu           0.147793766  0.147793766 -0.58535157  0.88093910
#> v_loss_mu          -0.203294509 -0.203294509 -0.33176072 -0.07482830
#> v_Intercept_sd      0.976060088  0.976060088  0.89216824  1.05995193
#> v_gain_sd           0.570641924  0.570641924  0.46237253  0.67891132
#> v_loss_sd           1.137344632  1.137344632  0.96867056  1.30601870
#> v_Intercept_subj.1 -0.450638588 -0.450638588 -1.08072500  0.17944782
#> v_Intercept_subj.2 -0.434263357 -0.434263357 -1.00285962  0.13433291
#> v_Intercept_subj.3 -0.054206614 -0.054206614 -0.53224507  0.42383184
#> v_Intercept_subj.4  0.427643607  0.427643607  0.37097311  0.48431410
#> v_Intercept_subj.5  0.187669428  0.187669428  0.04997798  0.32536087
#> v_Intercept_subj.6  0.417847393  0.417847393 -0.58516428  1.42085907
#> v_Intercept_subj.7 -0.350462126 -0.350462126 -0.59795674 -0.10296751
#> v_Intercept_subj.8 -0.009930908 -0.009930908 -0.41501646  0.39515464
#> v_gain_subj.1       0.427765256  0.427765256 -0.23038211  1.08591262
#> v_gain_subj.2      -0.100076159 -0.100076159 -0.84159130  0.64143898
#> v_gain_subj.3       0.106327069  0.106327069 -0.37514213  0.58779627
#> v_gain_subj.4       0.006201073  0.006201073 -1.09942831  1.11183046
#> v_gain_subj.5      -0.171992317 -0.171992317 -1.04560575  0.70162112
#> v_gain_subj.6       0.352624518  0.352624518 -0.45580846  1.16105750
#> v_gain_subj.7      -0.023575220 -0.023575220 -0.78378529  0.73663485
#> v_gain_subj.8       0.273172263  0.273172263 -0.12142130  0.66776583
#> v_loss_subj.1       0.440051612  0.440051612 -0.06200499  0.94210821
#> v_loss_subj.2      -0.488906314 -0.488906314 -1.01262931  0.03481668
#> v_loss_subj.3      -0.120293040 -0.120293040 -0.24162372  0.00103764
#> v_loss_subj.4       0.241147128  0.241147128  0.02796946  0.45432480
#> v_loss_subj.5      -1.005829074 -1.005829074 -1.55478649 -0.45687165
#> v_loss_subj.6       0.591079616  0.591079616  0.32631857  0.85584066
#> v_loss_subj.7       0.053845456  0.053845456 -0.60048568  0.70817660
#> v_loss_subj.8      -0.999325474 -0.999325474 -1.41819020 -0.58046075
#> z_Intercept_mu     -0.327309975 -0.327309975 -0.75189455  0.09727460
#> z_trialNum_mu       0.038067263  0.038067263 -0.81232168  0.88845620
#> z_Intercept_sd      0.607174990  0.607174990  0.51457274  0.69977724
#> z_trialNum_sd       0.718400391  0.718400391  0.70992814  0.72687264
#> z_Intercept_subj.1 -0.401715318 -0.401715318 -0.49914027 -0.30429036
#> z_Intercept_subj.2  0.105877036  0.105877036 -0.39906358  0.61081766
#> z_Intercept_subj.3 -0.239112394 -0.239112394 -0.35298678 -0.12523801
#> z_Intercept_subj.4 -0.759314330 -0.759314330 -1.41060955 -0.10801911
#> z_Intercept_subj.5  0.061811057  0.061811057 -0.21448079  0.33810290
#> z_Intercept_subj.6 -0.240403445 -0.240403445 -0.92613649  0.44532960
#> z_Intercept_subj.7  0.122130046  0.122130046 -0.21997323  0.46423333
#> z_Intercept_subj.8 -0.435277852 -0.435277852 -0.94919109  0.07863539
#> z_trialNum_subj.1  -0.056457466 -0.056457466 -0.64558207  0.53266714
#> z_trialNum_subj.2  -0.051759827 -0.051759827 -0.87956129  0.77604164
#> z_trialNum_subj.3   0.125460851  0.125460851 -0.30812384  0.55904554
#> z_trialNum_subj.4   0.090325364  0.090325364 -1.38267349  1.56332422
#> z_trialNum_subj.5  -0.289958118 -0.289958118 -1.42053565  0.84061941
#> z_trialNum_subj.6   0.400922998  0.400922998 -0.65065173  1.45249772
#> z_trialNum_subj.7  -0.058015876 -0.058015876 -1.28857030  1.17253854
#> z_trialNum_subj.8   0.191857503  0.191857503 -0.48854363  0.87225863
#> a_mean_grand        0.839066479  0.839066479  0.77470208  0.90343088
#> t_mean_grand        0.200146500  0.200146500  0.20014650  0.20014650
#> v_mean_grand        0.114059192  0.114059192 -0.67209025  0.90020863
#> z_mean_grand        0.455006385  0.455006385  0.44213150  0.46788127
#> a_mean_subj.1       1.239231184  1.239231184  0.93434071  1.54412166
#> a_mean_subj.2       0.430335105  0.430335105  0.36285000  0.49782021
#> a_mean_subj.3       0.573480831  0.573480831  0.37077898  0.77618269
#> a_mean_subj.4       0.700568522  0.700568522  0.49538583  0.90575122
#> a_mean_subj.5       0.878471264  0.878471264  0.77403541  0.98290712
#> a_mean_subj.6       0.979661777  0.979661777  0.86729802  1.09202553
#> a_mean_subj.7       1.119898942  1.119898942  0.57402403  1.66577385
#> a_mean_subj.8       0.790884206  0.790884206  0.36745612  1.21431229
#> t_mean_subj.1       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.2       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.3       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.4       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.5       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.6       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.7       0.200146500  0.200146500  0.20014650  0.20014650
#> t_mean_subj.8       0.200146500  0.200146500  0.20014650  0.20014650
#> v_mean_subj.1      -0.457396084 -0.457396084 -1.72559468  0.81080251
#> v_mean_subj.2      -0.220406772 -0.220406772 -0.90878871  0.46797517
#> v_mean_subj.3       0.070155991  0.070155991 -0.60229452  0.74260650
#> v_mean_subj.4       0.298423277  0.298423277 -0.37025011  0.96709666
#> v_mean_subj.5       0.639072553  0.639072553  0.63472815  0.64341695
#> v_mean_subj.6       0.284099166  0.284099166 -1.30957396  1.87777229
#> v_mean_subj.7      -0.391417442 -0.391417442 -1.39315459  0.61031971
#> v_mean_subj.8       0.689942847  0.689942847  0.29820643  1.08167926
#> z_mean_subj.1       0.395858357  0.395858357  0.34899476  0.44272195
#> z_mean_subj.2       0.519600405  0.519600405  0.49775248  0.54144833
#> z_mean_subj.3       0.457711777  0.457711777  0.37494693  0.54047662
#> z_mean_subj.4       0.335481306  0.335481306  0.31567719  0.35528542
#> z_mean_subj.5       0.498745161  0.498745161  0.49553765  0.50195267
#> z_mean_subj.6       0.491970665  0.491970665  0.45599335  0.52794798
#> z_mean_subj.7       0.522983664  0.522983664  0.46749778  0.57846955
#> z_mean_subj.8       0.417699746  0.417699746  0.37681313  0.45858636
```
