abstract Benchmark ## A benchmark represents a problem
abstract Algorithm # An algorithm is a procedure to solve it

# global mutable directory connecting benchmark names with dataframes
benchmarks = Dict{Any, Vector{Any}}()

function register_benchmarks!(captures::Vector{Symbol})
  for capture in captures
    let capture = capture
      register!(:benchmark,capture) do i
        global benchmarks
  #                     @show capture
        if haskey(benchmarks,capture)
          push!(benchmarks[capture], i)
        else
          benchmarks[capture] = [i]
        end
      end
    end
  end
end

clear_benchmarks!() = global benchmarks = Dict{Any, Vector{Any}}()

function disable_benchmarks!(captures::Vector{Symbol})
  for capture in captures
    disable_filter!(capture,:benchmark)
  end
end

function setup!(captures::Vector{Symbol})
  clear_benchmarks!()
  global benchmarks
  register_benchmarks!(captures)
end

function cleanup!()
  disable_benchmarks!(captures)
  res = deepcopy(benchmarks)
  clear_benchmarks!()
  value, res
end

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench(captures::Vector{Symbol}, f::Function, args...)
  setup!(captures)
  value, Δt, Δb = @timed(f(args...))
  window(:total_time, Δt)
  cleanup!(captures)
end

macro quickbench(e)
  @q
  setup!()
  e
  cleanup()!
end

# Run all the benchmarks
# function runbenchmarks(torun::Vector{Algorithm, Benchmark})
#   e
# end
