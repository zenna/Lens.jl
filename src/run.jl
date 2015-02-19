abstract Problem ## A computational problem
abstract Algorithm # An algorithm is a procedure to solve it
# We shall call a pair of them a run
typealias Run (Algorithm, Problem)

# Run all the benchmarks with all the algorithms
function runbenchmarks{A<:Algorithm, B<:Problem}(algos::Vector{A},
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
