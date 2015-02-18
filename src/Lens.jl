module Lens

import Base.isequal
using DataStructures
using DataFrames

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
  disable_filter!,
  disable_all_filters!

include("lens.jl")
include("benchmark.jl")

end
