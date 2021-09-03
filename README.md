
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
#>   subj_idx response       rt trial_no gain loss
#> 1        1        1 8.310281        1  0.7 -0.6
#> 2        1        1 0.798285        2  0.6 -0.3
#> 3        1        0 1.017669        3  0.3 -1.0
#> 4        1        0 1.332322        4  0.3 -0.6
#> 5        1        0 1.946687        5  0.1 -0.2
#> 6        1        0 0.704754        6  0.1 -0.7
```

Scale data when possible:

``` r
data_example$trial_no = data_example$trial_no/200
head(data_example)
#>   subj_idx response       rt trial_no gain loss
#> 1        1        1 8.310281    0.005  0.7 -0.6
#> 2        1        1 0.798285    0.010  0.6 -0.3
#> 3        1        0 1.017669    0.015  0.3 -1.0
#> 4        1        0 1.332322    0.020  0.3 -0.6
#> 5        1        0 1.946687    0.025  0.1 -0.2
#> 6        1        0 0.704754    0.030  0.1 -0.7
```

## Run model

``` r
test = 0
if(test){
  seed = 1
  warmup = 0
  iter = 10
  chains = 2
} else {
  seed = 1
  warmup = 400
  iter = 700
  chains = 4
}

stan_data_hddm = runModel(
  data = data_example,
  #### or read from a .csv file
  ## file_name = 'data_sample.csv', 
  a_coef = 'Intercept',
  t_coef = 'Intercept',
  z_coef = c('Intercept', 'trial_no'),
  v_coef = c('Intercept', 'gain', 'loss'),
  seed = seed,
  warmup = warmup,
  iter = iter,
  refresh = iter/10,
  chains = chains,
  csv_name_para = NULL,
  csv_name_diag = NULL
)
#> [1] "Range of RT: [0.408558, 9.482172]"
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> http://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> http://mc-stan.org/misc/warnings.html#tail-ess
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
  z_coef = "Intercept",
  v_coef = "Intercept",
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
The seed for random number generation. The default is generated from 1
to the maximum integer supported by <span
style="font-family: Courier New, Courier; color: #666666;"><b>R</b></span>
on the machine. Even if multiple chains are used, only one seed is
needed, with other chains having seeds derived from that of the first
chain to avoid dependent samples. When a seed is specified by a number,
<code>as.integer</code> will be applied to it. If
<code>as.integer</code> produces <code>NA</code>, the seed is generated
randomly. The seed can also be specified as a character string of
digits, such as <code>“12345”</code>, which is converted to integer.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>warmup</code>
</td>
<td>
<p>
A positive integer specifying the number of warmup (aka burnin)
iterations per chain. If step-size adaptation is on (which it is by
default), this also controls the number of iterations for which
adaptation is run (and hence these warmup samples should not be used for
inference). The number of warmup iterations should be smaller than
<code>iter</code> and the default is <code>iter/2</code>.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>iter</code>
</td>
<td>
<p>
A positive integer specifying the number of iterations for each chain
(including warmup). The default is 2000.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>chains</code>
</td>
<td>
<p>
A positive integer specifying the number of Markov chains. The default
is 4.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>cores</code>
</td>
<td>
<p>
Number of cores to use when executing the chains in parallel, which
defaults to 1 but we recommend setting the <code>mc.cores</code> option
to be as many processors as the hardware and RAM allow (up to the number
of chains).
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>csv\_name\_para</code>
</td>
<td>
<p>
Save model details
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>csv\_name\_diag</code>
</td>
<td>
<p>
Save model details
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>sample\_file</code>
</td>
<td>
<p>
An optional character string providing the name of a file. If specified
the draws for <em>all</em> parameters and other saved quantities will be
written to the file. If not provided, files are not created. When the
folder specified is not writable, <code>tempdir()</code> is used. When
there are multiple chains, an underscore and chain number are appended
to the file name prior to the <code>.csv</code> extension.
</p>
</td>
</tr>
<tr valign="top">
<td>
<code>refresh</code>
</td>
<td>
<p>
Show progress. Default 500
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
#>       waic  p_waic      lppd p_waic_1 elapsed_time_min elapsed_time_max
#> 1 789.9547 43.2236 -351.7538 36.95766         235.7804         329.2083
#>   rhat_max  ess_min divergent max_tree
#> 1 1.012487 243.1025         0        0
```

Show posteror distribution summary

``` r
stan_data_hddm$para[,c(1:3,13)]
#>                           mean      median         2.5%        97.5%
#> a_Intercept_mu      1.04597701  1.04451512  0.886010572  1.207147712
#> a_Intercept_sd      0.16703304  0.15177215  0.038417042  0.377418625
#> a_Intercept_subj.1  1.04291794  1.04187802  0.915524070  1.173359219
#> a_Intercept_subj.2  0.92247933  0.92269316  0.723954434  1.113764290
#> a_Intercept_subj.3  1.22636571  1.22592918  1.055754350  1.383904517
#> a_Intercept_subj.4  1.14349358  1.14023035  0.957923053  1.347553684
#> a_Intercept_subj.5  1.05162996  1.04380764  0.780138538  1.350557314
#> a_Intercept_subj.6  1.06714844  1.06077849  0.845180369  1.326023066
#> a_Intercept_subj.7  1.03116344  1.03132830  0.848215432  1.237014294
#> a_Intercept_subj.8  0.93377052  0.93424366  0.780982231  1.094884734
#> t_Intercept_mu     -0.88645787 -0.89801018 -1.054661918 -0.687360680
#> t_Intercept_sd      0.18996470  0.18240982  0.015896051  0.435536679
#> t_Intercept_subj.1 -0.90542738 -0.90610870 -1.189957737 -0.656853128
#> t_Intercept_subj.2 -0.89138994 -0.88289619 -1.052638360 -0.782226862
#> t_Intercept_subj.3 -0.86404872 -0.87814120 -1.214988444 -0.539698678
#> t_Intercept_subj.4 -0.59644253 -0.53370011 -0.981335377 -0.272763020
#> t_Intercept_subj.5 -0.98572146 -0.97374834 -1.125342435 -0.918360984
#> t_Intercept_subj.6 -0.88830904 -0.87768455 -1.056494275 -0.786341472
#> t_Intercept_subj.7 -0.98928584 -0.98028790 -1.104063745 -0.930235449
#> t_Intercept_subj.8 -0.96460784 -0.95180308 -1.175097459 -0.835675431
#> v_Intercept_mu     -0.10412039 -0.09557776 -0.576596638  0.273655245
#> v_gain_mu           1.30646713  1.31539512  0.232088612  2.328546320
#> v_loss_mu           1.99417166  2.01698161  1.026372130  2.758894955
#> v_Intercept_sd      0.35586448  0.32565889  0.011619322  0.909468879
#> v_gain_sd           1.50328548  1.45525881  0.875352582  2.342184892
#> v_loss_sd           1.01966072  0.98619847  0.353503965  1.891024509
#> v_Intercept_subj.1  0.02245431  0.01007487 -0.426561766  0.518297326
#> v_Intercept_subj.2 -0.21959484 -0.17510559 -0.946592160  0.351269214
#> v_Intercept_subj.3  0.10493091  0.09160959 -0.335370672  0.594123804
#> v_Intercept_subj.4  0.07696457  0.04776566 -0.413447947  0.677783092
#> v_Intercept_subj.5 -0.05744154 -0.05506386 -0.732897083  0.582140172
#> v_Intercept_subj.6 -0.37627943 -0.29767420 -1.290523818  0.255051991
#> v_Intercept_subj.7 -0.05259654 -0.04998055 -0.689141791  0.552431512
#> v_Intercept_subj.8 -0.38168551 -0.31434808 -1.245374856  0.237642170
#> v_gain_subj.1       2.02267269  2.03323961  1.310971793  2.689857487
#> v_gain_subj.2       2.06821019  2.06490843  1.019047757  3.129642293
#> v_gain_subj.3       0.65098368  0.65677991 -0.059890615  1.360884073
#> v_gain_subj.4       2.68736184  2.68170500  1.828995403  3.610955715
#> v_gain_subj.5       0.02611516  0.03620807 -1.325847938  1.347146500
#> v_gain_subj.6       0.44215641  0.41701478 -0.486836853  1.494850117
#> v_gain_subj.7       0.94617450  0.94241425 -0.003935377  1.938538536
#> v_gain_subj.8       4.41322226  4.38573157  3.169888871  5.813234322
#> v_loss_subj.1       2.06362698  2.07386814  1.339594157  2.840631352
#> v_loss_subj.2       3.00893910  3.00296633  1.948090400  4.052543131
#> v_loss_subj.3       1.82621288  1.82344780  1.111888599  2.598416087
#> v_loss_subj.4       2.52421711  2.51677919  1.755173919  3.395907814
#> v_loss_subj.5       2.67445075  2.63692941  1.300308746  4.180642141
#> v_loss_subj.6       1.20857044  1.21418602  0.262568209  2.103828152
#> v_loss_subj.7       1.39769222  1.40249275  0.506236197  2.228230696
#> v_loss_subj.8       3.54458458  3.54327407  2.207909090  4.882321647
#> z_Intercept_mu     -0.52211779 -0.52316001 -1.030544091  0.017588783
#> z_trial_no_mu      -0.19422249 -0.16616661 -1.643688378  1.291100313
#> z_Intercept_sd      0.68599989  0.64958320  0.313761564  1.244396875
#> z_trial_no_sd       2.19967244  2.22249411  0.855954722  3.391685389
#> z_Intercept_subj.1 -0.49641107 -0.49494839 -1.003912439 -0.004727308
#> z_Intercept_subj.2 -0.38226531 -0.38829963 -0.952164881  0.219178132
#> z_Intercept_subj.3  0.12376895  0.12279608 -0.441223758  0.724523308
#> z_Intercept_subj.4 -0.26795172 -0.26360142 -0.803099599  0.275985401
#> z_Intercept_subj.5 -1.16418720 -1.15958214 -1.932211861 -0.480588721
#> z_Intercept_subj.6 -0.82993816 -0.83368310 -1.449634826 -0.223171096
#> z_Intercept_subj.7 -1.33384626 -1.33269898 -1.909825779 -0.794241448
#> z_Intercept_subj.8  0.02116770  0.01116037 -0.567948432  0.605445026
#> z_trial_no_subj.1   2.39012641  2.38985614 -0.700473080  5.803140520
#> z_trial_no_subj.2  -1.12293042 -1.08995798 -4.056072831  1.668984209
#> z_trial_no_subj.3  -1.04144503 -0.99869007 -4.298494600  2.181243947
#> z_trial_no_subj.4   1.63972871  1.64173548 -1.451338744  4.991634509
#> z_trial_no_subj.5  -3.79984879 -3.84445425 -7.851187130 -0.186357798
#> z_trial_no_subj.6  -2.30706476 -2.27449143 -5.375272284  0.474198697
#> z_trial_no_subj.7  -1.32637753 -1.26775543 -4.079063587  1.417851566
#> z_trial_no_subj.8   3.01847705  2.99306646 -0.317010436  6.561363084
#> a_mean_grand        2.89216307  2.88464017  2.661261124  3.170439106
#> t_mean_grand        0.41899268  0.41900293  0.376970830  0.462896011
#> v_mean_grand       -0.45626179 -0.45576113 -0.614451858 -0.300145537
#> z_mean_grand        0.37762442  0.37705981  0.345687112  0.412645434
#> a_mean_subj.1       2.84389504  2.83453534  2.498084081  3.232834217
#> a_mean_subj.2       2.52779754  2.51605743  2.062573484  3.045802126
#> a_mean_subj.3       3.41996037  3.40733065  2.874142490  3.990452041
#> a_mean_subj.4       3.15443605  3.12748874  2.606277762  3.848000739
#> a_mean_subj.5       2.89245865  2.84001020  2.181775720  3.859575945
#> a_mean_subj.6       2.92916185  2.88861895  2.328397757  3.766036478
#> a_mean_subj.7       2.81734988  2.80478897  2.335475369  3.445311477
#> a_mean_subj.8       2.55224516  2.54528762  2.183616036  2.988838218
#> t_mean_subj.1       0.40796018  0.40409362  0.304234244  0.518480585
#> t_mean_subj.2       0.41111225  0.41358336  0.349015731  0.457386341
#> t_mean_subj.3       0.42734084  0.41555463  0.296713839  0.582923887
#> t_mean_subj.4       0.56474023  0.58643111  0.374810251  0.761273173
#> t_mean_subj.5       0.37369273  0.37766477  0.324541315  0.399172756
#> t_mean_subj.6       0.41233721  0.41574444  0.347672521  0.455508243
#> t_mean_subj.7       0.37223247  0.37520307  0.331521127  0.394460824
#> t_mean_subj.8       0.38252551  0.38604433  0.308788908  0.433581528
#> v_mean_subj.1       0.04112008  0.04114540 -0.199120085  0.298941691
#> v_mean_subj.2      -0.91187378 -0.91008172 -1.354449159 -0.480237219
#> v_mean_subj.3      -0.46345008 -0.46142894 -0.705719031 -0.232813596
#> v_mean_subj.4       0.33459766  0.33365074  0.046589570  0.639572697
#> v_mean_subj.5      -1.46600202 -1.46659832 -2.203382962 -0.717543583
#> v_mean_subj.6      -0.74592704 -0.74013529 -1.169692025 -0.356429049
#> v_mean_subj.7      -0.31138553 -0.30847262 -0.676816928  0.048392316
#> v_mean_subj.8      -0.12717358 -0.12806729 -0.499392214  0.218301812
#> z_mean_subj.1       0.45301784  0.45235023  0.374653726  0.537407907
#> z_mean_subj.2       0.37378867  0.37023559  0.269813636  0.485964637
#> z_mean_subj.3       0.49553007  0.49335880  0.402806118  0.596182102
#> z_mean_subj.4       0.48550057  0.48610694  0.385260942  0.589931241
#> z_mean_subj.5       0.18359065  0.18035098  0.107911842  0.285378987
#> z_mean_subj.6       0.24684004  0.24267596  0.163181577  0.352406233
#> z_mean_subj.7       0.18485708  0.18166242  0.127933325  0.255344356
#> z_mean_subj.8       0.59787040  0.59985420  0.502747630  0.682335220
```
