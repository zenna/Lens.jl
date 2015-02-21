using Base.Test
using Lens

clear_all_filters!()
@test length(values(lens_to_filters)) == 0

function simpletest1()
  a = 10
  b = 10
  lens(:after_rands1;a=a,b=b)
end

gfunc(m) = @test sum(m[:a]) + sum(m[:b]) == 20
register!(:after_rands1, Filter(:gfunc, gfunc, true, true))
@test nfilters() == 1
enable_all_filters!()
simpletest1()

clear_all_filters!()
function simpletest2()
  a = 10
  b = 10
  lens(:after_rands2,a,b)
end

register!(:gunit, :after_rands2, false) do x,y
  @test x + y == 20
end

simpletest2()
enable_all_filters!()
disable_all_filters!()

function f()
  x = 20
  y = 30
  z = 50
  lens(:x,x)
  lens(:y,y)
  lens(:z,z)
end

value, res = quickbench(f,[:x,:y,:z])
(50,[:z=>{Data(1,:z,[:x1=>50])},:x=>{Data(1,:x,[:x1=>20])},:y=>{Data(1,:y,[:x1=>30])}])