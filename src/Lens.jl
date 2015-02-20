module Lens

import Base: isequal, hash, getindex

export
  Benchmark,
  Algorithm,
  Filter,
  Capture,
  lens,
  benchmarks,
  quickbench,
  @quickbench,
  register_benchmarks!,
  disable_benchmarks!,
  disable_benchmarks,

  quickbench,
  @quickbench,

  register!,
  getfilters,
  clear_all_filters!,
  enable_all_filters!,
  enable_filter!,
  disable_filter!,
  disable_all_filters!,
  nfilters,

  lens_to_filters

include("filter.jl")
include("benchmark.jl")
include("run.jl")
include("std.jl")

end
