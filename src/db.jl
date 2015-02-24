## Database Functions
## ==================

default_dbpath = joinpath(homedir(),"runs.sqlite")
set_dbpath!(dbpath::String) = global default_dbpath = dbpath
rundb(dbpath = default_dbpath) = SQLiteDB(dbpath)

# Does the table tablename exist in this db?
function tableexists(db::SQLiteDB, tablename::String)
  r = query(db,"SELECT name FROM sqlite_master
                WHERE type='table' AND name='$tablename';")
  r[1,1] != 0
end

function create_runs_table!(db::SQLiteDB)
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

# Add a result to the db
function addrundb(db::SQLiteDB, runname::String, a::Algorithm, p::Problem,
                  status::String, result = nothing, profile = nothing)
  now = string(Dates.now())
  append(db, "runs", [[runname a p now gethostname() status result profile]])
end

## Query helpers
## =============

# This returns a result set where rows are removed if the predicate p
# when applies to the rows value in the column colname is false
function where(r::ResultSet, colname::String, p::Function)
  coli = findfirst(r.colnames, colname)
  coli == 0 && error("result set has no column $colname")
  goodcols = Int[]

  # Find those which satisfy filter
  for i = 1:size(r)[1]
    p(r[coli][i]) && push!(goodcols,i)
  end

  values = Any[]
  for i = 1:size(r)[2]
    col = r[i]
    newcol = eltype(col)[]
    for j in goodcols
      push!(newcol,col[j])
    end
    push!(values,newcol)
  end
  ResultSet(r.colnames, values)
end

## Get results in rowform
function rows(rs::ResultSet)
  vs = Vector{Any}[]
  for i = 1:size(rs)[1]
    v = Array(Any,size(rs)[2])
    for j = 1:size(rs)[2]
      v[j] = rs[i,j]
    end
    push!(vs,v)
  end
  vs
end

# Collate results across processors
function collate(rs::Vector{Result},lensname::Symbol, varname::Symbol)
  combined = Any[]
  for r in rs
    for v in values(r.values)
      records = v[lensname]
      push!(combined, records[varname]...)
    end
  end
  combined
end

# Groups rows of results by (Algorithm,Problem) pair
# Returns Dictionary mapping (Algorithm,Problem) to Vector of rows
function group(q::ResultSet)
  d = Dict{Any,Vector{Vector{Any}}}()
  for r in rows(q)
    key = [r[2],r[3]]
    if haskey(d,key) push!(d[key],r) 
    else d[key] = Vector[r] end
  end
  d
end

## Convenience Queries
# [int((i[2]) == (j[2])) for i in Lens.rows(q), j in Lens.rows(q)]
all_records(db=rundb()) = query(db,"SELECT * from runs")
all_failed(db=rundb()) = query(db,"SELECT * from runs WHERE status = 'FAIL'")
