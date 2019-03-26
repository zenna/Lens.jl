"A lens into the soul of your program"
module Lens

using Cassette
using Spec

"""
Create a named lens

```julia
```
"""
function lens end

"Apply f to args in context of lens"
function lensapply end

"Evaluate an expression with a lensmap"
function leval end

# Cassette based implementation
# include("cassette.jl")

# TODO: Normal Julia implementation
# include("julia.jl")

include("global.jl")

"""Function call with lens (shorthand for)

```julia
f(x) = lens(:mylens, 2x + 1)
lmap = (mylens = println,)
@lenscall lmap f(31)
```
"""
macro lenscall(lmap, fcall)
  fcall.head == :call || error("Must be function application")
  haskwargs(expr) = expr.args[2] isa Expr && expr.args[2].head == :parameters
  r = if haskwargs(fcall)
    Expr(:call, :lenscall, fcall.args[2], lmap, fcall.args[1], fcall.args[3:end]...)
  else
    Expr(:call, :lenscall, lmap, fcall.args...)
  end
  r
end
@spec call.head == :call "Must be function application"

export lens, lenscall, @lenscall, @leval

end