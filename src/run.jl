# A computational problem
abstract Problem

# An algorithm is a procedure to solve it
abstract Algorithm

# A run (or trial) is the application of an algorithm to a problem
typealias Run (Algorithm, Problem)

benchmark() = error()

function tableexists(db::SQLiteDB, tablename::String)
  r = query(db,"SELECT name FROM sqlite_master
                WHERE type='table' AND name='$tablename';")
  r[1,1] != 0
end

function create_res_table!(db::SQLiteDB)
  tblquery = "CREATE TABLE runs(
      runname TEXT,
      algorithm  BLOB,
      problem BLOB,
      timestamp TEXT,
      hostname TEXT,
      status TEXT,
      results BLOB,
      profile BLOB);"
  query(db,tblquery)
end

function addrundb(db::SQLiteDB, runname::String, a::Algorithm, p::Problem,
                  status::String, result = nothing, profile = nothing)
  now = string(Dates.now())
  append(db, "runs", [[runname a p now gethostname() status result profile]])
end

# Run all the benchmarks with all the algorithms
function runbenchmarks{A<:Algorithm, B<:Problem}(
        algos::Vector{A},benches::Vector{B};
        newseed = false,prefix::String = "",runname::String = "",
        savedb::Bool = false, savefile::Bool = false,
        profile::Bool = false)

  # Database saving
  local db
  if savedb
    db = SQLiteDB("/home/zenna/runs.sqlite")
    !tableexists(db, "runs") && create_res_table!(db)
  end

  # Serialise data
  local thisrundir
  if savefile
    thisrundir = joinpath(prefix, "data", "$(runname)-$(string(Dates.now()))")
    mkdir(thisrundir)
  end

  results = Dict{(Algorithm, Problem),Any}()
  runiter = 1
  nruns = length(benches) * length(algos)
  nfailures = 0

  for j = 1:length(benches), i = 1:length(algos)
    println("\nRUNNING $runiter of $nruns, $nfailures so far" )
    print("$(algos[i]) \n")
    print("$(benches[j]) \n")
    newseed && srand(345678) # Set Random Seed
    # restart_counter!()
    try
      res = benchmark(algos[i], benches[j])
      results[(algos[i],benches[j])] = res
      savedb && (addrundb(db,runname, algos[i],benches[j],"DONE",res))
      savefile && (dumpbenchmark(thisrundir,results))
    catch er
      nfailures += 1
      @show er
      @show j
      @show length(benches)
      savefile && (results[(algos[i],benches[j])] = er)
      savedb && (addrundb(db,runname, algos[i],benches[j],"FAIL",er))
    end
    runiter += 1
  end
  println("$nfailures failures")
  savefile && (dumpbenchmark(thisrundir,results,"all"))
  results
end

# Dump the benchmark data into a file
function dumpbenchmark(thisrundir,x,suffix::String = "")
  fname = "$(string(Dates.now()))-$suffix"
  path = joinpath(thisrundir, fname)
  f = open(path,"w")
  serialize(f,x)
  close(f)
end
