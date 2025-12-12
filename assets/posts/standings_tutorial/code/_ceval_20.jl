# This file was generated, do not modify it. # hide
rank(x; rev::Bool=false) = sortperm(sortperm(x; rev))
