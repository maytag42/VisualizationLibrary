% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/standard_tables.R
\name{outcome_by_site}
\alias{outcome_by_site}
\title{Outcome by Site}
\usage{
outcome_by_site(analytic, outcome_name)
}
\arguments{
\item{analytic}{analytic data set that must include study_id, outcome_data, facilitycode, and enrolled}

\item{outcome_name}{name of the outcome to be considered in the visualization}
}
\value{
An HTML table.
}
\description{
Returns summary statistics on the number of the time to event data of each site for a specified outcome.
Output column "Percent of Expected (excluding events)" comes from excluding events from the days sum calculation,
and "Percent of Expected" refers to dividing the average outcome_days with the average expected_days.
}
\examples{
outcome_by_site("Replace with Analytic Tibble", 'test_outcome')

}
