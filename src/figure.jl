using Gadfly
function plot_xy{T1<:Real, T2<:Real}(xdata::Vector{T1}, ydata::Vector{Vector{Vector{T2}}};
                                    xlabel::String = "", ylabel::String = "", )
  dfs = DataFrames.DataFrame[]
  i = 1
  for group in ydata
    lengths = [length(c) for c in group]
    means = Float64[]
    mins = Float64[]
    maxs = Float64[]
    for j = 1:maximum(lengths)
      vals = Float64[]
      for l = 1:length(group)
        j <= length(group[l]) && push!(vals,group[l][j])
      end
      push!(means, mean(vals))
      push!(mins, minimum(vals))
      push!(maxs, maximum(vals))
    end
    df = DataFrames.DataFrame(x=1:length(means), y = means, ymin = mins, ymax = maxs, label = "$i")
    push!(dfs,df)
    i += 1
  end
  plot(vcat(dfs...), x=:x, y=:y, ymin = :ymin, ymax = :ymax, color="label",Geom.line,
       Guide.xlabel(xlabel),
       Guide.ylabel(ylabel),
       Theme(lowlight_opacity=0.1,panel_opacity=0.1, key_position = :bottom))
end

function parse_results(gd::GroupedDataFrame, lensname::Symbol, varname::Symbol,
                       postfilter::Function; groupcol = :problem)
  #each group has a vector of vector
  ygroupdata = Vector{Vector{Float64}}[]
  for df in gd
    ydata = Vector{Float64}[]
    results = df[:results]
    collated = collate(Result[array(results)...], lensname, varname)
    for c in collated
      d = postfilter(df[1,groupcol],c)
      push!(ydata,d)
    end
    push!(ygroupdata,ydata)
  end
  ygroupdata
end

# Plot a Grouped Result Set
# Every row of a resultset corresponds to a line
function plot_xy(gd::GroupedDataFrame, postfilter::Function, lensname::Symbol,
                 varname::Symbol; xlabel::String = "", ylabel::String = "")
  # Extract the ydata and xdata
  ydata = parse_results(gd, lensname, varname, postfilter)
  xdata = [1,2,3]
  plot_xy(xdata, ydata; xlabel = xlabel, ylabel = ylabel)
end




# # Every row of a resultset corresponds to a single point on a line
# # useful e.g. for runtime vs dimension
# function plot_xy_single(xcolname, xextractf, ycolname, yextractf)
#   plot_xy(x)
# end