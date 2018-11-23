@doc """Result of a capture
  Result.val has form:
  Processor id -> (lensname -> (varname -> Vector of values captured at lens)""" ->
struct Result
  values::Dict{Int,Dict{Symbol,Dict{Symbol,Vector{Any}}}}
end

Result() = Result(Dict{Int,Dict{Symbol,Vector{Any}}}())
convert(::Type{Vector{Result}}, x::Vector{Any}) =
  (rs = similar(x,Result); for i = 1:length(x) rs[i] = x[i] end)

# Convenience functions for extracting data from a Result
function get(r::Result; proc_id::Int=1, lensname=nothing, capturename=nothing)
  entries = r.values[proc_id]
  if lensname == nothing
    length(entries) != 1 && error("No lensname specified and more than one lens captured")
    lensname = first(entries)[1]
  end
  if capturename == nothing
    length(entries[lensname]) != 1 && error("No capture name specified and more than one captured <found></found>")
    capturename = first(entries[lensname])[1]
  end
  entries[lensname][capturename]
end

get(r::Tuple{T,Result}) where T = get(r[2])
