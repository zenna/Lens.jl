using Base.Test
using Lens

function f()
  x = 10;
  lens(:mylens,x)
  y = 20
  z = 30
  lens(:yourlens,x=x,y=y)
  40
end

value, results = quickbench(f, [:mylens])
@test value == 40
@test results[:mylens][1] == 10
@test length(results) == 1
value, results = quickbench(f, Capture[:mylens, (:yourlens,:x), (:yourlens,:y)])

@test results[:yourlens_y][1] == 20