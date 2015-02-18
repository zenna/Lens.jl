## lensing
## =========

# global mutable directory connecting lenses to filters
lens_to_filters = Dict{Symbol, Set{Filter}}()

# A lens is a named lens into an executable piece of code
function lens(name::Symbol, data...)
  filters = getfilters(name)
  if !isempty(filters)
    for filter in filters
      filter.enabled && filter.f(data...)
    end
  end
end

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


