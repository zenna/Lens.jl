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

value, results = capture(f, [(:mylens,[:x])])
@test value == 40
@test get(results)[1] == 10
value, results = capture(f, :his)
@test get(results)[1] == 20

value, results = capture(f, [(:yourlens, [:z,:y])])
@test get(results;capturename=:z)[1] == 30
@test get(results;capturename=:y)[1] == 20

## Parallel Tests
addprocs(1)
@everywhere using Lens

function parbench()
  a = zeros(100)
  tot = 0
  lens(:sum,tot)
  for proc in procs()
    Bref = @spawn (s = sum(rand(1000,1000)^2); lens(:sum,s); s)
    tot += fetch(Bref)
  end
  tot
end

## Test Macro
@capture((x = 3 ;x + lens(:tlens, x^x)),:tlens)
