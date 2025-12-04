# This file was generated, do not modify it. # hide
@chain final_df begin
    select(
        :team,
        :name,
        :wins,
        :losses,
        :ties,
        :pct,
        :points_for,
        :points_against,
        :net_pts,
    )
    sort([
        order(:pct, rev=true),
        order(:name),
    ])
end
