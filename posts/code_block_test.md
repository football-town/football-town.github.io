+++
title = "Code block tests"
date = Date(2025, 11, 25)
rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/3/32/Rick_and_Morty_opening_credits.jpeg)"

tags = ["tutorials", "code"]
+++

# Examples of code blocks

For a tutorial, one could imagine using code blocks like this:

```!
x = 1:5
y = 2x
```

Note that we can then reference the variables in a later block:

```!
z = y .+ 3
```
