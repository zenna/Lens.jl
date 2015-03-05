using Gadfly

function plot_xy{T1<:Real, T2<:Real}(xdata::Vector{T1}, ydata::Vector{Vector{Vector{T2}}};
                                    xlabel::String = "", ylabel::String = "")
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
                       postfilter::Function)
  #each group has a vector of vector
  ygroupdata = Vector{Vector{Float64}}[]
  for df in gd
    ydata = Vector{Float64}[]
    results = df[:results]
    collated = collate(Result[array(results)...], lensname, varname)
    for c in collated
      d = postfilter(df[gd.cols],c)
      push!(ydata,d)
    end
    push!(ygroupdata,ydata)
  end
  ygroupdata
end

function plot_xy_single(d::Dict; xlabel::String = "", ylabel::String = "")
  dfs = DataFrames.DataFrame[]
  for (group,val) in d
    push!(dfs,DataFrame(x = val[1], y = val[2], label = string(rand())))
  end

  plot(vcat(dfs...), x=:x, y=:y, color="label",Geom.line,
       Guide.xlabel(xlabel),
       Guide.ylabel(ylabel),
       Scale.x_log10,
       Theme(key_position = :bottom))
end

function plot_xy_single(gd::GroupedDataFrame, grouper::Function,
                        filterer::Function, getx::Function,
                        depvar::Symbol;
                        xlabel::String = "", ylabel::String = "")

  # gd should be grouped by properties which affect the dependent variable
  # each group will have a single line
  dc = Dict{Any, Vector{Vector{Float64}}}()

  for group in gd
    # Then we'll group by the independent variable
    # because since our algorithms sample, each of these groups will contain
    # multiple runs which we want to compute statistics for
    depgroups = grouper(group)

    # These are all our datapoints for a particular system
    xs = Float64[]
    ys = Float64[]
    for depgroup in depgroups
      xval::Float64 = getx(depgroup) #1 is as good as any
      collated = collate(Result[depgroup[:results]...],depvar,:x1)
      collatedf = Float64[filterer(c) for c in collated]
      meanc = mean(collatedf)
      push!(xs, xval)
      push!(ys, meanc)
    end
    dc[group] = Vector[xs,ys]
  end
  plot_xy_single(dc;xlabel = xlabel, ylabel = ylabel)
end
