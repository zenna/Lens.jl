using Lens

struct Loop end
struct LoopEnd end
function bubblesort(a::AbstractArray{T,1}) where T
  b = copy(a)
  isordered = false
  span = length(b)
  i = 0
  while !isordered && span > 1
    lens(Loop, (b = b, i = i)) # <--- lens here!!
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
    i += 1
  end
  lens(LoopEnd, (sorteddata = b, niters = i)) # <--- and here!!
  return b
end

function bubblesortnolens(a::AbstractArray{T,1}) where T
  b = copy(a)
  isordered = false
  span = length(b)
  i = 0
  while !isordered && span > 1
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
    i += 1
  end
  return b
end

function test()
  @leval bubblesort([1, 4, 2]) (after_loop = (println,),)
end

test()