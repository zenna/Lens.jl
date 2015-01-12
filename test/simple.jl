using Window
using Base.Test

function simpletest()
  a = rand(10)
  @window after_rand a
end

register!(:after_rand, :justshow, i->@test length(i) == 10)
simpletest()
