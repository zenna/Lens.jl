using Base.Test
using Lens

function f()
  x = 10;
  lens(:mylens,x=x)
  y = 20
  lens(:his,y)
  z = 30
  lens(:yourlens,z=z,y=y)
  40
end

value, results = quickbench(f, [(:mylens,[:x])])

@test value == 40
@test results[:mylens][1].data[:x] == 10
value, results = quickbench(f, :his)
@test results[:his][1].data[:x1] == 20


value, results = quickbench(f, [(:yourlens, [:z,:y])])
@test results[:yourlens][1].data[:z] == 30
@test results[:yourlens][1].data[:y] == 20
