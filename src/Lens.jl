module Lens

import Base: isequal, hash

export
  Benchmark,
  Algorithm,
  lens,
  benchmarks,
  quickbench,
  register_benchmarks!,
  disable_benchmarks!,
  disable_benchmarks,

  register!,
  getfilters,
  clear_all_filters!,
  enable_all_filters!,
  enable_filter!,
  disable_filter!,
  disable_all_filters!

include("filter.jl")
include("benchmark.jl")

end
