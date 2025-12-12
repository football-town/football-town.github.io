# This file was generated, do not modify it. # hide
final_df = @chain total_df begin
    leftjoin(
        team_df,
        on = :team,
    )
    leftjoin(
        subset(location_df, :is_home),
        on = :team,
        renamecols = "" => "_home",
    )
    leftjoin(
        subset(location_df, :is_home => ByRow(!)),
        on = :team,
        renamecols = "" => "_away",
    )
    leftjoin(
        subset(division_df, :is_division),
        on = :team,
        renamecols = "" => "_division",
    )
    leftjoin(
        subset(conf_df, :is_conf),
        on = :team,
        renamecols = "" => "_conf",
    )
    leftjoin(
        subset(conf_df, :is_conf => ByRow(!)),
        on = :team,
        renamecols = "" => "_non_conf",
    )
end

names(final_df)
