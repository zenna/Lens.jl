## Windowing
## =========


# A window is a named window into an executable piece of code
macro window(name, data...)
  # Hacking with strings because I don't know how to quote symbols
  namestring = string(name)
  quote
  filters = getfilters(symbol($namestring))
  if !isempty(filters)
    for filter in filters
      f.enabled && filter.f($(data...))
    end
  end
  end
end

# A filter is a named function
# It has a name so that we can remove it if desired easily
immutable Filter
  name::Symbol
  f::Function
  enabled::Bool
end

# Two filters are considered equal if they have the same name
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

# Clearing is permanent
clear_all_filters!() = window_to_filters = Dict{Symbol, Set{Filter}}()
disable_filter!(name::Symbol)
disable_all_filters!() = for f in values(window_to_filters) f.enabled = false end
