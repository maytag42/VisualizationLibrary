% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/closed_tables.R
\name{closed_enrollment_status_by_site}
\alias{closed_enrollment_status_by_site}
\title{Number of Subjects Screened, Eligible, Enrolled and Not Enrolled}
\usage{
closed_enrollment_status_by_site(analytic)
}
\arguments{
\item{analytic}{This is the analytic data set that must include screened, 
eligible, refused, consented, enrolled, not_consented, discontinued_pre_randomization, site_certified_days, 
facilitycode, late_ineligible}
}
\value{
html table
}
\description{
Visualizes the enrollment totals for each site.

This is a closed version of enrollment_status_by_site, request if enrollment_status_by_site is present in your study. 
See enrollment_status_by_site for more information.
}
\examples{
closed_enrollment_status_by_site("Replace with Analytic Tibble")

}
