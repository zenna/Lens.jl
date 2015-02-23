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
        benchmarks[lensname][varname] = [value]
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

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench{C<:Capture}(f::Function, captures::Vector{C})
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
quickbench(f::Function, captures::Vector{Any}) = quickbench(f,Capture[captures...])
# Convenience - if we just use a lens, assume we want the first captured var
quickbench(f::Function, capture::Symbol) = quickbench(f, [(capture, [:x1])])
quickbench(f::Function, captures::Vector{Symbol}) =
  quickbench(f, [(capture, [:x1]) for capture in captures])

macro quickbench(expr,captures)
   :(quickbench(()->$expr,$captures))
end

# Run all the benchmarks
# function runbenchmarks(torun::Vector{Algorithm, Benchmark})
#   e
# end
