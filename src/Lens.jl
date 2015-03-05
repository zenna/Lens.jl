module Lens

import Base: convert

export
  Problem,
  Algorithm,
  Result,
  Filter,
  Capture,
  lens,
  benchmarks,
  quickbench,
  @quickbench,
  register_benchmarks!,
  disable_benchmarks!,
  disable_benchmarks,

  quickcapture,
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

  lens_to_filters,

  #db
  all_records,
  where,
  rows,
  groupby

# include("common.jl")
include("filter.jl")
include("capture.jl")
# include("db.jl")
# include("run.jl")
include("std.jl")
# include("figure.jl")

end
