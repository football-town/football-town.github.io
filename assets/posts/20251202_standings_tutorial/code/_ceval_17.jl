# This file was generated, do not modify it. # hide
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
end;

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
end;

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
end;
