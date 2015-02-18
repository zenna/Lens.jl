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

## Run Benchmarks
## ==============

# Do a quick and dirty bechmark, captures captures and returns result too
function quickbench(captures::Vector{Symbol}, f::Function, args...)
  setup!(captures)
  value, Δt, Δb = @timed(f(args...))
  window(:total_time, Δt)
  cleanup!(captures)
end

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


# Run all the benchmarks with all the algorithms
function runbenchmarks{A<:Algorithm, B<:Benchmark}(algos::Vector{A},
                                                   benches::Vector{B};
                                                   newseed = false,
                                                   runname::String = "")
  results = Dict{(Algorithm, Benchmark),Any}()
  runiter = 1; nruns = length(benches) * length(algos)
  nfailures = 0

  thisrundir = joinpath(benchdir, "data", "$(runname)-$(string(Dates.now()))")
  mkdir(thisrundir)

  for j = 1:length(benches), i = 1:length(algos)
    println("\nRUNNING $runiter of $nruns, $nfailures so far")
    print("$(algos[i]) \n")
    print("$(benches[j]) \n")
    newseed && srand(345678) # Set Random Seed
    restart_counter!()
    try
      results[(algos[i],benches[j])] = benchmark(algos[i], benches[j])
      dumpbenchmark(thisrundir,results)
    catch er
      nfailures += 1
      @show er
      @show j
      @show length(benches)
      results[(algos[i],benches[j])] = er
    end
    runiter += 1
  end
  println("$nfailures failures")
  dumpbenchmark(thisrundir,results,"all")
  results
end

function dumpbenchmark(thisrundir,x,suffix::String = "")
  fname = "$(string(Dates.now()))-$suffix"
  path = joinpath(thisrundir, fname)
  f = open(path,"w")
  serialize(f,x)
  close(f)
end