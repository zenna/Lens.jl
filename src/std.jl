## Standard Filters
## ================

printfl = Filter(:print, x->print(x...),true,false)
printlnfl = Filter(:print, x->println(x...),true,false)

# macro filterize(fg)
#   filtername = symbol("$(string(fg))_fl")
#   @show filtername
#   :(Filter(:e, x->($fg)(x...),true,false))
# end

# @filterize(show)
# show(3)

# f = :agahaha
