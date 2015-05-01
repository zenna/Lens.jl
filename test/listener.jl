using Base.Test
using Lens

clear_all_listeners!()
@test length(values(Lens.lens_to_listeners)) == 0

function simpletest1()
  a = 10
  b = 10
  lens(:after_rands1;a=a,b=b)
end

gfunc(m) = @test sum(m[:a]) + sum(m[:b]) == 20
register!(:after_rands1, Listener(:gfunc, gfunc, true, true))
@test nlisteners() == 1
enable_all_listeners!()
simpletest1()

clear_all_listeners!()
function simpletest2()
  a = 10
  b = 10
  lens(:after_rands2,a,b)
end

register!(:gunit, :after_rands2, false) do x,y
  @test x + y == 20
end

simpletest2()
enable_all_listeners!()
disable_all_listeners!()

function f()
  x = 20
  y = 30
  z = 50
  lens(:x,x)
  lens(:y,y)
  lens(:z,z)
end

value, res = capture(f,[:x,:y,:z])
