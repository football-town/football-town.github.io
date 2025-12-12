+++
title = "Week 14 Games"
date = Date(2025, 12, 4)
rss_pubdate = Date(2025, 12, 4)
rss = "The schedule and spread for week 14 of the 2025 NFL season."
rss_author = "KyleSJohnston"
tags = ["updates", "preview"]
pinned = false
+++

```julia:code/preview
#hideall
using Chain
using DataFrames
using Dates
using NFLData
using Printf

function stringify_time(wd, gt)
    wd_str = wd[1:3]
    gt_str = Dates.format(gt, "I:MM p")
    return "$wd_str $gt_str"
end

stringify_spread(spread) = Printf.@sprintf "%+.1f" spread
stringify_game(away, home) = "$away @ $home"

@chain load_schedules() begin
    subset(
        :season => x -> x .== 2025,
        :week => x -> x .== 14,
    )
    sort([
        :gameday,
        :gametime,
    ])
    select(
        [:weekday, :gametime] => ((wd, gt) -> stringify_time.(wd, gt)) => :when,
        :spread_line => (x -> stringify_spread.(x)) => :spread,
        [:away_team, :home_team] => ((a,h) -> stringify_game.(a,h)) => :description,
        :total_line => :total,
    )
end
```

\show{code/preview}
