# This file was generated, do not modify it. # hide
team_df = @chain load_teams() begin
    select(
        :team_abbr => :team,
        :team_name => :name,
        :team_conf => :conf,
        :team_division => :division,
    )
end

first(team_df, 10)
