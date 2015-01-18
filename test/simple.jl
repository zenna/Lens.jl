using Window
using Base.Test

function simpletest()
  a = rand(10)
  b = rand(10)
  window(:after_rand,a)
end

clear_all_filters!()
register!(:after_rand, :justshow, i->@show @test length(i) == 10)
simpletest()
enable_all_filters!()
disable_all_filters!()
