module Lens

using Compat
import Base: convert, get, getindex

export
  Result,
  Listener,
  Capture,
  lens,
  capture,
  @capture,
  register_benchmarks!,
  disable_benchmarks!,
  disable_benchmarks,

  register!,
  getlisteners,
  clear_all_listeners!,
  enable_all_listeners!,
  enable_listener!,
  disable_listener!,
  disable_all_listeners!,
  nlisteners,

  getindex

include("listener.jl")
include("result.jl")
include("capture.jl")
include("std.jl")

end
