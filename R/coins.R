# if (!requireNamespace("xfun", quietly = TRUE)) install.packages("xfun")
# xfun::pkg_attach2("readr", "rstudioapi")


# THINGS TO DO
# Different syntax in config.toml and config.yaml
# Different syntax in toml or yaml frontmatter
# baseurl not meaningful when using relative URLs?
# addins for write_coins_all ? (needs shiny interface for path selection)



#' Add COinS To All Files Of A Directory
#'
#' \code{coins_all} looks for all files under the directory and calls with the
#' appropiate path string for each file \code{coins_this}, which is doing all the
#' hard work: extracting the information from frontmatter and config file,
#' generating the COinS string and adding it to the end of the file.
#'
#' Two conditions prevent calling \code{coins_this()}:
#'
#' \itemize{
#' \item File is an index file ('_index-md').
#' \item The YAML frontmatter contains the directive 'no_coins: yes'.
#' }
#'
#' @param dir String. Providing the path to the directory. \code{coins_all}
#'   looks recursevly at all files under the directory provided by the path
#'   string.
#'
#' @return Invisible empty list.
#' @export
#'
#'
#' @examples
#' coins_all()
#' coins_all("content/post")
#'
coins_all = function(dir = 'content') {
    # if (missing(dir)) dir = switch(generator(),
    #                                hugo = 'content', jekyll = '.', hexo = 'source'
    # )
    files = list.files(dir, md_pattern, recursive = TRUE, full.names = TRUE)
    if (length(files) == 0) return(list())
    lapply(files, function(f) {
        coins_this(f)
    })
    return(invisible())
}


#' Add COinS to visible file in RStudio
#'
#' \code{coins_this} adds the COinS string to the end of the file which is
#' currently open in the RStudio source editor. You can call this funtions via
#' the RStudio Addins or from the console.
#'
#' \code{coins_this} aborts execution if essential information for building a
#' correct citation is missing:
#'
#' \itemize{
#' \item File has no YAML frontmatter.
#' \item YAML frontmatter has no title.
#' \item No author available in frontmatter, config.toml or in options.
#' \item No baseurl available
#' }
#'
#' @param path String.
#'
#' @return String (Message of success).
#'
#' @export
#'
coins_this <- function(path='') {
    # get content of document
    if (path == '') {
        # get COinS of just this open file via rstudionapi:
        # returns a list of 'id', 'path', 'contents'
        txt <- rstudioapi::getSourceEditorContext()
        path <- txt$path
        coinsAll <- FALSE
    } else {
        # get many COinS each from a different file path
        # no COinS for '_index.md' files
        if (basename(path) == '_index.md') return()
        txt <- readr::read_file(path)
        coinsAll <- TRUE
    }

    # get text from config.toml
    configTxt <- readr::read_file("config.toml")

    # get list of yaml data in document frontmatter
    yamlFrontmatter <- coins_frontmatter(txt, configTxt, coinsAll, path)

    # exit if 'no_coins = yes'
    if (!(is.null(yamlFrontmatter$no_coins)) && (yamlFrontmatter$no_coins)) return()

    # get (missing) list of yaml data in config.toml
    yamlConfig <- coins_config(yamlFrontmatter, path)

    # combine yamlFrontmatter with yamlConfig
    # yamlFrontmatter has precedence
    coinsYaml <- coins_yaml(yamlFrontmatter, yamlConfig )

    # collect and combine URL for web page
    coinsURL <- coins_url(path, configTxt, coinsYaml)

    # put all infos together and build the COinS metadata
    coinsString <- coins_string(coinsURL, coinsYaml)

    # write COinS into file
    if (coinsAll) {
        readr::write_file(coinsString, path, append = TRUE)
    } else {
        rstudioapi::insertText(c(Inf, 1), coinsString, id = txt$id)
        rstudioapi::documentSave(id = txt$id)
    }

    relFilepath  <- stringr::str_remove(path, '[[:graph:]].*/content/')
    return(message("Success! COinS added at the end of '", relFilepath, "'."))

}

#' The \pkg{coinsR} package
#'
#' The comprehensive documentation of this package is the book \bold{blogdown:
#' Creating Websites with R Markdown}
#' (\url{https://bookdown.org/yihui/blogdown/}).
#' @docType package
#' @name coinsR
#' @aliases coinsR-package
#' @import blogdown
#' @import bookdown
#' @import stringr
#' @importFrom lubridate month wday yday
#' @importFrom readr read_file write_file
#' @importFrom rstudioapi documentSave getSourceEditorContext insertText
#' @importFrom utils URLencode
#' @importFrom xfun read_utf8
#' @importFrom yaml read_yaml
#' @examples if (interactive()) coins_all()
NULL


