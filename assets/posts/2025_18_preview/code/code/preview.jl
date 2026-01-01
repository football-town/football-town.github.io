# This file was generated, do not modify it. # hide
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
        :week => x -> x .== 18,
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