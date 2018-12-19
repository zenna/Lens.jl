# A lens into the soul of your program

[![Build Status](https://travis-ci.org/zenna/Lens.jl.svg?branch=master)](https://travis-ci.org/zenna/Lens.jl)

Lens.jl is a simple Julia package which makes it easy to dynamically inspect and extract values deep within a program, with minimal interference to the program itself.

The philosophy of Lens is that observation should not imply interference.  A running program is like a machine; there are many possible things we might like to know about its behaviour, but we want a clean interface that doesn't require us to mutate our machine in order to observe it.

# Installation

Lens is in the official Julia Package repository.  You can easily install it from a Julia REPL with:

```julia
] add Lens
```

# Usage

Suppose we have a function which [bubble sorts](http://en.wikipedia.org/wiki/Bubble_sort) an array:

```julia
function bubblesort(a::AbstractArray{T,1}) where T
  b = copy(a)
  isordered = false
  span = length(b)
  i = 0
  while !isordered && span > 1
    lens(:start_of_loop, (b = b, i = i)) # <--- lens here!!
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
  lens(:after_loop, (sorteddata = b, niters = i)) # <--- and here!!
  return b
end
```
The algorithm details do not matter; what is important is the `lens`.  Lenses are created in the form:

```julia
lens(lensname::Symbol, x, y, ...)
```

The first argument is a Symbol which gives a name to the lens.  We'll need to remember the name for later when we attach functions to the lens.
The remaining arguments `x, y,...` are any values you want the lens to capture.
It is recommended to use keyword `NamedTuples`

Lenses capture values we specify, then propagate that data onto listeners.
Lenses themselves do not contain any information about the listeners, the listeners are attached onto Lens in the context of a particular execution.
This is achieved with Lens Evaluation `@leval`

```julia
lmap = (start_of_loop = ((b, i)) -> , end_of_loop = println)
@leval bubblesort lmap
```

The second argument of @leval is a lens map (often abbreivated to `lmap`).  In this simplest form, it is a `NamedTuple` where mapping lens names to funtions.

## Composing Functions

Often we want to execute an expression and attach many functions to a lens.

```julia
function analgorithm(x)
  for i = 1:10
    x = x + i
    lens(:loopend, (x = x, i = i))
  end
end

f1((x, i)) = "Printing x: $x"
f2((x, i)) = "Printing y: $y"
@leval analgorithm (endloop = f1 + f2)
```

In some case, we need more complex compositions.
For example, we may the output of one 
