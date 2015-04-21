module Lens

import Base: convert

export
  Result,
  Filter,
  Capture,
  lens,
  capture,
  @capture,
  register_benchmarks!,
  disable_benchmarks!,
  disable_benchmarks,

  register!,
  getfilters,
  clear_all_filters!,
  enable_all_filters!,
  enable_filter!,
  disable_filter!,
  disable_all_filters!,
  nfilters,

  get

include("filter.jl")
include("capture.jl")
include("std.jl")

end
