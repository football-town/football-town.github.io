# This file was generated, do not modify it. # hide
away_df = @chain games_df begin
    select(
        :away_team => :team,
        :away_team => (x -> false) => :is_home,
        :away_score => :points_for,
        :home_score => :points_against,
        :result => (x -> x .< 0) => :is_win,
        :result => (x -> x .> 0) => :is_loss,
        :result => (x -> x .== 0) => :is_tie,
        :is_conf,
        :is_division,
    )
end;

home_df = @chain games_df begin
    select(
        :home_team => :team,
        :home_team => (x -> true) => :is_home,
        :home_score => :points_for,
        :away_score => :points_against,
        :result => (x -> x .> 0) => :is_win,
        :result => (x -> x .< 0) => :is_loss,
        :result => (x -> x .== 0) => :is_tie,
        :is_conf,
        :is_division,
    )
end;

df = vcat(home_df, away_df)

first(df, 5)
