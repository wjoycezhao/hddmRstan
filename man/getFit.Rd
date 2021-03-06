% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/function_model.R
\name{getFit}
\alias{getFit}
\title{Get stanfit}
\usage{
getFit(
  stan_data,
  stan_model_compiled,
  warmup = 0,
  iter = 10,
  chains = 1,
  cores = chains,
  seed = sample(1e+05, 1),
  sample_file = NULL,
  init_r = 1,
  refresh = 500,
  adapt_delta = 0.99,
  stepsize = 0.05,
  max_treedepth = 20
)
}
\arguments{
\item{stan_data}{Formmated rstan data. Output of getRstanData().}

\item{stan_model_compiled}{stan model.}

\item{warmup}{A positive integer specifying the number of warmup (aka burnin)
    iterations per chain. If step-size adaptation is on (which it is by default), 
    this also controls the number of iterations for which adaptation is run (and
    hence these warmup samples should not be used for inference). The number of 
    warmup iterations should be smaller than \code{iter} and the default is
    \code{iter/2}.}

\item{iter}{A positive integer specifying the number of iterations for each 
    chain (including warmup). The default is 2000.}

\item{chains}{A positive integer specifying the number of Markov chains. 
    The default is 4.}

\item{cores}{Number of cores to use when executing the chains in parallel,
    which defaults to 1 but we recommend setting the \code{mc.cores} option 
    to be as many processors as the hardware and RAM allow (up to the 
    number of chains).}

\item{seed}{The seed for random number generation. The default is generated 
    from 1 to the maximum integer supported by \R on the machine. Even if 
    multiple chains are used, only one seed is needed, with other chains having 
    seeds derived from that of the first chain to avoid dependent samples.
    When a seed is specified by a number, \code{as.integer} will be applied to it. 
    If \code{as.integer} produces \code{NA}, the seed is generated randomly. 
    The seed can also be specified as a character string of digits, such as
    \code{"12345"}, which is converted to integer.}

\item{sample_file}{An optional character string providing the name of a file.
    If specified the draws for \emph{all} parameters and other saved quantities
    will be written to the file. If not provided, files are not created. 
    When the folder specified is not writable, \code{tempdir()} is used. 
    When there are multiple chains, an underscore and chain number are appended
    to the file name prior to the \code{.csv} extension.}

\item{refresh}{Show progress. Default 500}

\item{adapt_delta}{Default 0.99}

\item{stepsize}{Default 0.05}

\item{max_treedepth}{Default 20}

\item{save_model_file}{Specify a name if you want to save the RStan samples and diagnostics to a csv file.}
}
\description{
Get stanfit
}
