% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CAMer.R
\name{singleCAM}
\alias{singleCAM}
\title{Continuous Admixture Modeling (CAM) for a Single LD Decay Curve}
\usage{
singleCAM(d, Z, m1, T = 500L, isolation = TRUE, fast.search = TRUE,
  max.duration = 150L, single.parallel = isolation && !fast.search,
  single.clusternum = 4L)
}
\arguments{
\item{d}{the numeric vector of genetic distance (Morgan) of LD decay curve}

\item{Z}{the numeric vector of admixture induced LD (ALD) decay curve}

\item{m1}{the admixture proportion of population 1 or the path of the .log file containing this information. If \code{m2} is the admixing proportion of population 2, then \code{m1+m2=1}. The .log file should be the output of \code{MALDmef}.}

\item{T}{the most ancient generation to be searched. Defaults to 500.}

\item{isolation}{\code{TRUE} if the models used for fitting are HI, CGF1-I, CGF2-I and GA-I; \code{FALSE} if the models used for fitting are HI, CGF1, CGF2 and GA. Defaults to \code{TRUE}.}

\item{fast.search}{Defaults to \code{TRUE}. See "Details".}

\item{max.duration}{Defaults to 150. See "Details".}

\item{single.parallel}{a logical expression indicating whether parallel computation should be used. Defaults to \code{TRUE} if \code{isolation=TRUE,fast.search=FALSE} and \code{FALSE} otherwise.}

\item{single.clusternum}{the number of clusters in parallel computation. Defaults to 4 for the four models. Used if \code{single.parallel=TRUE}.}
}
\value{
an object of S3 class "CAM.single". A list consisting of:
\item{call}{the matched call}
\item{maxindex}{the index of the maximal value in \code{Z} See "Details".}
\item{d,Z}{identical to function inputs up to some truncation. See "Details"}
\item{T,isolation}{identical to function inputs}
\item{A}{numeric matrix \eqn{A} with the \eqn{(i,j)}-th entry being \eqn{\text{exp}(-j \cdot d_i)}, \eqn{d_i} meaning the \eqn{i}-th entry of \code{d} and \eqn{j} meaning the genertion.}
\item{m1,m2}{admixture proportion of population 1 and 2}
\item{estimate}{a list of estimates. Each element contains the estimated parameters \eqn{m}, \eqn{n}, \eqn{\theta_0}, \eqn{\theta_1}, starting generation, ending generation and the corresponding ssE and msE. The time point for HI model is stored in \code{start} variable.}
\item{summary}{a data frame containing the information in \code{estimate} in a compact form}
}
\description{
Find the estimated time intervals/point for HI, CGF1(-I), CGF2(-I) and GA(-I) models and corresponding statictis (ssE, msE, etc.) for a single LD decay curve (e.g. Combined_LD or Jack? in a .rawld file).
}
\details{
\code{fast.search} is only used when \code{isolation=TRUE}. \code{TRUE} to use the fast searching algorithm, which sometimes gives slightly wider time intervals than the slow searching algorithm. It is recommended to use \code{fast.search=TRUE} (default), not only because it is significantly faster, but also because according to our experience it can partially solve the over-fitting problem of CGF-I and GA-I models so that HI usually does not perform significantly worse than them.

\code{max.duration} is only used when \code{isolation=TRUE} and \code{fast.search=FALSE}. The maximal duration of admixture \eqn{n} to be considered as possible. Smaller values can make the slow searching algorithm faster. If \code{max.duration>T}, it will be set to be \code{T}.

Given a single LD decay curve, for each model, this function does the following:

If \code{isolation=FALSE}, it goes through all possible time intervals/points in [0,\code{T}], each time estimating \eqn{\theta_0} and \eqn{\theta_1} for the corresponding interval/point, and chooses the time interval/point that achieves the smallest ssE as the estimate for the model. Each corresponding \eqn{\theta=(\theta_0,\theta_1)} is the estimted \eqn{\theta} for each model.

If \code{isolation=TRUE,fast.search=FALSE}, it also goes through all possible time intervals/points to estimate parameters. This slow algorithm is not recommended as it takes more than 40 minutes if \code{T=500L,max.duration=150L} and \code{Z} has length 3497 without parallel computation.

If \code{isolation=TRUE,fast.search=TRUE}, for CGF1-I, CGF2-I, GA-I models, it uses a fast searching algorithm to search for a local minimum of ssE. This local minimum is not guaranteed to be the global minimum as that in the slow algorithm, but usually it is the same or quite close to that. It is recommended to use the fast algorithm because it takes only about 2 minutes if \code{T=500L,max.duration=150L} and \code{Z} has length 3497 without parallel computation.

\code{maxindex} is the index of \code{Z} such that \code{Z[maxindex]} is the maximal value of \code{Z}. If the first few values of \code{Z} are not decreasing as theoretically expected, the \code{1:maxindex} of \code{Z} and \code{d} will be removed in calculation and in returned values.

If the last entry of distence is greater than 10, a warning of unit will be given.

If the estimated time intervals/points cover \code{T}, a warning of too small \code{T} is given. The user should re-run the function with a larger \code{T} so that optimal time intervals/points can be reached.

Require \pkg{parallel} or \pkg{snow} package installed if \code{single.parallel=TRUE}. For newer versions of \code{R (>=2.14.0)}, \pkg{parallel} is in R-core. If only \pkg{snow} is available, it is recommended to library it before using the parallel computing funcationality. When only \pkg{snow} is available, it will be \code{require}-d and hence the search path will be changed; if \pkg{parallel} is available, it will be used but the search path will not be changed. One may go to \url{https://cran.r-project.org/src/contrib/Archive/snow/} to download and install older versions of \pkg{snow} if the version of \code{R} is too old. If neither of the packages is available but \code{single.parallel=TRUE}, the function will compute sequentially with messages.

Be aware that when the computational cost is small (e.g. \code{isolation=FALSE} or \code{T=20L,isoaltion=TRUE,fast.search=FALSE,max.duration=10L}), using parallel computation can result in longer computation time.

There is a special method of \code{plot} and \code{print} for this class.
}
\note{
If the input of \code{m1} is the .log file path, there should not be any "=" in the names of populations. If there are, the function may not be able to execute normally, and the user should check the .log file and input \code{m1} as a number manually.

When \code{LD.parallel=TRUE} or \code{single.parallel=TRUE}, it is not recommended to terminate the execution of the function. If \pkg{parallel} package is available, it is said that \code{\link[parallel]{setDefaultCluster}} from \pkg{parallel} can be used to remove the registered cluster, but real experiments does not support this; fortunately, these unused clusters will be removed automatically later, but with warnings. If only \pkg{snow} package is available, according to \url{http://homepage.stat.uiowa.edu/~luke/R/cluster/cluster.html}, "don't interrupt a snow computation". The ultimate method to close the unused clusters is probably to quit the R session.
}
\examples{
data(CGF_50)
Z<-CGF_50$Combined_LD
d<-CGF_50$Distance

#fit models with isolation=FALSE
fit<-singleCAM(d,Z,m1=0.3,T=10L,isolation=FALSE) #with warning

#re-run with larger T
fit<-singleCAM(d,Z,m1=0.3,T=100L,isolation=FALSE)
fit

#fit models with isolation=TRUE using fast searching algorithm
fit<-singleCAM(d,Z,m1=0.3,T=100L)
fit

#fit models with isolation=TRUE using slow searching algorithm
#with parallel computation
fit<-singleCAM(d,Z,m1=0.3,T=100L,fast.search=FALSE,
               single.parallel=TRUE,single.clusternum=4L)
fit

#fit models with isolation=TRUE using slow searching algorithm
#without parallel computation
fit<-singleCAM(d,Z,m1=0.3,T=70L,fast.search=FALSE,single.parallel=FALSE)
fit

fitted.curves<-reconstruct.fitted(fit)
}
\seealso{
\code{\link{CAM}}, \code{\link{reconstruct.fitted}}, \code{\link{conclude.model}}
}

