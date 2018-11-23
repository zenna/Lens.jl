# global mutable directory connecting benchmark names with dataframes
const Capture = Tuple{Symbol, Vector{Symbol}}

# Lensname -> Varname -> Vector of captued values
clear_captured!() = global captured = Dict{Symbol,Dict{Symbol,Vector{Any}}}()
clear_captured!()

# Convert a dict into an other one with only those keys in ks
extract(d::Dict{K,V},ks::Vector{K}) where {K,V} = Dict{K,V}(k=>d[k] for k in ks)

# Capture the data and add it to global 'captured'
function capturebench!(captures::Vector{Symbol}, data::Data)
  global captured
  # From the Data object we just pull out the data values restricted
  # to the vars we want to capture
  lensname = data.lensname
  extracteddata = extract(data.data, captures)

  # Default dict behaviour, if no list then create it, otherwise append
  if haskey(captured,lensname)
    for (varname,value) in extracteddata
      if haskey(captured[lensname],varname)
        push!(captured[lensname][varname],value)
      else
        captured[lensname][varname] = Any[]
        push!(captured[lensname][varname],value)
      end
    end
  else
    captured[lensname] = Dict(k => [v] for (k,v) in extracteddata)
  end
end

# Creates a listener for each capture and register to
# The associated data to be captured
function register_captured!(captures::Vector{Capture})
  for c in captures
    let c = c
      λ = data -> capturebench!(c[2],data)
      register!(c[1], Listener(:benchmark, λ, true, true))
    end
  end
end

# Register lenses
function setup!(captures::Vector{C}) where C <: Capture
  clear_captured!()
  register_captured!(captures)
end

# Unregister lenses and delete benchmark data
function cleanup!()
  delete_listener!(:benchmark)
  clear_captured!()
end

@doc "Quick and dirty capture:
  Evaluates `f()` and captures any values specified in `captures`.
  Also returns result of `f()`" ->
function capture(f::Function, captures::Vector{C}; exceptions = true) where C <: Capture
  for proc in procs()
    fetch(Distributed.@spawnat proc setup!(captures))
  end

  local Δt
  local Δb
  local value
  if exceptions
    try
      value, Δt, Δb = @timed(f())
    catch e
      println("Uncaught exception trickled down to capture:")
      println(e)
      value = nothing
      Δt = 0
      Δb = 0
    end
  else
    value, Δt, Δb = @timed(f())
  end
  lens(:total_time, Δt)
  local res

  # When there are multiple processors, collate all data
  res = Result()
  for proc in procs()
    res.values[proc] = remotecall_fetch(proc, ()->Lens.captured)
  end
  for proc in procs() Distributed.@spawnat proc cleanup!() end
  value,res
end

# Hack for failture of type inference to detect [:a, (:a,b)] as Capture vec
capture(f::Function, captures::Vector{Any}; exceptions = true) =
  capture(f,Capture[captures...]; exceptions = exceptions)
# Convenience - if we just use a lens, assume we want the first captured var
capture(f::Function, capturename::Symbol; exceptions = true) =
  capture(f, [(capturename, [:x1])]; exceptions = exceptions)
capture(f::Function, captures::Vector{Symbol}; exceptions = true) =
  capture(f, [(capture, [:x1]) for capture in captures]; exceptions = exceptions)

macro capture(expr,captures)
   :(capture(()->$expr,$captures))
end
