using Lens
using Base.Test

function simpletest()
  a = rand(10)
  b = rand(10)
  lens(:after_rand,a)
end

clear_all_filters!()
register!(i->length(i) == 10, :after_rand, :justshow)
simpletest()
enable_all_filters!()
disable_all_filters!()
