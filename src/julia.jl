apl(f, args...) = f(args...)

function apl(fs::Tuple, args...)
  foreach(f -> f(args...), fs)
end

mutable struct Container
  lmap::NamedTuple
end

const LMAP = Container(NamedTuple())

function apllens(lmap::NamedTuple, nm::Symbol, arg)
  if haskey(lmap, nm)
    fs = getfield(lmap, nm)
    apl(fs, arg)
    arg
  else
    arg
  end
end

function apllens(lmap::NamedTuple, nm::Symbol, args...)
  if haskey(lmap, nm)
    fs = getfield(lmap, nm)
    apl(fs, args...)
    args
  else
    args
  end
end

apllens(nm::Symbol, args...) = apllens(globalmap(), nm, args...)

lens(nm, arg) = apllens(nm, arg)
lens(nm, args...) = apllens(nm, args...)
lens(nm, args::NamedTuple) = apllens(nm, args)

lens(nm; kwargs...) = lens(nm, kwargs)

"Global Map!"
function setgloballmap!(lmap)
  LMAP.lmap::NamedTuple = lmap
end
globalmap()::NamedTuple = LMAP.lmap

function resetglobalmap!()
  setgloballmap!(NamedTuple())
end

"Lens call f(args...)"
function lenscall(lmap::NamedTuple, f, args...; kwargs...)
  setgloballmap!(lmap)
  f(args...; kwargs...)
end

"""
Lensed eval

```julia
function g(x, y)
  lens(:howdy, (x = x, y = y))
  2x + y
end

@leval g(1, 2) (howdy = println ∘ sum ∘ values,)
```
"""
macro leval(expr, lmap)
  quote 
    setgloballmap!($(esc(lmap)))
    res = $(esc(expr))
    resetglobalmap!()
    res
  end
end