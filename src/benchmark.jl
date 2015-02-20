# global mutable directory connecting benchmark names with dataframes
typealias Capture (Symbol, Vector{Symbol})

clear_benchmarks!() = global benchmarks = Dict{Symbol, Vector{Any}}()
clear_benchmarks!()

# Convert a dict into an other one with only those keys in ks
extract{K,V}(d::Dict{K,V},ks::Vector{K}) = Dict{K,V}([k=>d[k] for k in ks])

function capturebench(vars::Vector{Symbol}, data::Data)
  global benchmarks
  sliceddata = Data(data.procid, data.lensname, extract(data.data, vars))
  if haskey(benchmarks,sliceddata.lensname)
    push!(benchmarks[sliceddata.lensname], sliceddata)
  else
    benchmarks[sliceddata.lensname] = [sliceddata]
  end
end

# Creates a filter for each capture and register to
# The associated data to be captured
function register_benchmarks!(captures::Vector{Capture})
  for c in captures
    let c = c
      λ = data -> capturebench(c[2],data)
      register!(c[1], Filter(:benchmark, λ, true, true))
    end
  end
end

# Register lenses
function setup!{C<:Capture}(captures::Vector{C})
#   @show "setting up", myid(), captures
  clear_benchmarks!()
  register_benchmarks!(captures)
#   println("JUSTMADE, $lens_to_filters")
end

# Unregister lenses and delete benchmark data
function cleanup!()
  delete_filter!(:benchmark)
  clear_benchmarks!()
end

## Run Benchmarks
## ==============

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench{C<:Capture}(f::Function, captures::Vector{C})
  for proc in procs()
    fetch(@spawnat proc setup!(captures))
  end
#   println("ID $lens_to_filters")
  value, Δt, Δb = @timed(f())
  lens(:total_time, Δt)
  local res

  # When there are multiple processors, collate all data
  if nprocs() > 1
    res = Any[]
    for proc in procs()
      push!(res, remotecall_fetch(proc, ()->Lens.benchmarks))
    end
  else
    res = deepcopy(benchmarks)
  end
  for proc in procs() @spawnat proc cleanup!() end
  value,res
end

# Hack for failture of type inference to detect [:a, (:a,b)] as Capture vec
quickbench(f::Function, captures::Vector{Any}) = quickbench(f,Capture[captures...])
# Convenience - if we just use a lens, assume we want the first captured var
quickbench(f::Function, capture::Symbol) = quickbench(f, [(capture, [:x1])])

# macro quickbench(e)
#   @q
#   setup!()
#   e
#   cleanup()!
# end

# Run all the benchmarks
# function runbenchmarks(torun::Vector{Algorithm, Benchmark})
#   e
# end
