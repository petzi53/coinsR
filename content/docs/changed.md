---
title: Changed
author: Peter Baumgartner
date: '2019-06-04'
slug: changed
toc: no
disable_comments: yes
draft: yes
---

### Link attribute _target="_blank"

```
    [blackfriday]
        hrefTargetBlank = true  # true opens external links in a new tab.
```

changed to:

```
    [blackfriday]
        hrefTargetBlank = false
```
<hr/>

### layouts/partials/last-modified.html

+ always display "Page created" (but not the author because I am the only author!)
+ if `lastmod` is set to a date: display "Last modified"

```
<footer class=" footline" >
    {{with .Params.Date}}
    	   Page created:
    	   {{with $.Date}} <i class='fa fa-calendar'></i> {{ .Format "2006-01-02" }}{{end}}
    {{end}}

    {{ if ne .Lastmod .Date }}
    	{{with .Params.lastmod}}
        	    | Last modified:
        	    {{with $.Lastmod}} <i class='fa fa-calendar'></i> {{ .Format "2006-01-02" }}{{end}}
    	{{end}}
    {{end}}

    </div>

</footer>
```

### archetype with title for special characters

If I am using special characters in the title (for instance a colon) than the text cannot successfully compiled. I added a `'` symbol in the archetype, similar as in the description line.

```
---
title: '"{{ replace .TranslationBaseName "-" " " | title }}"'
date: {{ .Date }}
lastmod:
description: ""
toc: false
disable_comments: true
draft: true
---

Lorem Ipsum....
Notice `draft` is set to true.
```

Now I can write the following title without any problems:

```
---
title: 'This is a Test: with Sonderzeichen'
author: Peter Baumgartner
date: '2019-06-05'
slug: this-is-a-test-with-for-sonderzeichen
categories: []
tags: []
lastmod: ~
description: ''
toc: no
disable_comments: yes
draft: yes
---

Lorem Ipsum....
Notice `draft` is set to true.
```


<span class='Z3988' title='url_ver=Z39.88-2004&amp;ctx_ver=Z39.88-2004&amp;rfr_id=info%3Asid%2Fzotero.org%3A2&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft.type=blogPost&amp;rft.title=Changed%20::%20Open%20Science%20Education&amp;rft.source=Changed&amp;rft.rights=CC%20BY-SA%204.0&amp;rft.description=&amp;rft.identifier=https%3A%2F%2Fnotes.peter-baumgartner.net%2Fdocs%2Fchanged&amp;rft.aufirst=Peter&amp;rft.aulast=Baumgartner&amp;rft.au=Peter%20Baumgartner&amp;rft.date=&amp;rft.language=en'></span>