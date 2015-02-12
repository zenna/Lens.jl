abstract Benchmark ## A benchmark represents a problem
abstract Algorithm # An algorithm is a procedure to solve it

# global mutable directory connecting benchmark names with dataframes
benchmarks = Dict{Any, Vector{Any}}()

function register_benchmarks!(captures::Vector{Symbol})
  for capture in captures
    let capture = capture
      register!(capture, :benchmark,
                i->begin
                    global benchmarks
#                     @show capture
                    if haskey(benchmarks,capture)
                      push!(benchmarks[capture], i)
                    else
                      benchmarks[capture] = [i]
                    end
                  end)
    end
  end
end

clear_benchmarks!() = global benchmarks = Dict{Any, Vector{Any}}()

function disable_benchmarks!(captures::Vector{Symbol})
  for capture in captures
    disable_filter!(capture,:benchmark)
  end
end

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench(f::Function, captures::Vector{Symbol})
  Window.clear_benchmarks!()
  global benchmarks
  Window.register_benchmarks!(captures)
  value, Δt, Δb = @timed(f())
  window(:total_time, Δt)
  # cleanup
  Window.disable_benchmarks!(captures)
  res = deepcopy(Window.benchmarks)
  clear_benchmarks!()
  value, res
end

# Run all the benchmarks
# function runbenchmarks(torun::Vector{Algorithm, Benchmark})
#   e
# end
