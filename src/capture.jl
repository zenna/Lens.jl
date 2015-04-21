# global mutable directory connecting benchmark names with dataframes
typealias Capture (Symbol, Vector{Symbol})

clear_benchmarks!() = global benchmarks = Dict{Symbol,Dict{Symbol,Vector{Any}}}()
clear_benchmarks!()

# Convert a dict into an other one with only those keys in ks
extract{K,V}(d::Dict{K,V},ks::Vector{K}) = Dict{K,V}([k=>d[k] for k in ks])

# Capture the data and add it to global 'benchmarks'
function capturebench!(captures::Vector{Symbol}, data::Data)
  global benchmarks
  # From the Data object we just pull out the data values restricted
  # to the vars we want to capture
  lensname = data.lensname
  extracteddata = extract(data.data, captures)

  # Default dict behaviour, if no list then create it, otherwise append
  if haskey(benchmarks,lensname)
    for (varname,value) in extracteddata
      if haskey(benchmarks[lensname],varname)
        push!(benchmarks[lensname][varname],value)
      else
        benchmarks[lensname][varname] = Any[]
        push!(benchmarks[lensname][varname],value)
      end
    end
  else
    benchmarks[lensname] = [k=>[v] for (k,v) in extracteddata]
  end
end

# Creates a filter for each capture and register to
# The associated data to be captured
function register_benchmarks!(captures::Vector{Capture})
  for c in captures
    let c = c
      λ = data -> capturebench!(c[2],data)
      register!(c[1], Filter(:benchmark, λ, true, true))
    end
  end
end

# Register lenses
function setup!{C<:Capture}(captures::Vector{C})
  clear_benchmarks!()
  register_benchmarks!(captures)
end

# Unregister lenses and delete benchmark data
function cleanup!()
  delete_filter!(:benchmark)
  clear_benchmarks!()
end

## Run Benchmarks
## ==============

# Stores the result of a benchmark
immutable Result
  # Processor id -> (lensname -> (varname -> Vector of values of that lens)
  values::Dict{Int,Dict{Symbol,Dict{Symbol,Vector{Any}}}}
end

Result() = Result(Dict{Int,Dict{Symbol,Vector{Any}}}())
convert(::Type{Vector{Result}}, x::Vector{Any}) =
  (rs = similar(x,Result); for i = 1:length(x) rs[i] = x[i] end)

# Convenience functions for extracting data from a Result
function get(r::Result, proc_id=1; lensname=nothing, capturename=nothing)
  entries = r.values[proc_id]
  if lensname == nothing
    length(entries) != 1 && error("No lensname specified and more than one lens captured")
    lensname = first(entries)[1]
  end
  if capturename == nothing
    length(entries[lensname]) != 1 && error("No capture name specified and more than one captured <found></found>")
    capturename = first(entries[lensname])[1]
  end
  entries[lensname][capturename]
end
get{T}(r::(T,Result); args...) = get(r[2]; args...)

# Do a quick and dirty bechmark, captures captures and returns result too
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
    res.values[proc] = remotecall_fetch(proc, ()->Lens.benchmarks)
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