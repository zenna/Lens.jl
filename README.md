# A lens into the soul of your program

[![Build Status](https://travis-ci.org/zenna/Lens.jl.svg?branch=master)](https://travis-ci.org/zenna/Lens.jl)

Lens.jl is a simple Julia package which makes it easy to dynamically inspect and extract values deep within your program, with minimal interference to the program itself.

The philosophy of Lens is that observation should not imply interference.  A running program is like a machine; there are many possible things we might like to know about its dynamics, but we want a clean interface that doesn't require us to mutate our machine in order to observe it.

# Installation

Lens is not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with

```julia
Pkg.clone("https://github.com/zenna/Lens.jl.git")
```

# Usage

Suppose we have a bubblesort:

```julia
function bubblesort{T}(a::AbstractArray{T,1})
    b = copy(a)
    isordered = false
    span = length(b)
    while !isordered && span > 1
        lens(:start_of_loop, b)
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
    end
    return b
end
```

The the algorithm don't matter, what's important is the `lens`.  Lens are created in one of two forms, the first, used in bubblesort, is as follows:

```julia
lens(lensname::Symbol, x, y, ...)
```

The first argument is a symbol and gives a name to the lens.  We'll need to remember the name for later when we attach *filters* to the lens.
The remaining arguments `x,y,...` are any values you want the lens to capture.

Lenses capture values we specify, then propagate that data onto `Filters`.
Lenses themselves do not contain any information about the filters, the filters are attached onto Lens through a function `register!`.  For example we can register a printing filter to the lens with:

```julia
register!(println, :print_data, :start_of_loop, false)
```

Then if we if we simply call `bubblesort` our lens will be activated.

```julia
julia> bubblesort([1,2,0,3])
[1,2,0,3]
[1,0,2,3]
[0,1,2,3]
4-element Array{Int64,1}:
 0
 1
 2
 3
```

The previous call to register `register!(f::Function, filtername::Symbol, lensname::Symbol, kwargs::Bool` took a Function as input and automatically created a `Filter` for us.  This is just for convenience, and it allows us to use the `do` notation

```julia
register!(:print_data, :start_of_loop, false) do
  do something
end
```

We can, of course, create a `Filter` explicitly

```julia
register!(:start_of_loop, Filter(:gfunc, gfunc, true, true))
```

## Keyword arguments

creates a Filter which takes arbitrary input and prints it.  The arguments are 1) the filters name (which might be useful if we want to remove or disable the filter later), 2) a function which transforms information sent to it by the lens 3) whether the filter is enabled or not 4) whether the filter takes keyworld arguments (we'll get to thsi soon)


Now if we evaluate f, we should see some output

```
f()
=>
```

# Capturing

Often we want to just extract or capture some values somewhere deep within our programs.
A `Capture` is a s

## Basic Architecture

There are three kinds of thing

- Lens
- Data
- Filter

When a lens is encountered in code, it propagates `Data` to all `Filters` which are registered to it.

## Enabling and Disabling Filters

If you want to temporarily disable all the filters and render all your lenses ineffectual use `disable_all_filters!()`.  To renable them all use `enable_all_filters!()`.  These can be convenient for example if you want dynamically switch between filters which are printing information to the screen.

For more fine grained control use enable `enable_filter!(watch_name::Symbol, filter_name::Symbol)` which enables the lens with name `watch_name` propagating to the filter with name `filter_name`.  Unsurprisingly, these is also `disable_filter!`.

For more permanent effect there is `delete_filter!` and `clear_all_filters!`, which are just like above but not temporary.