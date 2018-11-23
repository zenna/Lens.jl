# A piece of Data is sent from a lens
struct Data
  procid::Int # The process that executed the lens
  lensname::Symbol
  data::Dict{Symbol, Any} # Variable ids, hmm
end

getindex(x::Data,i::Symbol) = x.data[i]

# A listener is a named function
# It has a name so that we can remove it if desired easily
mutable struct Listener
  name::Symbol
  f::Function
  enabled::Bool
  kwargs::Bool #Does the function take its argument as keywords
end

## Lenses
## ======
# global mutable directory connecting lenses to listeners
lens_to_listeners = Dict{Symbol, Set{Listener}}()

# Two listeners are considered equal if they have the same name
hash(a::Listener) = hash(a.name)
# ==(a::Listener,b::Listener) = a.name == b.name
isequal(a::Listener, b::Listener) = a.name == b.name

## Lens KW
function lens(lensname::Symbol; data...)
#   println("in lens",myid(),data, lens_to_listeners)
  listeners = getlisteners(lensname)
  if !isempty(listeners)
    for listener in listeners
      datum = Data(myid(), lensname, Dict{Symbol, Any}(data))
      listener.enabled && listener.kwargs && listener.f(datum)
      # When listener does not use kwargs just pass in the values
      listener.enabled && !listener.kwargs && listener.f([d[2] for d in data]...)
    end
  end
  v = [d[2] for d in data]
  length(v) == 1 ? v[1] : v
end

lens(lensname::Symbol, data...) =
  lens(lensname; [(Symbol("x$i"),data[i]) for i = 1:length(data)]...)

## Enabling/Disabling Listeners
## ==========================
# Register a lens to a listener.
function register!(lensname::Symbol, f::Listener)
#   println("I'm her eand registering!!!\n")
  # DefaultDict: add listener to list or create singleton listener vec
  if haskey(Lens.lens_to_listeners, lensname)
    push!(Lens.lens_to_listeners[lensname],f)
  else
    Lens.lens_to_listeners[lensname] = Set([f])
  end
end

# Create/register a Listener with function and f and name listenername to lensname
register!(f::Function, listenername::Symbol, lensname::Symbol, kwargs::Bool) =
  register!(lensname, Listener(listenername, f, true, kwargs))

# Clearing is permanent
clear_all_listeners!() = global lens_to_listeners = Dict{Symbol, Set{Listener}}()

function delete_listener!(listener_name::Symbol)
  for l in values(lens_to_listeners), f in l
    if f.name == listener_name delete!(l,f) end
  end
end

function enable_listener!(watch_name::Symbol, listener_name::Symbol)
  for f in lens_to_listeners[watch_name]
    if f.name == listener_name f.enabled = true end
  end
end

function disable_listener!(lensname::Symbol, listener_name::Symbol)
  for f in lens_to_listeners[lensname]
    if f.name == listener_name f.enabled = false end
  end
end

enable_all_listeners!() = for fset in values(lens_to_listeners), f in fset f.enabled = true end
disable_all_listeners!() = for fset in values(lens_to_listeners), f in fset f.enabled = false end
# What listeners are registed to lens name
getlisteners(name::Symbol) = haskey(lens_to_listeners, name) ? lens_to_listeners[name] : Set{Listener}()
nlisteners() = (i=0; for fset in values(lens_to_listeners), f in fset i += 1 end; i)

