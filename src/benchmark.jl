abstract Benchmark ## A benchmark represents a problem
abstract Algorithm # An algorithm is a procedure to solve it

# global mutable directory connecting benchmark names with dataframes
benchmarks = Dict{Any, Vector{Any}}()

function register_benchmarks!(captures::Vector{Symbol})
  @show length(captures)
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

# Run all the benchmarks
# function runbenchmarks(torun::Vector{Algorithm, Benchmark})
#   e
# end
