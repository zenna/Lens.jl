module Lens

using SQLite
using Dates
import Base: isequal, hash, getindex

export
  Problem,
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
  runbenchmarks,

  register!,
  getfilters,
  clear_all_filters!,
  enable_all_filters!,
  enable_filter!,
  disable_filter!,
  disable_all_filters!,
  nfilters,

  lens_to_filters

include("common.jl")
include("filter.jl")
include("benchmark.jl")
include("db.jl")
include("run.jl")
include("std.jl")

end
