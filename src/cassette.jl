Cassette.@context LensCtx

function Cassette.prehook(ctx::LensCtx, ::typeof(lens), nm::Symbol, args)
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