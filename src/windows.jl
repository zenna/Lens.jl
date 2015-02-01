## Windowing
## =========

# A window is a named window into an executable piece of code
function window(name::Symbol, data...)
  filters = getfilters(name)
  if !isempty(filters)
    for filter in filters
      filter.enabled && filter.f(data...)
    end
  end
end

# A filter is a named function
# It has a name so that we can remove it if desired easily
type Filter
  name::Symbol
  f::Function
  enabled::Bool
end

# Two filters are considered equal if they have the same name
import Base.isequal
import Base.hash

hash(a::Filter) = hash(a.name)
# ==(a::Filter,b::Filter) = a.name == b.name
isequal(a::Filter, b::Filter) = a.name == b.name

# global mutable directory connecting windowes to filters
window_to_filters = Dict{Symbol, Set{Filter}}()

# Register a window to a filter.
function register!(window::Symbol, f::Filter)
  # DefaultDict: add filter to list or create singleton filter vec
  haskey(window_to_filters, window) ? push!(window_to_filters[window],f) :
                                    window_to_filters[window] = Set([f])
end

register!(window::Symbol, filtername::Symbol, f::Function) =
  register!(window, Filter(filtername, f, true))

# What filters are registed to window name
getfilters(name::Symbol) = haskey(window_to_filters, name) ? window_to_filters[name] : Set{Filter}()

## Enabling/Disabling Filters
## ==========================

#Clearing is permanent
clear_all_filters!() = window_to_filters = Dict{Symbol, Set{Filter}}()

function disable_filter!(watch_name::Symbol, filter_name::Symbol)
  for f in window_to_filters[watch_name]
    if f.name == filter_name f.enabled = false end
  end
end

function enable_filter!(watch_name::Symbol, filter_name::Symbol)
  for f in window_to_filters[watch_name]
    if f.name == filter_name f.enabled = true end
  end
end

function enable_all_filters!()
  for fset in values(window_to_filters)
    for f in fset
      f.enabled = true
    end
  end
end

function disable_all_filters!()
  for fset in values(window_to_filters)
    for f in fset
      f.enabled = false
    end
  end
end
