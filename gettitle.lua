-- ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#gettitle.lua>>[init]
function Meta(meta)
    print(pandoc.utils.stringify(meta.title))
    return meta
end
-- ~/~ end
