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
I think it's reasonable to consider only field goals and touchdowns as successful drives.[^safety]
It keeps the model simple without sacrificing usefulness.

\begin{eqnarray}
    p_0 &=& P(no\ score)\\
    p_3 &=& P(field\ goal)\\
    p_6 &=& P(touchdown)
\end{eqnarray}

This model assumes these are the only possible drive outcomes.

$$ 1 = p_0 + p_3 + p_6 $$

Although it will only become relevant later on, we have to consider 

\begin{eqnarray}
    p_1 &=& P(extra\ point\ |\ touchdown)\\
    p_2 &=& P(2pt\ conversion\ |\ touchdown)
\end{eqnarray}

## Some Basics

With this model, the goal is to have a function $ f(x) $ that computes the number of drives needed to overcome a deficit of $ x $ points.[^negation]


A game that is already tied requires no additional drives to be tied.

$$ f(0) = 0 $$

Even though the model takes the perspective of the losing team catching up to tie the game, the model is symmetric to winning teams.

$$ f(-x) = -f(x) $$

This has the added benefit of keeping games zero-sum.

With the probabilities defined above, it's straightforward to start calculating $ f(x) $.

### Field Goal Deficits

$$ f(1) = p_0 \times (1 + f(1)) + p_3 \times 1 + p_6 \times 1 $$

A recursive definition makes it easy to account for non-scoring drives.

Perhaps more usefully, this is equivalent to the following:

\begin{eqnarray}
    f(1) &=& 1 + p_0 f(1)\\
    f(1)&=& \frac{ 1 }{ 1 - p_0 }\\
    f(1)&=& \frac{ 1 }{ p_3 + p_6 }
\end{eqnarray}

As the probability of a scoring drive increases, the number of drives decreases toward 1.
This makes intuitive sense.

$$ f(2) = p_0 \times (1 + f(2)) + p_3 \times 1 + p_6 \times 1 $$

This leads to the same expression as $ f(1) $, which makes sense because any score would overcome the deficit.
The same is true for $ f(3) $.

$$ f(1) = f(2) = f(3) = \frac{ 1 }{ p_3 + p_6 } $$

### Touchdown Deficits

Deficits between four and six points are similarly equivalent.

\begin{eqnarray}
    f(4) &=& p_0 \times (1 + f(4)) + p_3 \times (1 + f(1)) + p_6 \times 1\\
    f(4) &=& 1 + p_0 f(4) + p_3 f(1)\\
    f(4) &=& \frac{ 1 + p_3 f(1) }{ p_3 + p_6 }
\end{eqnarray}

The equivalence stems from the prior equivalence.

$$ f(5) = \frac{ 1 + p_3 f(2) }{ p_3 + p_6 } = \frac{ 1 + p_3 f(1) }{ p_3 + p_6 } $$

$$ f(4) = f(5) = f(6) = \frac{ 1 + p_3 f(1) }{ p_3 + p_6 } $$

### Down by Seven

Considering this situation requires some guidelines about attempting the two-point conversion.

When kicking the extra point, the outcome (in drives) is $ p_1 + (1-p_1) (1 + f(1)) $.
When going for two, the outcome is $ p_2 + (1 - p_2) (1 + f(1)) $.

Because we can be confident that $ p_1 > p_2 $, kicking the extra point leads to fewer drives.

\begin{eqnarray}
    f(7) &=& p_0 (1 + f(7)) + p_3 (1 + f(4)) + p_6 ( p_1 + (1-p_1) (1 + f(1)) )\\
    f(7) &=& 1 + p_0 f(7) + p_3 f(4) + p_6 (1 - p_1) f(1)\\
    f(7) &=& \frac{ 1 + p_3 f(4) + p_6 (1 - p_1) f(1) }{ p_3 + p_6 }
\end{eqnarray}

### Down by Eight

In this scenario, we compare the following:

\begin{eqnarray}
    p_1 f(1) + (1-p_1) (1+f(2)) &\stackrel{?}{=}& p_2 + (1-p_2) (1+f(2))\\
    1 + f(1) - p_1 &\stackrel{?}{=}& 1 + f(1) - p_2 f(1)\\
    -p_1 &\stackrel{?}{=}& -p_2 f(1)
\end{eqnarray}

We cannot decide without substituting in realistic numbers.

---

[^safety]: Safeties are infrequent, and they're scored by the defense instead of the offense.
[^negation]: You could argue that $ x $ should be negative for a deficit, but we want $ f(x) $ to have the same sign as $ x $.
