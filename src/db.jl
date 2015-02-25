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

import Base: convert
# ResultSets are not great, we'll convert everything to DataFrames
function convert(::Type{DataFrame},rs::ResultSet)
  df = DataFrame()
  for i = 1:length(rs.colnames)
    df[symbol(rs.colnames[i])] = rs[i]
  end
  df
end

## SQLite helpers - to make SQLite more convenient
## ==============================================

# This returns a result set where rows are removed if the predicate p
# when applies to the rows value in the column colname is false
function where(df::DataFrame, col::Symbol, p::Function)
  rows = Int[]
  for rowi = 1:size(df)[1] if p(df[rowi,col]) push!(rows,rowi) end end
  SubDataFrame(df,rows)
end


function where(df::SubDataFrame, col::Symbol, p::Function)
  rows = Int[]
  for rowi = 1:size(df)[1] if p(df[rowi,col]) push!(rows,rowi) end end
  filteredrows = Array(Int,length(rows))
  for i = 1:length(rows)
    filteredrows[i] = df.rows[rows[i]]
  end
  SubDataFrame(df.parent,filteredrows)
end


import DataFrames.groupby
function groupby(df::DataFrame, col::Symbol, f::Function)
  groupcol = DataArray([f(df[rowi,col]) for rowi = 1:size(df)[1]])
  dfc = copy(df)
  dfc[:groupcol] = groupcol
  groupby(dfc,:groupcol)
end

# Collate results across processors
function collate(rs::Vector{Result}, lensname::Symbol, varname::Symbol)
  combined = Any[]
  for r in rs
    for v in values(r.values)
      record = v[lensname][varname]
      push!(combined, record)
    end
  end
  combined
end

## Convenience Queries
all_records(db=rundb()) = convert(DataFrame,query(db,"SELECT * from runs WHERE status is 'DONE'"))
