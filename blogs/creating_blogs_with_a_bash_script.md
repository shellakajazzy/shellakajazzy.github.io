---
title: Creating Blogs With a Bash Script
published: July 29, 2026
---

[![Entangled badge](https://img.shields.io/badge/entangled-Use%20the%20source!-%2300aeff)](https://entangled.github.io/)

# Creating Blogs With a Bash Script

This is the first (of hopefullly many) blog posts on this site.
This also serves as a literate document containing the code to generate the blog posts.

I will be using [Pandoc](https://pandoc.org/) to convert Markdown documents into HTML that can be put into a template file.

## HTML Template
This is the template file that will be used when producing the pages of the site.

`template.html`:
``` {.html file=template.html}
<!DOCTYPE HTML>

<html>
    <head>
        <title>shellakajazzy.github.io - $title$</title>
        <style>
            body { background-color: black; color: white; }
            code { background-color: #001900; color: lightgreen; font-family: monospace, monospace, monospace; }
            pre { background: #001900; overflow-x: auto; white-space: pre; padding: 1rem; }
            a:link { color: #005EC8; }
            a:visited { color: #C400C5; }
            .dates { color: darkgrey; font-size: 0.75em; }
            img { width: 50%; height: 50%; display: block; margin: 0 auto; }

            @media (width <= 960px) {
                .mainContent { margin-left: auto; margin-right: auto; width: 95%; color: white; }
                .leftHeader { text-align: left; }
                .rightHeader { text-align: left; }
            }
            @media (width > 960px) {
                .mainContent { margin-left: auto; margin-right: auto; width: 50%; color: white; }
                .leftHeader { text-align: left; padding: 0; margin: 0; position: absolute; }
                .rightHeader { text-align: right; }
            }
        </style>
    </head>

    <body>
        <div class="mainContent">
            <p class="leftHeader"><a href="https://shellakajazzy.github.io">shellakajazzy.github.io</a></p>
            <p class="rightHeader"><a href="index.html">Home</a> | <a href="blogs.html">Blogs</a></p>

            $if(published)$
            <p class="dates">Published: $published$</p>
            $endif$

            $if(edited)$
            <p class="dates">Last Edited: $edited$</p>
            $endif$

            $body$
        </div>
    </body>
</html>
```

This template is used to format the pages of my website through Pandoc with the `--template` flag.

## Blog Generation Script
This script is used to generate blog posts, starting off with the homepage.

`bloggen.bash`:
``` {.bash #bloggen file=bloggen.bash}
# create the homepage
pandoc README.md --template=template.html -o "./docs/index.html"
```

Next, each individual post stored in the `./blogs/` directory is turned into an HTML page:

``` {.bash #bloggen}
# iterate through blog posts in ./blogs/, sort them by publication date
[ -f ./tosort.txt ] && rm tosort.txt
touch tosort.txt

for file in ./blogs/*.md; do
    publish_epoch="$(date -d "$(pandoc $file --lua-filter=getpubdate.lua | head -n 1)" +%s)"
    title="$(pandoc $file --lua-filter=gettitle.lua | head -n 1)"
    sanitized_title="$(echo $title | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')"

    # save the publish date and title to be sorted later
    echo "$publish_epoch ./$sanitized_title.html $title" >> tosort.txt

    # generate the html of the blog file
    pandoc $file --template=template.html -o "./docs/$sanitized_title.html"
done
```

Then, the [blogs.html](./blogs.html) file needs to be generated:

``` {.bash #bloggen}
# convert a sorted list of blog posts into points on the blogs.md page
[ -f ./blogs.md ] && rm blogs.md
[ -f ./revblogs.md ] && rm revblogs.md
touch revblogs.md

sort -nk 1 tosort.txt | while read line; do
    blog_path="$(echo $line | cut -f 2 -d ' ')"
    blog_title="$(echo $line | cut -f 3- -d ' ')"
    blog_pub_date="$(date -d "@$(echo $line | cut -f 1 -d ' ')" +"%b %d, %Y")"

    echo "- $blog_pub_date | [$blog_title]($blog_path)" >> revblogs.md
done
echo "# Blogs" >> revblogs.md
tac revblogs.md >> blogs.md
pandoc blogs.md --template=template.html -o ./docs/blogs.html
```

Finally, the temporary files created are cleaned up:

``` {.bash #bloggen}
# cleanup temporary files
rm tosort.txt
rm revblogs.md
```

### Pandoc Lua Filters
In order to actually extract the metadata from the blog posts, some Lua filters are necessary for Pandoc, which are:

`gettitle.lua` - gets the title of the blog post:

``` {.lua file=gettitle.lua}
function Meta(meta)
    print(pandoc.utils.stringify(meta.title))
    return meta
end
```

`getpubdate.lua` - gets the publication date of the blog post:

``` {.lua file=getpubdate.lua}
function Meta(meta)
    print(pandoc.utils.stringify(meta.published))
    return meta
end
```

