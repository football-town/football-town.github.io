# This file was generated, do not modify it. # hide
games_df = @chain games_df begin
    leftjoin(
        team_df,
        on = :away_team => :team,
        renamecols = "" => "_away",
    )
    leftjoin(
        team_df,
        on = :home_team => :team,
        renamecols = "" => "_home",
    )
    transform(
        [:conf_home, :conf_away] => ((h,a) -> h .== a) => :is_conf,
        [:division_home, :division_away] => ((h,a) -> h .== a) => :is_division,
    )
end;
