% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/closed_tables.R
\name{closed_appendix_D_protocol_deviation}
\alias{closed_appendix_D_protocol_deviation}
\title{Appendix D: Listing of any protocol deviations for closed report}
\usage{
closed_appendix_D_protocol_deviation(analytic)
}
\arguments{
\item{analytic}{analytic data set that must include study_id, protocol_deviation_data or protocol_deviation_full_data}
}
\value{
HTML.
}
\description{
Returns HTML describing the information found in the protocol_deviation_data or protocol_deviation_full_data
long file.
}
\examples{
closed_appendix_D_protocol_deviation("Replace with Analytic Tibble")

}
