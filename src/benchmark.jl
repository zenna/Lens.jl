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

# Creates a filter for each capture and registers to
# The associated data to be captured
function register_benchmarks!(captures::Vector{Capture})
  fls = Array(Filter, length(captures))
  for i = 1:length(captures)
    let c = captures[i]
      λ = data -> capturebench(c[2],data)
      fls[i] = Filter(gensym("benchmark"), λ, true, true)
      register!(c[1], fls[i])
    end
  end
  fls
end

# Register lenses
function setup!{C<:Capture}(captures::Vector{C})
  clear_benchmarks!()
  register_benchmarks!(captures)
end

# Unregister lenses and delete benchmark data
function cleanup!(fls::Vector{Filter})
  captures = [fl.name for fl in fls]
  for capture in captures delete_filter!(capture) end
  clear_benchmarks!()
end

## Run Benchmarks
## ==============

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench{C<:Capture}(f::Function, captures::Vector{C})
  fls = setup!(captures)
  value, Δt, Δb = @timed(f())
  lens(:total_time, Δt)
  res = deepcopy(benchmarks)
  cleanup!(fls)
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
