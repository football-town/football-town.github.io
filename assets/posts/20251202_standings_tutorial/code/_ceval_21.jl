# This file was generated, do not modify it. # hide
rank_df = @chain final_df begin
    groupby(:division)
    transform(
        :pct => (x -> rank(x; rev=true)) => :division_rank,
    )
    transform(
        :division_rank => (x -> x .== 1) => :division_leader,
    )
    groupby([:conf, :division_leader])
    transform(
        :pct => (x -> rank(x; rev=true)) => :conference_rank,
    )
    transform(
        [:division_leader, :conference_rank] => ByRow((l,r) -> l ? r : r+4) => :conference_rank,
    )
    sort(:conference_rank)
end;
