## lensing
## =========

# A lens is a named lens into an executable piece of code
function lens(name::Symbol, data...)
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

# global mutable directory connecting lenses to filters
lens_to_filters = Dict{Symbol, Set{Filter}}()

# Register a lens to a filter.
function register!(lens::Symbol, f::Filter)
  # DefaultDict: add filter to list or create singleton filter vec
  haskey(lens_to_filters, lens) ? push!(lens_to_filters[lens],f) :
                                    lens_to_filters[lens] = Set([f])
end

register!(f::Function, filtername::Symbol, lens::Symbol) =
  register!(f, Filter(filtername, f, true),lens)

# What filters are registed to lens name
getfilters(name::Symbol) = haskey(lens_to_filters, name) ? lens_to_filters[name] : Set{Filter}()

## Enabling/Disabling Filters
## ==========================

#Clearing is permanent
clear_all_filters!() = lens_to_filters = Dict{Symbol, Set{Filter}}()

function disable_filter!(watch_name::Symbol, filter_name::Symbol)
  for f in lens_to_filters[watch_name]
    if f.name == filter_name f.enabled = false end
  end
end

function enable_filter!(watch_name::Symbol, filter_name::Symbol)
  for f in lens_to_filters[watch_name]
    if f.name == filter_name f.enabled = true end
  end
end

function enable_all_filters!()
  for fset in values(lens_to_filters)
    for f in fset
      f.enabled = true
    end
  end
end

function disable_all_filters!()
  for fset in values(lens_to_filters)
    for f in fset
      f.enabled = false
    end
  end
end
