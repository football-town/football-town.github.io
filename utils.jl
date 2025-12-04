function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function post_paths()
    return [
        joinpath("posts", p)
        for p
        in readdir("posts")
    ]
end

function post_date(rpath)
    # retrieve the "date" field of the page if defined, otherwise
    # use the date of creation of the file
    pvd = pagevar(rpath, :date)
    if isnothing(pvd)
        return Date(Dates.unix2datetime(stat(rpath * ".md").ctime))
    end
    return pvd
end

function post_summary!(c::IOBuffer, rpath::String)
    write(c, """<section class="post">""")
    write(c, """<header class="post-header">""")

    url = get_url(rpath)
    write(c, """<a href="$url">""")
    write(c, """<h2 class="post-title">""", pagevar(rpath, "title"), "</h2>")
    write(c, "</a>")

    subtitle = pagevar(rpath, "subtitle")
    if !isnothing(subtitle)
        write(c, "<p>", subtitle,"</p>")
    end

    write(c, """</header>""")
    write(c, """<div class="post-description">""")

    rss = pagevar(rpath, "rss")
    if !isnothing(rss)
        write(c, "<p>", rss,"</p>")
    end

    write(c, """</div>""")
    write(c, """</section>""")
end

function hfun_custom_taglist()::String
    # -----------------------------------------
    # Part1: Retrieve all pages associated with
    #  the tag & sort them
    # -----------------------------------------
    # retrieve the tag string
    tag = locvar(:fd_tag)
    rpaths = if isnothing(tag) || tag == ""
        post_paths()
    else
        # recover the relative paths to all pages that have that
        # tag, these are paths like /blog/page1
        globvar("fd_tag_pages")[tag]
    end
    # you might want to sort these pages by chronological order
    # you could also only show the most recent 5 etc...
    sort!(rpaths, by=post_date, rev=true)

    is_pinned = [
        isnothing(pagevar(rpath, "pinned")) ? false : pagevar(rpath, "pinned")
        for rpath
        in rpaths
    ]

    # --------------------------------
    # Part2: Write the HTML to plug in
    # --------------------------------
    # instantiate a buffer in which we will write the HTML
    # to plug in the tag page
    c = IOBuffer()
    if any(is_pinned)
        write(c, """<div class="posts">""")
        write(c, """<h1 class="content-subhead">Pinned Posts</h1>""")
        for rpath in rpaths
            pin = pagevar(rpath, "pinned")
            if isnothing(pin) || !pin
                continue
            end
            post_summary!(c, rpath)
        end
        write(c, """</div>""")  # class="posts"
    end

    write(c, """<div class="posts">""")
    write(c, """<h1 class="content-subhead">Recent Posts</h1>""")
    for rpath in rpaths
        pin = pagevar(rpath, "pinned")
        if isnothing(pin) || !pin
            post_summary!(c, rpath)
            continue
        end
    end
    write(c, """</div>""")  # class="posts"

    # return the HTML string
    return String(take!(c))
end
