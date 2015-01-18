module Window

import Base.isequal

export
  window,

  register!,
  getfilters,
  clear_all_filters!,
  disable_filter!,
  disable_all_filters!

include("windows.jl")
end
