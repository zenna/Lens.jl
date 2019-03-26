# Lens implemented using global variables

"Default Lens: do nothing"
deflenscall(::Type{T}, x) where T = nothing

mutable struct Wrapper
  x
end

const glens = Wrapper(deflenscall)

function setglens!(newglens)
  glens.x = newglens
end

setglens!(pair::Pair) = setglens!(lmap(pair))
setglens!(tpl::Tuple) = setglens!(lmap(tpl...))

function lens(::Type{T}, x) where T
  glens.x(T, x)
end

function lenscall(newlens, f, arg)
  setglens!(newlens)
  res = f(arg)
  setglens!(deflenscall)
  res
end

@inline lenscall(pair::Pair, f, arg) = lenscall(lmap(pair), f, arg)
@inline lenscall(tpl::Tuple, f, arg) = lenscall(lmap(tpl...), f, arg)

"Lens call f(args...; kwargs)"
function lenscall(newlens, f, args...; kwargs...)
  setglens!(newlens)
  res = f(args...; kwargs...)
  setglens!(deflenscall)
  res
end

@inline lenscall(pair::Pair, f, arg...; kwargs...) = lenscall(lmap(pair), f, arg...; kwargs...)
@inline lenscall(tpl::Tuple, f, args...; kwargs...) = lenscall(lmap(tpl...), f, args...; kwargs...)

function lmap(l1::Type{T1}, f1) where {T1}
  g(_, x) = nothing
  g(::Type{T1}, x) = f1(x)
  g
end

function lmap(l1::Type{T1}, f1, l2::Type{T2}, f2) where {T1, T2}
  g(_, x) = nothing
  g(::Type{T1}, x) = f1(x)
  g(::Type{T2}, x) = f2(x)
  g
end

function lmap(l1::Type{T1}, f1, l2::Type{T2}, f2, l3::Type{T3}, f3) where {T1, T2, T3}
  g(_, x) = nothing
  g(::Type{T1}, x) = f1(x)
  g(::Type{T2}, x) = f2(x)
  g(::Type{T3}, x) = f3(x)
  g
end

function lmap(l1::Type{T1}, f1, l2::Type{T2}, f2, l3::Type{T3}, f3, l4::Type{T4}, f4) where {T1, T2, T3, T4}
  g(_, x) = nothing
  g(::Type{T1}, x) = f1(x)
  g(::Type{T2}, x) = f2(x)
  g(::Type{T3}, x) = f3(x)
  g(::Type{T4}, x) = f4(x)
  g
end

@inline inner(::Type{T}) where T = T
@inline lmap((l1, f1)::Pair) = lmap(inner(l1), f1)
@inline lmap((l1, f1)::Pair, (l2, f2)::Pair) = lmap(inner(l1), f1, inner(l2), f2)
@inline lmap((l1, f1)::Pair, (l2, f2)::Pair, (l3, f3)::Pair) = lmap(inner(l1), f1, inner(l2), f2, inner(l3), f3)
@inline lmap((l1, f1)::Pair, (l2, f2)::Pair, (l3, f3)::Pair, (l4, l4)::Pair) = lmap(inner(l1), f1, inner(l2), f2, inner(l3), f3, inner(l4), f4)

"""
Lensed eval

```julia
struct L end
function g(x, y)
  lens(L, (x = x, y = y))
  2x + y
end

  @leval L => println ∘ sum ∘ values g(1, 2)
```
"""
macro leval(lmap, expr)
  quote 
    setglens!($(esc(lmap)))
    res = $(esc(expr))
    setglens!(deflenscall)
    res
  end
end