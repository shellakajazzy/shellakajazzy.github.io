# ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#bloggen>>[init]
# create the homepage
pandoc README.md --template=template.html -o "./docs/index.html"
# ~/~ end
# ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#bloggen>>[1]
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
# ~/~ end
# ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#bloggen>>[2]
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
# ~/~ end
# ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#bloggen>>[3]
# cleanup temporary files
rm tosort.txt
rm revblogs.md
# ~/~ end
