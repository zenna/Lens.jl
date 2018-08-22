"A (mini) lens into the soul of your program"
module Lens

using Cassette
using Spec

Cassette.@context LensCtx

"Create a named lens"
function lens end

# lens(nm, args...) = nothing
lens(nm, args::NamedTuple) = args
lens(nm; kwargs...) = lens(nm, kwargs)

function Cassette.execute(ctx::LensCtx, ::typeof(lens), nm::Symbol, args)
  lensmap = ctx.metadata
  if haskey(lensmap, nm)
    fs = getfield(ctx.metadata, nm)
    foreach(f -> f(args...), fs)
  else
    args
  end
end

function lensapply(lensmap, f, args...)
  Cassette.overdub(LensCtx(metadata = lensmap), f, args...)
end

export lens, lensapply

end