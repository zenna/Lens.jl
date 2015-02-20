# A Lens into the soul of your program

Lens.jl is a simple Julia library to introspect on the runtime behaviour of your programs, with minimal interference with the program itself.  It is useful when

- You want to profile your program, but want to inspect arbitrary statistics of arbitrary values in the program.
- You have multiple solutions to a prolem and you want to compare them

[![Build Status](https://travis-ci.org/zenna/Lens.jl.svg?branch=master)](https://travis-ci.org/zenna/Lens.jl)

# Installation

Lens is not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with

```julia
Pkg.clone("https://github.com/zenna/Lens.jl.git")
```

# Usage

Perhaps the most efficient way to understand how Lens.jl works is to look at the tests.
<!-- 

## Lens
Suppose you have a function:

```julia
function f()
  X = rand(1000)
  adad
```

Lens can be used in one of two ways

```julia
lens(:lensname, x, y)
```

The first argument is a symbol and gives a name to the lens.
We'll need the name later when we attach filters to the lens.
The remaining arguments `x,y,...` are any values you want the lens to capture.

Lenses capture values we specify, then propagate that data onto `Filters`.
Lenses themselves do not contain any information about the filters, the filters are attached onto Lens through a function `register!`.

The filter:

```julia
fl = Filter(:print, x->print(x...),true,false)
```

creates a Filter which takes arbitrary input and prints it.  The arguments are 1) the filters name (which might be useful if we want to remove or disable the filter later), 2) a function which transforms information sent to it by the lens 3) whether the filter is enabled or not 4) whether the filter takes keyworld arguments (we'll get to thsi soon)

```

We connect the filter to the lens with:

```julia
register!(:lensname, fl)
```

Now if we evaluate f, we should see some output

```
f()
=>
```

A `Capture` is a s

## Benchmarks -->
