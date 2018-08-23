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

lens(nm, args...) = args
lens(nm, args::NamedTuple) = args
lens(nm; kwargs...) = lens(nm, kwargs)

"Apply f to args in context of lens"
function lensapply end

# Cassette based implementation
include("cassette.jl")

# TODO: Normal Julia implementation
# include("julia.jl")

export lens, lensapply

end