# coinsR

Generate bibliographic metadata for your (blogdown / Hugo ) website using COinS (Context Object in Spans).

## What are COinS and why would you need it?

[COinS](https://en.wikipedia.org/wiki/COinS) is the abbreviation of "**C**ontext **O**bjects **in S**pans". It refers to a [microformat standard to embed bibliographic metadata as HTML](https://www.univie.ac.at/elib/index.php?title=COinS_Microfromat_Bibliographic_Metadata_for_Embedding_in_HTML). A [COinS string](https://www.questia.com/magazine/1G1-161981672/coins-what-it-stands-for-context-objects-in-spans) includes as HTML code all the information necessary to cite a publication correctly. It works for every type of publication (books, papers, web pages).

The main advantages of COinS is that it can generate citations. COinS embedded in your HTML pages helps your blog readers or website visitors to cite your posts and pages correctly.

With `coinsR` you can create COinS metadata programmatically either for one webpage or recursively for all files of a directory. 

## Some Examples:

+ `coins_all()` -- Applies COinS recursively at the end of all files under the `content` directory.
+ `coins_all('content/post')` -- Applies COinS recursively at the end of all files under the `content/post`. directory.
+ `coins_this('content//docs/learned.md')` -- Applies a COinS at the end of the file `content//docs/learned.md`.
+ Choosing `COINSR` from the RStudio Addins -- Adds a COinS at the end of the file currently open RStudio.

## Installation

`remotes::install_github('petzi53/coinsR', build_vignettes = TRUE)`

I am trying to prepare `coinsR` as an R packages distributed via the [CRAN repository](https://cran.r-project.org/). But as I am still not very experienced in R programming I am not sure if I will succeed. 

## Use cases of `coinsR` and limitations

Before going into the detail of this package, I will summarize what use cases this package support and where it has its limitation. 

The package requires:

1. [Hugo](https://gohugo.io) with the R package [blogdown](https://bookdown.org/yihui/blogdown/)
2. Config file in the TOML format (config.toml)
3. Blog entries with YAML front matter

I am planning for a future version to loosen the last two limitations and allow it for config.yaml and TOML front matter (but not for .json).

## Applying the functions of `coinsR`

There are just two functions:

1. `coins_all(dir = 'content')`: `dir` is a path to a directory to pages with YAML front matter. The default value is 'content,' e.g., add COinS to all files of the blogdown website.
2. `coins_this('path-to-filename')`: You can either use this command from the console with a path to a file name or to apply `COINS` from the RStudio Addins to create a COinS at the end of the currently open file. 

You would get success messages for all files where `coinsR` has added a COinS string at the end of the data.

> Success! COinS added at the end of 'docs/learned.md'.

For a correct citation with COinS the following data are mandatory: 

+ Site parameter 'baseurl' in config.toml
+ Site parameter 'description' with the name of the blog/website in config.toml.
+ Author either in front matter, config.toml or as 'blogdown.author' options in .Rprofile.
+ A YAML front matter (header of the file)
+ A title in the YAML front matter

All these missing data will **stop execution** of `coinsR` program with the following error messages.
Other missing data produce a **warning**, but COinS are added to the end of the file anyway:

+ If there is no 'slug' in the front matter then the title is taken for the URL.
+ If there is no 'date' parameter in front matter then the generated system date of the current date is taken.
+ If there is no 'description' in the front matter.
+ If there is no 'copyright' in the front matter and in the config.toml.
+ if there is no 'DefaultContentLanguage' in front matter and in the config.toml.

COinS does not produce an error if the file name is '_index.md. It skips all index files.

There is another possibility to prevent adding COinS at the end of the file. `coinsR` skips all files, when they have the directive `no_coins: true` in the YAML front matter. 

## More about COinS on my blog: 

+ [Bibliographic Metadata for your Website](https://notes.peter-baumgartner.net/2019/06/19/bibliographic-metadata-for-your-web-page/)
+ [How to produce bibliographic metadata for your web page?](https://notes.peter-baumgartner.net/tutorial/how-to-produce-bibliographic-metadata-for-you-web-page/)

