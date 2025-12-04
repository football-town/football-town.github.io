# This file was generated, do not modify it. # hide
total_df = @chain df begin
    groupby(:team)
    combine(
        :is_win => sum => :wins,
        :is_loss => sum => :losses,
        :is_tie => sum => :ties,
        :points_for => sum => :points_for,
        :points_against => sum => :points_against,
    )
    transform(
        [:wins, :losses, :ties] => ((w,l,t) -> winning_percentage.(w,l,t)) => :pct,
        [:points_for, :points_against] => ((pf,pa) -> pf .- pa) => :net_pts,
    )
end

first(sort(total_df, :pct, rev=true), 5)
