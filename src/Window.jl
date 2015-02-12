module Window

import Base.isequal
using DataStructures
using DataFrames

export
  Benchmark,
  Algorithm,
  window,
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

include("windows.jl")
include("benchmark.jl")

end
