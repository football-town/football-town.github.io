+++
title = "Conference Standings"
date = Date(2025, 11, 25)
rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/3/32/Rick_and_Morty_opening_credits.jpeg)"

tags = ["tutorials"]
+++

Any regular-season analysis of the NFL would be incomplete without some awareness of the conference standings.
Standings have [implications](https://www.nfl.com/standings/tie-breaking-procedures) for both the playoffs and the draft, and understanding those implications can help explain counter-intuitive phenomena&mdash;especially near the end of the regular season.

In this tutorial, we're going to reproduce the final [2024 conference standings](https://www.nfl.com/standings/conference/2024/REG).
The code can easily be adapted to handle other points in time or simulated results.

Some familiarity with Julia and with the NFL is helpful.

\toc

## Preparing the Environment

For this tutorial, we need to import a few packages.

```!
using Chain
using DataFrames
using NFLData
```

Depending on your environment, you may need to add these packages to the environment first.
If this errors, you have two options:
- `pkg> add Chain, DataFrames, NFLData` or
- `import Pkg; Pkg.add(["Chain", "DataFrames", "NFLData"])`
Either will modify your environment to make these packages available.[^1]

### Why `Chain`?

I started using Julia after several years of Python.
Python syntax supports building up expressions by chaining methods to the end of previous results.

For example:
```python
input_df.groupby([
    "key1", "key2",
]).agg(
    value_mean=pd.NamedAgg(column="value", aggfunc=np.mean),
    value_std=pd.NamedAgg(column="value", aggfunc=np.std),
).plot()
```

This syntax arises somewhat naturally when iterating in a Jupyter notebook.

Julia supports a similar [piping syntax](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping).[^2]

```julia
input_df |>
    (x -> groupby(x, [:key1, :key2])) |>
    (x -> combine(x, :value => mean => :value_mean, ))
```

I find that syntax to be clunky.
With `Chain`, the same example reads a lot cleaner.

```julia
@chain input_df begin
    groupby([:key1, :key2])
    combine(
        :value => mean => :value_mean,
        :value => std => :value_std,
    )
end
```

The [`Chain` documentation](https://github.com/jkrumbiegel/Chain.jl?tab=readme-ov-file#chainjl) has a number of (better) examples.

## Loading Data

We source data with `NFLData.load_teams()` and `NFLData.load_schedules()`.

### Teams

```!
first(load_teams(), 3)
```

To make joins slightly easier, we source the team data and rename with `select`.

```!
team_df = @chain load_teams() begin
    select(
        :team_abbr => :team,
        :team_name => :name,
        :team_conf => :conf,
        :team_division => :division,
    )
end

first(team_df, 10)
```

### Schedules & Results

```!
games_df = @chain load_schedules() begin
    subset(
        :season => x -> x .== 2024,
        :game_type => x -> x .== "REG",
    )
end;

first(games_df, 5)
```

```!
nrow(games_df)
```

```!
extrema(games_df[!, :week])
```

272 games are included over 18 weeks of football.

```!
ismissing.(games_df[!, :result]) |> sum
```

Results are available for every game.

## Cleaning Data

For conference standing purposes, I would consider `games_df` to be a "wide" format.[^3]
We have one row per *game*; we want one row per *team*.
We can obtain a "long" format by concatenating a "home" dataframe and an "away" dataframe.

### Conference & Division Indicators

To compute conference (division) records, we need to know whether both teams are in the same conference (division).
We join with `team_df` to add the conference and division fields, and compute the indicators with `transform`.

```!
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
```

### Home & Away Interpretations

We have to do two things to interpret the data correctly:
- `home_score` and `away_score` need to be converted into `points_for` and `points_against`.
- `result`&mdash;which is `home_score - away_score`&mdash;requires some logic to become W/L/T indicators.

Most of the other fields are simply passed through the `select`.

```!
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
``` 

Just to make sure we've done this correctly, we verify some totals.
```!
sum(df[!, :is_division]) == 192  # 4 teams * 3 opponents * 2 meetings * 8 divisions
```

```!
sum(df[!, :points_for]) == sum(df[!, :points_against])
```

```!
sum(df[!, :is_win]) == sum(df[!, :is_loss])
```

```!
sum(df[!, :is_tie]) % 2 == 0
```

## Analysis

We know from the [tiebreaking procedures](https://www.nfl.com/standings/tie-breaking-procedures) that ties count as a half-win for each team.
Since we will be repeating this calculation a number of times, it is a good candidate for a function.

```!
function winning_percentage(wins, losses, ties)
    total_wins = wins + 0.5 * ties
    total_games = wins + losses + ties
    return total_wins / total_games
end
```

# TODO: CONTINUE HERE!

```!
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

location_df = @chain df begin
    groupby([:team, :is_home])
    combine(
        :is_win => sum => :wins,
        :is_loss => sum => :losses,
        :is_tie => sum => :ties,
    )
    transform(
        [:wins, :losses, :ties] => ((w,l,t) -> recordstr.(w,l,t)) => :record,
    )
end

division_df = @chain df begin
    groupby([:team, :is_division])
    combine(
        :is_win => sum => :wins,
        :is_loss => sum => :losses,
        :is_tie => sum => :ties,
    )
    transform(
        [:wins, :losses, :ties] => ((w,l,t) -> recordstr.(w, l ,t)) => :record,
        [:wins, :losses, :ties] => ((w,l,t) -> winning_percentage.(w, l ,t)) => :pct,
    )
end

conf_df = @chain df begin
    groupby([:team, :is_conf])
    combine(
        :is_win => sum => :wins,
        :is_loss => sum => :losses,
        :is_tie => sum => :ties,
    )
    transform(
        [:wins, :losses, :ties] => ((w,l,t) -> recordstr.(w, l ,t)) => :record,
        [:wins, :losses, :ties] => ((w,l,t) -> winning_percentage.(w, l ,t)) => :pct,
    )
end

@chain total_df begin
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
    select(
        :team,
        :name,
        :conf,
        :division,
        :wins,
        :losses,
        :ties,
        :pct,
        :points_for,
        :points_against,
        :net_pts,
        :record_home,
        :record_away,
        :record_division,
        :pct_division,
        :record_conf,
        :pct_conf,
        :record_non_conf,
    )
    sort([order(:pct, rev=true), order(:name)])
end
```


---

```!


recordstr(wins, losses, ties) = "$wins - $losses - $ties"
```

---

[^1]: Depending on what you expect to get from this tutorial, this may be a good use case for a [temporary environment](https://pkgdocs.julialang.org/v1/environments/#Temporary-environments).
[^2]: This example requires `using Statistics`.
[^3]: For a detailed explanation of "wide" and "long" formats, DataFrames.jl has a section about [reshaping data](https://dataframes.juliadata.org/stable/man/reshaping_and_pivoting/).
