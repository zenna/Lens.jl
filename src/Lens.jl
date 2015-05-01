module Lens

using Compat
import Base: convert, get

VERSION < v"0.4-" && using Docile

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

  get

include("listener.jl")
include("result.jl")
include("capture.jl")
include("std.jl")

end
