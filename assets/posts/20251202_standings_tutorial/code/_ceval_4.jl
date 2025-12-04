# This file was generated, do not modify it. # hide
games_df = @chain load_schedules() begin
    subset(
        :season => x -> x .== 2024,
        :game_type => x -> x .== "REG",
    )
end;

first(games_df, 5)
