# A piece of Data is sent from a lens
immutable Data
  procid::Int # The process that executed the lens
  lensname::Symbol
  data::Dict{Symbol, Any} # Variable ids, hmm
end

getindex(x::Data,i::Symbol) = x.data[i]

# A filter is a named function
# It has a name so that we can remove it if desired easily
type Filter
  name::Symbol
  f::Function
  enabled::Bool
  kwargs::Bool #Does the function take its argument as keywords
end

## Lenses
## ======
# global mutable directory connecting lenses to filters
lens_to_filters = Dict{Symbol, Set{Filter}}()

# Two filters are considered equal if they have the same name
hash(a::Filter) = hash(a.name)
# ==(a::Filter,b::Filter) = a.name == b.name
isequal(a::Filter, b::Filter) = a.name == b.name

## Lens KW
function lens(lensname::Symbol; data...)
#   println("in lens",myid(),data, lens_to_filters)
  filters = getfilters(lensname)
  if !isempty(filters)
    for filter in filters
      datum = Data(myid(), lensname, Dict{Symbol, Any}(data))
      filter.enabled && filter.kwargs && filter.f(datum)
      # When filter does not use kwargs just pass in the values
      filter.enabled && !filter.kwargs && filter.f([d[2] for d in data]...)
    end
  end
  v = [d[2] for d in data]
  length(v) == 1 ? v[1] : v
end

lens(lensname::Symbol, data...) =
  lens(lensname; [(symbol("x$i"),data[i]) for i = 1:length(data)]...)

## Enabling/Disabling Filters
## ==========================
# Register a lens to a filter.
function register!(lensname::Symbol, f::Filter)
#   println("I'm her eand registering!!!\n")
  # DefaultDict: add filter to list or create singleton filter vec
  if haskey(Lens.lens_to_filters, lensname)
    push!(Lens.lens_to_filters[lensname],f)
  else
    Lens.lens_to_filters[lensname] = Set([f])
  end
end

# Create/register a Filter with function and f and name filtername to lensname
register!(f::Function, filtername::Symbol, lensname::Symbol, kwargs::Bool) =
  register!(lensname, Filter(filtername, f, true, kwargs))

# Clearing is permanent
clear_all_filters!() = global lens_to_filters = Dict{Symbol, Set{Filter}}()

function delete_filter!(filter_name::Symbol)
  for l in values(lens_to_filters), f in l
    if f.name == filter_name delete!(l,f) end
  end
end

function enable_filter!(watch_name::Symbol, filter_name::Symbol)
  for f in lens_to_filters[watch_name]
    if f.name == filter_name f.enabled = true end
  end
end

function disable_filter!(lensname::Symbol, filter_name::Symbol)
  for f in lens_to_filters[lensname]
    if f.name == filter_name f.enabled = false end
  end
end

enable_all_filters!() = for fset in values(lens_to_filters), f in fset f.enabled = true end
disable_all_filters!() = for fset in values(lens_to_filters), f in fset f.enabled = false end
# What filters are registed to lens name
getfilters(name::Symbol) = haskey(lens_to_filters, name) ? lens_to_filters[name] : Set{Filter}()
nfilters() = (i=0; for fset in values(lens_to_filters), f in fset i += 1 end; i)

