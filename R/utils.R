# Utilities for the COinS program
# Sorted Alphabetically:
# coins_yaml: Combine information from front matter and config file
# coins_config: Collect information from (at the time only) config.toml
# coins_frontmatter: Collect information from front matter of the file(s)
# coins_url: Build the URL of the web page
# coins_permastring: Utility for coins_url:
#    Get the permalinks data from config.toml
# coins_string: combine all collected information to build the COinS
# coins_parse: Parse URL and replace value according permalinks from config.toml
# fetch_yaml: Read YAML-data into file

# if (!requireNamespace("xfun", quietly = TRUE)) install.packages("xfun")
# xfun::pkg_attach2("blogdown", "stringr", "lubridate")

coins_yaml <- function(yfrontmatter, yconfig) {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # copyright
    if (is.null(yfrontmatter$copyright)) {
        coinsRight = yconfig$copyright
    } else {
        coinsRight = yfrontmatter$copyright
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # coinsDefaultLanguage
    if (is.null(yfrontmatter$DefaultContentLanguage)) {
        coinsDefaultLanguage = yconfig$language
    } else {
        coinsDefaultLanguage = yfrontmatter$DefaultContentLanguage
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # coinsAuthor
    # browser()
    coinsAuthor = ''
    if (coinsAuthor == '' && !is.null(yfrontmatter$author))
        {coinsAuthor = yfrontmatter$author}

    if (coinsAuthor == '' && !is.null(yconfig$author))
        {coinsAuthor = yconfig$author}

    if (coinsAuthor == '' && !is.null(getOption('blogdown.author')))
    {coinsAuthor = getOption('blogdown.author')}

    if (coinsAuthor == '') {
        # return(stop(paste("No 'author' found in yaml front matter,",
        #                   "config.toml and in options (blogdown.author) in '.Rrofile'.")), call. = FALSE)
       stop("Test", call. = FALSE)
    }


    # if (!is.null(yfrontmatter$author)) {coinsAuthor = yfrontmatter$author}
    # if ((coinsAuthor == '') && (length(yconfig$author > 1))) {
    #     coinsAuthor = yconfig$author
    # } else {
    #     coinsAuthor = getOption('blogdown.author')
    # }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # build list
    coinsYamlList <- list(coinsDoctitle = yfrontmatter$title,
                          coinsDate = yfrontmatter$date,
                          coinsSlug = yfrontmatter$slug,
                          coinsDescription = yfrontmatter$description,
                          coinsCopyright = coinsRight,
                          coinsLanguage = coinsDefaultLanguage,
                          coinsBaseurl = yconfig$baseurl,
                          coinsBlogtitle = yconfig$blogtitle,
                          coinsAuthor = coinsAuthor)
    return(coinsYamlList)
}


coins_frontmatter <- function(docText, configText, coinsAll, fPath) {
    # different text format from rstudioapi and readr
    if (coinsAll) {
        # readr loads a character string
        yml_str <- stringr::str_extract(docText, regex('---\\n.*?---\\n', dotall = TRUE))
        yml <- yaml::read_yaml(text = yml_str)
    } else {
        # rstudioapi generates a list
        res <- split_yaml_body(docText$contents) # comments already excluded
        yml <- res$yaml_list
    }

    if (length(yml) == 0) return(
        stop(paste(fPath, "has no Yaml header."), call. = FALSE)
    )

    if (!(is.null(yml$no_coins)) && (yml$no_coins)) return(yml)


    #++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # stop if no document title
    if (is.null(yml[['title']])) {
        t <- paste(fPath, "has no 'title' in yaml front matter.")
        stop(t, call. = FALSE)
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # warn if no slug, then take title of document
    if (is.null(yml[['slug']])) {
        titleString <- yml[['title']]
        # convert to a string with a dash betweeen words
        # conert to lower and replace several spaces with only one dash
        slugString <- gsub('\\s+',"-", stringr::str_to_lower(titleString))
        yml[['slug']] <- slugString
        warning(paste(fPath, "has no 'slug' in front matter; the title is taken."), call. = FALSE)
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++
    # warn if no date: generate date from 'Sys.Date()'
    if (is.null(yml[['date']])) {
        warning(paste(fPath, "has no 'date' parameter in yaml front matter. Generated system date of today."), call. = FALSE)
        yml[['date']] = Sys.Date()
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++
    # warn if document has no description (abstract)
    if (is.null(yml[['description']])) {
        warning(paste(fPath, "has no 'description' in yaml front matter."), call. = FALSE)
        yml[['description']] = ''
    }
    return(yml)
}

################################################################################
coins_config <- function(yamlList, fPath) {
    configList <- load_config() # comments already parsed!

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # stop if no baseurl (what about relativeURL? In my understanding: There has a baseurl in any case.)
    if (is.null(configList[['baseurl']])) return(stop("No site parameter 'baseurl' in config.toml."), call. = FALSE)
    coinsBaseURL <- configList[['baseurl']]

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # stop if no title of website in config.toml
    if (is.null(configList[['title']])) return(stop("No site parameter 'description' with the name of the blog/website in config.toml."), call. = FALSE)
    coinsBlogTitle <- configList[['title']]

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # warn if no copyright (yaml front matter has precedence)
    coinsCopyright = ''
    if (!(is.null(yamlList$copyright))) {
        coinsCopyright = yamlList$copyright
    } else {(!(is.null(configList[['copyright']])))
        coinsCopyright = configList[['copyright']]
    }
    if (coinsCopyright == '') warning(paste(fPath, "has no 'copyright' in front matter and in config.toml."), call. = FALSE)

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # warn if no DefaultContentLanguage (How about multilingual site?)
    coinsLanguage = ''
    if (!(is.null(yamlList$DefaultContentLanguage))) {
        coinsLanguage = yamlList$DefaultContentLanguage
    } else {(!(is.null(configList[['DefaultContentLanguage']])))
        coinsLanguage = configList[['DefaultContentLanguage']]
    }
    if (coinsLanguage == '') warning(paste(fPath, "has no 'DefaultContentLanguage' in front matter and in config.toml."), call. = FALSE)

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # store data in list
    coinsConfigList <- list(baseurl = coinsBaseURL,
                            blogtitle = coinsBlogTitle,
                            copyright = coinsCopyright,
                            language = coinsLanguage)
    return(coinsConfigList)
}


################################################################################
coins_url <- function(path, configText, yamlData) {

    yamlData = yamlData
    # get all lines as matrix under '[permalink]' from config.toml: for instance
    #   [,1]                                      [,2] [,3]
    #  [1,] "    post = \"/:year/:month/:day/:slug\"" ""   "    tutorial = \"/:day/:month/:year/:slug\""
    coinsPermaStrMatrix <- coins_permastring(configText)

    # get relative path of  full path of current document:
    # remove everything until after 'content/' for instance
    # "post/2019/2019-06-25-open-citations-TOS.en.Rmd"
    coinsRelDir <- stringr::str_remove(path, '^[[:graph:]]*content/')

    # get sections as one of the options for permalinks
    coinsSections <- stringr::str_remove(coinsRelDir, basename(path))

    # get directory of blog entry to match with lines under '[permalink]'
    coinsSection <- stringr::str_remove(coinsRelDir, '/.*$')

    # get part of matrix which is relevant: for instance 1
    coinsPermaStrWhich <- stringr::str_which(coinsPermaStrMatrix, coinsSection)

    # get format of permalink without matching directory
    coinsPermaLink <- stringr::str_trim(sub('^.*=', '', coinsPermaStrMatrix[coinsPermaStrWhich]))

    # next line see:
    # https://stackoverflow.com/questions/27350636/r-argument-is-of-length-zero-in-if-statement
    if(!is.null(coinsPermaStrWhich) & length(coinsPermaStrWhich) > 0 & TRUE) {
        coinsPartURL <- coins_parse(coinsPermaLink, yamlData, coinsSections, coinsSection, basename(path))
        coinsURL <- paste0(yamlData$coinsBaseurl, coinsPartURL)
        coinsURL <- stringr::str_replace_all(coinsURL, '\"', '')
        # check if coinsBaseURL ends with '/' AND coinsPartURL starts with '/'?
        # because of 'http://' I have to replace only the second match!!
        # https://stackoverflow.com/questions/43077846/how-to-replace-second-or-more-occurrences-of-a-dot-from-a-column-name
        coinsURL <<- stringr::str_replace_all(coinsURL, '(//.*?)//', '\\1/')

        ###########

    } else {
        coinsURL <<- paste0(yamlData$coinsBaseurl, coinsSections, yamlData$coinsSlug)
    }
}

# get permalinks from config.toml
coins_permastring <- function(txt) {
    # extract until empty line (= consecutice \n) OR new parameter = [
    p <- stringr::str_extract(txt, '\\[permalinks\\][\\s\\S]*?(?=\n{2,}|\\[)')
    p <- stringr::str_split(p, '\\[permalinks\\]\\n')[[1]][2]
    p <- stringr::str_split(p, '\\n', simplify = TRUE)

    # delete everything after comments '#'
    for (i in 1:length(p)) p[i] <- gsub('\\s*#.+', '', p[i])
    return(p)
}




coins_string <- function(coinsURL, ylist, sep=" :: ") {
    a <- "&amp;"
    coinsAuthor <- stringr::str_split_fixed(ylist[['coinsAuthor']], " ", 2)

    cs <- paste0("\n\n",
                 "<span class='Z3988' title='url_ver=Z39.88-2004&amp;ctx_ver=Z39.88-2004&amp;rfr_id=info%3Asid%2Fzotero.org%3A2&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc", a,
                 "rft.type=",      'blogPost', a,
                 "rft.title=",      utils::URLencode(ylist[['coinsDoctitle']]), utils::URLencode(sep),
                 utils::URLencode(ylist[['coinsBlogtitle']]), a,
                 "rft.source=",     utils::URLencode(ylist[['coinsDoctitle']]), a,
                 "rft.rights=",     utils::URLencode(ylist[['coinsCopyright']]), a,
                 "rft.description=",utils::URLencode(ylist[['coinsDescription']]), a,
                 "rft.identifier=", utils::URLencode(coinsURL, reserved = TRUE), a,
                 "rft.aufirst=",    utils::URLencode(coinsAuthor[1,1]), a,
                 "rft.aulast=",     utils::URLencode(coinsAuthor[1,2]), a,
                 "rft.au=",         utils::URLencode(ylist[['coinsAuthor']]), a,
                 "rft.date=",       ylist[['date']], a,
                 "rft.language=",   ylist[['coinsLanguage']],
                 "'></span>"
    )
    return(noquote(cs))
}



coins_parse <- function(parseStr, coinsYaml, section, sections, fileName) {
    # /:year/:month/:monthname/:day/:weekday/:weekdayname/:yearday/:section/:sections/:title/:slug/:filename/
    # /2019/07/july/24/3/wednesday/205/test/test/misc/some-r-markdown-überexamples/hello-r-markdown/2015-07-23-hello-r-rmarkdown/

    permaValues <- c(":year", ":month", ":monthname", ":day", ":weekday",
                     ":weekdayname", ":yearday", ":section", ":sections",
                     ":title", ":slug", ":filename")
    # order of urlValues is important, has to be equivalent with permaValues
    urlValues <- c(stringr::str_sub(coinsYaml$coinsDate, 1, 4),  # :year
                   stringr::str_sub(coinsYaml$coinsDate, 6, 7),  # :month
                   stringr::str_to_lower(month.name[lubridate::month(coinsYaml$coinsDate)]),  # :monthname
                   stringr::str_sub(coinsYaml$coinsDate, 9, 10), # :day
                   lubridate::wday(coinsYaml$coinsDate,
                                   # # :weekday (hugo starts with 0, setting lubridate option)
                                   week_start = getOption("lubridate.week.start", 1)),
                   stringr::str_to_lower(lubridate::wday(coinsYaml$coinsDate, label = TRUE, abbr = FALSE)), # :weekdayname
                   lubridate::yday(coinsYaml$coinsDate), # :yearday
                   section,
                   sections,
                   utils::URLencode(stringr::str_to_lower(stringr::str_replace_all(coinsYaml$coinsBlogtitle, '\\s', '-'))), # blog title (not document title)
                   coinsYaml$coinsSlug,
                   fileName
    )

    for (i in (1:length(permaValues))) {
        if (stringr::str_detect(parseStr, permaValues[i])) {
            parseStr <- stringr::str_replace(parseStr, permaValues[i], urlValues[i])
        }
    }
    return(parseStr)
}

rmd_pattern = '[.][Rr](md|markdown)$'
md_pattern  = '[.][Rr]?(md|markdown)$'

fetch_yaml = bookdown:::fetch_yaml
load_config = blogdown:::load_config
yaml_load = blogdown:::yaml_load
fetch_yaml = function(f) fetch_yaml(xfun::read_utf8(f))

# the next two functions are necessry because of a call to knitr::is_blank from split_yaml_body
# see: https://stackoverflow.com/questions/57191965/rcmd-check-unexported-objects-imported-by-calls-i-have-never-used
is_blank = function(x) {
    if (length(x)) all(grepl('^\\s*$', x)) else TRUE
}

split_yaml_body = function(x) {
    i = grep('^---\\s*$', x)
    n = length(x)
    res = if (n < 2 || length(i) < 2 || (i[1] > 1 && !is_blank(x[seq(i[1] - 1)]))) {
        list(yaml = character(), body = x)
    } else list(
        yaml = x[i[1]:i[2]], yaml_range = i[1:2],
        body = if (i[2] == n) character() else x[(i[2] + 1):n]
    )
    res$yaml_list = if ((n <- length(res$yaml)) >= 3) {
        yaml_load(res$yaml[-c(1, n)])
    }
    res
}



