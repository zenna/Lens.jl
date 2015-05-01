# global mutable directory connecting benchmark names with dataframes
typealias Capture @compat Tuple{Symbol, Vector{Symbol}}

# Lensname -> Varname -> Vector of captued values
clear_captured!() = global captured = Dict{Symbol,Dict{Symbol,Vector{Any}}}()
clear_captured!()

# Convert a dict into an other one with only those keys in ks
extract{K,V}(d::Dict{K,V},ks::Vector{K}) = Dict{K,V}([k=>d[k] for k in ks])

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
    captured[lensname] = [k => [v] for (k,v) in extracteddata]
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
function setup!{C<:Capture}(captures::Vector{C})
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
function capture{C<:Capture}(f::Function, captures::Vector{C})
  for proc in procs()
    fetch(@spawnat proc setup!(captures))
  end
  value, Δt, Δb = @timed(f())
  lens(:total_time, Δt)
  local res

  # When there are multiple processors, collate all data
  res = Result()
  for proc in procs()
    res.values[proc] = remotecall_fetch(proc, ()->Lens.captured)
  end
  for proc in procs() @spawnat proc cleanup!() end
  value,res
end

# Hack for failture of type inference to detect [:a, (:a,b)] as Capture vec
capture(f::Function, captures::Vector{Any}) = capture(f,Capture[captures...])
# Convenience - if we just use a lens, assume we want the first captured var
capture(f::Function, capturename::Symbol) = capture(f, [(capturename, [:x1])])
capture(f::Function, captures::Vector{Symbol}) =
  capture(f, [(capture, [:x1]) for capture in captures])

macro capture(expr,captures)
   :(capture(()->$expr,$captures))
end
