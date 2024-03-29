% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coins.R
\name{coins_this}
\alias{coins_this}
\title{Add COinS to visible file in RStudio}
\usage{
coins_this(path = "")
}
\arguments{
\item{path}{String.}
}
\value{
String (Message of success).
}
\description{
\code{coins_this} adds the COinS string to the end of the file which is
currently open in the RStudio source editor. You can call this functions via
the RStudio Addins or from the console.
}
\details{
\code{coins_this} aborts execution if essential information for building a
correct citation is missing:

\itemize{
\item File has no YAML front matter.
\item YAML front matter has no title.
\item No author available in front matter, config.toml or in options.
\item No baseurl available
}
}
\examples{
\dontrun{
coins_this()
coins_this("content/post/filename.md")}

}
