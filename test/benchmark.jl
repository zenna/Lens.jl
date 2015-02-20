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
@quickbench((x = 3 ;x + lens(:tlens, x^x)),:tlens)
