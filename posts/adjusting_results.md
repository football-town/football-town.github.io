+++
title = "Adjusting Game Results"
date = Date(2026, 1, 6)
rss_pubdate = Date(2026, 1, 6)
rss = "Rethinking game results as a measure of expected drives needed to tie the game."
rss_author = "KyleSJohnston"
tags = ["research"]
pinned = true
+++

More than any time I can remember, NFL broadcasts have emphasized clock management to limit the opponent's chance of having another drive.
The emphasis on "drives" as a basic resource of football is not new.

\toc

## Assumptions

The basic inputs to this model are the probabilities of drive outcomes.
In reality, these probabilities could be tailored to the team or to the matchup.
For the purposes of a narrative measure, using something team- or matchup-specific would be duplicative.
League-wide probabilities are a reasonable approximation that doesn't use "team strength" to infer "team strength".

This model assumes field goals and touchdowns as the only successful drives.[^safety]
It keeps the model simple without sacrificing usefulness.

\begin{eqnarray}
    p_0 &=& P(no\ score)\\
    p_3 &=& P(field\ goal)\\
    p_6 &=& P(touchdown)
\end{eqnarray}

Since these are the only possible drive outcomes:

$$ 1 = p_0 + p_3 + p_6 $$


After scoring a touchdown, teams have the option of kicking the extra point or attempting a two-point conversion.

\begin{eqnarray}
    p_1 &=& P(extra\ point\ success)\\
    p_2 &=& P(2pt\ conversion\ success)
\end{eqnarray}

These probabilities can be estimated with historical data.

## Basic Equations

The goal of this model is a function $ f(x) $ for the number of drives needed to overcome a deficit of $ x $ points.[^negation]
More specifically, "overcoming a deficit" implies turning a loss into a tie or a win.

A game that is already tied requires no additional drives to be tied.

$$ f(0) = 0 $$

For the convenience of analysis, any negative deficits also require no additional drives.

$$ f(x) = 0\qquad if\ x \lt 0 $$

### Going for Two

While it's only relevant once the deficit exceeds six, it's important to have some notation in place.
The following equations take a post-touchdown point-of-view.

$ f_1(x) $ is the number of drives to overcome a deficit of $ x $ when kicking the extra point.

$ f_2(x) $ is the number of drives to overcome a deficit of $ x $ when attempting the two point conversion.

The equations are functions of $ p_1 $ and $ p_2 $ as defined above.

\begin{eqnarray}
    f_1(x) &=& p_1 f(x-1) + (1 - p_1) f(x)\\
    f_2(x) &=& p_2 f(x-2) + (1 - p_2) f(x)
\end{eqnarray}

Without $ f(x) $ available, this is incomplete.
It can still be evaluated simple cases.

Trivially:
$$ f_1(0) = f_2(0) = 0 $$

Whenever $ x < 0 $, $ f_1(x) = f_2(x) = 0 $.

When down by one:
\begin{eqnarray}
    f_1(1) &=& (1 - p_1) f(1)\\
    f_2(1) &=& (1 - p_2) f(1)\\
\end{eqnarray}

Because we can be confident that $ p_1 > p_2 $, $ f_1(1) < f_2(1) $.
In plain language, kicking the extra point when down by one leads to fewer drives.

For this model, we take $ min( f_1(x), f_2(x) ) $ in every post-touchdown scenario.

### General Form

With the probabilities defined above, it's straightforward to define $ f(x) $.

\begin{eqnarray}
    f(x) &=& p_0 (1 + f(x))\ +\\
    & & p_3 (1 + f(x-3))\ +\\
    & & p_6 (1 + min( f_1(x-6), f_2(x-6) ))
\end{eqnarray}

A recursive definition makes it easy to account for non-scoring drives.

This is enough to find numerical solutions for likely game outcomes.

### Field Goal Deficits

\begin{eqnarray}
    f(1) &=& p_0 (1 + f(1)) + p_3 (1 + f(-2)) + p_6 (1 + f_1(-5))\\
    f(1) &=& p_0 f(1) + p_0 + p_3 + p_6\\
    f(1) &=& p_0 f(1) + 1\\
    f(1)&=& \frac{ 1 }{ 1 - p_0 }\\
    f(1)&=& \frac{ 1 }{ p_3 + p_6 }
\end{eqnarray}

As the probability of a scoring drive increases, the number of drives decreases toward 1.
This makes intuitive sense.

Also:
$$ f(2) = p_0 f(2) + 1 $$

This leads to the same expression as $ f(1) $, which makes sense because any score would overcome the deficit.
The same is true for $ f(3) $.

$$ f(1) = f(2) = f(3) = \frac{ 1 }{ p_3 + p_6 } $$

This equivalence allows us to infer two-point conversion strategies.

When down by two:
\begin{eqnarray}
    f_1(2) &=& p_1 f(1) + (1 - p_1) f(2)\\
    f_2(2) &=& (1 - p_2) f(2)
\end{eqnarray}

These equations can simplify:
\begin{eqnarray}
    f_1(2) &=& f(1)\\
    f_2(2) &=& (1 - p_2) f(1)
\end{eqnarray}

Since $ p_2 > 0 $, $ f_2(2) < f_1(2) $.
When down by two, going for two makes more sense.

### Touchdown Deficits

Deficits between four and six points are similarly equivalent.

\begin{eqnarray}
    f(4) &=& p_0 (1 + f(4)) + p_3 (1 + f(1)) + p_6 (1 + f_1(-2))\\
    f(4) &=& 1 + p_0 f(4) + p_3 f(1)\\
    f(4) &=& \frac{ 1 + p_3 f(1) }{ p_3 + p_6 }
\end{eqnarray}

The equivalence stems from the prior equivalence.

$$ f(5) = \frac{ 1 + p_3 f(2) }{ p_3 + p_6 } = \frac{ 1 + p_3 f(1) }{ p_3 + p_6 } $$

$$ f(4) = f(5) = f(6) = \frac{ 1 + p_3 f(1) }{ p_3 + p_6 } $$

### Down by Seven or Eight

From above, we know:

$$ min( f_1(1), f_2(1) ) = f_1(1) = (1 - p_1) f(1) $$


We also know:

$$ min( f_1(2), f_2(2) ) = f_2(2) = (1 - p_2) f(1) $$

These can be substituted into our equations.

Down by seven:
\begin{eqnarray}
    f(7) &=& p_0 (1 + f(7)) + p_3 (1 + f(4)) + p_6 (1 + (1 - p_1) f(1))\\
    f(7) &=& p_0 + p_0 f(7) + p_3 + p_3 f(4) + p_6 + p_6 f(1) - p_6 p_1 f(1)\\
    f(7) &=& 1 + p_0 f(7) + p_3 f(4) + p_6 f(1) - p_6 p_1 f(1)\\
    f(7) &=& \frac{ 1 + p_3 f(4) + p_6 f(1) - p_6 p_1 f(1) }{ p_3 + p_6 }
\end{eqnarray}

Down by eight:
\begin{eqnarray}
    f(8) &=& p_0 (1 + f(8)) + p_3 (1 + f(5)) + p_6 (1 + (1 - p_2) f(1))\\
    f(8) &=& p_0 + p_0 f(8) + p_3 + p_3 f(4) + p_6 + p_6 f(1) - p_6 p_2 f(1)\\
    f(8) &=& 1 + p_0 f(8) + p_3 f(4) + p_6 f(1) - p_6 p_2 f(1)\\
    f(8) &=& \frac{ 1 + p_3 f(4) + p_6 f(1) - p_6 p_2 f(1) }{ p_3 + p_6 }
\end{eqnarray}

Neither of these are especially elegant; there's no point in trying to simplify further.

## Numerical Solutions

Putting all this together, we can write a function to solve for deficits up to `n`.

```!
function deficit_drives(n::Integer, p₃::AbstractFloat, p₆::AbstractFloat, p₁::AbstractFloat, p₂::AbstractFloat)
    f = zeros(n)
    f₁ = zeros(n)
    f₂ = zeros(n)
    
    p₀ = 1 - p₃ - p₆

    for i in eachindex(f)
        f_fg = i > 3 ? f[i-3] : 0
        f_td = i > 6 ? min(f₁[i-6], f₂[i-6]) : 0
        f[i] = (1 + p₃ * f_fg + p₆ * f_td) / (p₃ + p₆)

        f_make = i > 1 ? f[i-1] : 0
        f₁[i] = p₁ * f_make + (1 - p₁) * f[i]

        f_success = i > 2 ? f[i-2] : 0
        f₂[i] = p₂ * f_success + (1 - p₂) * f[i]
    end

    return f, f₁, f₂
end
```

I've reviewed drive, extra-point, and two-point conversion outcomes using play-by-play data from NFLData.jl.
The probabilities are rounded approximations of regular season outcomes between 2020 and 2024.[^estimation]

```!
using DataFrames

p₆ = 0.24
p₃ = 0.16
p₁ = 0.96
p₂ = 0.48

(f, f1, f2) = deficit_drives(30, p₃, p₆, p₁, p₂)
results_df = DataFrame(:f => f, :f1 => f1, :f2 => f2)
```

Some interpretations:
- If, after a touchdown, you are down by 1, 4, 7, or 8, kick the extra point.
- If, after a touchdown, you are down by 2, 5, or 10, attempt the two-point conversion.
- For small deficits (<10), the ...
- For larger deficits (>20), the resulting values are more continuous, with each point requiring approximately 0.45 drives to overcome.

---

[^safety]: Safeties are infrequent, and they're scored by the defense instead of the offense.
[^negation]: You could argue that $ x $ should be negative for a deficit, but we want $ f(x) $ to have the same sign as $ x $.
[^estimation]: Finding the best estimates of the input probabilities is left for future work. These are meant to be illustrative. I have excluded drives that end the half, but I haven't excluded the final drive of every half.
