% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions_other.R
\name{getWAIC}
\alias{getWAIC}
\title{Get WAIC}
\usage{
getWAIC(stan_fit, logName = "log_lik")
}
\arguments{
\item{stan_fit}{Output of stan}

\item{logName}{}
}
\value{
lppd, p_waic_1, p_waic_2, and waic, defined
as 2*(lppd - p_waic_2), as recommmended in BDA
}
\description{
Get WAIC
}
