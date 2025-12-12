# This file was generated, do not modify it. # hide
function winning_percentage(wins, losses, ties)
    total_wins = wins + 0.5 * ties
    total_games = wins + losses + ties
    return total_wins / total_games
end
