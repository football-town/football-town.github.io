+++
title = "Week 16 Games"
date = Date(2025, 12, 16)
rss_pubdate = Date(2025, 12, 16)
rss = "The schedule and spread for week 16 of the 2025 NFL season."
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

include("src/common.jl")

@chain load_schedules() begin
    subset(
        :season => x -> x .== 2025,
        :week => x -> x .== 16,
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
