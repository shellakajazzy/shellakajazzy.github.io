-- ~/~ begin <<blogs/creating_blogs_with_a_bash_script.md#getpubdate.lua>>[init]
function Meta(meta)
    print(pandoc.utils.stringify(meta.published))
    return meta
end
-- ~/~ end
