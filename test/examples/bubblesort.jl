using Lens

function bubblesort(a::AbstractVector)
    b = copy(a)
    isordered = false
    span = length(b)
    iter = 0
    while !isordered && span > 1
        lens(:start_of_loop, b, iter) # <--- lens here!!
        isordered = true
        for i in 2:span
            if b[i] < b[i-1]
                t = b[i]
                b[i] = b[i-1]
                b[i-1] = t
                isordered = false
            end
        end
        span -= 1
        iter += 1
    end
    lens(:after_loop, sorteddata=b, niters=iter) # <--- and here!!
    return b
end

register!(println, :print_data, :start_of_loop, false)
bubblesort([1,2,0,3])
register!(:start_of_loop, Listener(:print_data, print, true, true))
bubblesort([1,2,0,3])

clear_all_listeners!()
register!(:print_data, :start_of_loop, false) do data, index
  println("on $index-th iteration the first element is $(index[1])")
end

bubblesort([50,2,0,20])

clear_all_listeners!()
function many_bubbles()
  for i = 1:100
    bubblesort(rand(100))
  end
end

iters = capture(many_bubbles, [(:after_loop, [:niters])])
get(iters)
