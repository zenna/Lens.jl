Cassette.@context LensCtx

lens(nm, arg) = arg
lens(nm, args...) = args
lens(nm, args::NamedTuple) = args
lens(nm; kwargs...) = lens(nm, kwargs)

apl(f, args...) = f(args...)

function apl(fs::Tuple, args...)
  foreach(f -> f(args...), fs)
end

function Cassette.prehook(ctx::LensCtx, ::typeof(lens), nm::Symbol, args...)
  lmap = ctx.metadata
  if haskey(lmap, nm)
    fs = getfield(ctx.metadata, nm)
    apl(fs, args...)
  else
    args
  end
end

"Cassette based Lenscall f(args...)"
function lenscall(lmap::NamedTuple, f, args...; kwargs...)
  f_(args...) = f(args...; kwargs...)
  Cassette.overdub(LensCtx(metadata = lmap), f_, args...)
end

"Cassette based Lenscall f(args...)"
function lenscallnk(lmap::NamedTuple, f, arg)
  Cassette.overdub(LensCtx(metadata = lmap), f, arg)
end

# "Lens call with keyword args"
# function lenscall(lmap::NamedTuple, f, args...; kwargs...)
#   f_(args...) = f(args...; kwargs...)
#   lenscall(lmap, f_, args...)
# end