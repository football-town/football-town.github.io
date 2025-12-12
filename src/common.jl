function stringify_time(wd, gt)
    wd_str = wd[1:3]
    gt_str = Dates.format(gt, "I:MM p")
    return "$wd_str $gt_str"
end

stringify_spread(spread) = Printf.@sprintf "%+5.1f" spread
stringify_game(away, home) = "$away @ $home"
