# GeneralUtils

The `GeneralUtils` package currently provides a variety of utility functions including non-GUI utilities, GUI utilities, and utility functions related to algorithmic differentiation.

## Installation

As described in the manual, to [install unregistered packages][unregistered], use `Pkg.clone()` with the repository url:

```julia
Pkg.clone("https://github.com/misun6312/GeneralUtils.jl.git")
```

Julia version 0.6 is required (install instructions [here][version]).

## Usage

### non-GUI Utilities

- `append_to_file`: Opens filename, appends str to it, and closes filename. If filename is not a string but us type Base.PipeEndpoint (an IO stream)
then simply prints to it, without trying to open or close

- `replacer`: Given a string representing an expression to be evaluated, and a dictionary of 
keys that are strings representing variables with values that are numbers,
parses the string into an expression, and substitutes any variables matching
the keys in mypars with the corresponding numeric values; finally, evaluates the
expression and returns the result.

```julia
# EXAMPLE:

julia> replacer("t1*10+sqrt(t2)", Dict("t"=>-3, "t1"=>5, "t2"=>100))
60.0

```

- `print_vector`: Takes a vector and uses @sprintf to put it on stream IO with [%.3f, %.3f] format. If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.


```julia
# EXAMPLE:

julia> print_vector([1, 2, pi])
[1.000, 2.000, 3.142]
```

- `two_level_copy`: Like copy(x), but can go down a level. Can handle both Arrays and Dicts, otherwise gets confused.

```julia
# EXAMPLE:

p = [1, 2, 3]
z = [p, 4]
y = Dict(:my=>p)

c = copy(z)
d = copy(y)

alpha = two_level_copy(z)
beta  = two_level_copy(y)
p[1]=1000

print("The inner levels of c and d are affected by the change to p:\n")
print(c); print("\n")
print(d); print("\n")
print("But the inner levels of alpha and beta are not:\n")
print(alpha); print("\n")
print(beta); print("\n")

---------------- output ---------------
The inner levels of c and d are affected by the change to p:
Any[[1000, 2, 3], 4]
Dict(:my=>[1000, 2, 3])
But the inner levels of alpha and beta are not:
Any[[1, 2, 3], 4]
Dict(:my=>[1, 2, 3])

```

- `next_file`: Returns a numbered and presumably unused filename starting with the string fbasename, followed by an integer digit. The returned integer will be one higher than the number of existing filenames starting with fbasename, and will be written with ndigits numbers, using leading zeros if necessary.

```julia
# EXAMPLE:

#If there are already 8 files starting with "Mydir/model" then

julia> next_file("Mydir/model_", 4)
"Mydir/model_0009"

```

- `num2fixed_string`: Returns a string version of a positive integer, with however many leading zeros are necessary to have
ndigits characters.

```julia
# EXAMPLE:

julia> num2fixed_string(32, 4)
"0032"

```

- `ascii_key_ize`: Given a dictionary that has keys that can be converted to strings, returns a copy with all keys converted to strings.

- `symbol_key_ize`: Given a dictionary that has keys that can be converted to Symbols, returns a copy with all keys converted to Symbols.

- `vectorize_dict`: Given a dictionary (in which) all keys are either strings or Symbols, and all values are Float64s), and an array ks of keys into that dictionary, returns a Float64 array the same size as ks containing the values. Each key is checked as either itself or the string version of itself or the Symbol version 
of itself.


```julia
# EXAMPLE: Thus the following all return the same

a = Dict(:this=>33.4, "that"=>28.7)

vectorize_dict(a, ["this", "that"])
vectorize_dict(a, [:this, "that"])
vectorize_dict(a, [:this, :that])

---------------- output ---------------
2-element Array{Float64,1}:
 33.4
 28.7

```

### GUI Utilities
### Gradient Utilities


## Testing

In a Julia session, run `Pkg.test("GeneralUtils")`.


[unregistered]:http://docs.julialang.org/en/release-0.4/manual/packages/#installing-unregistered-packages
[version]:http://julialang.org/downloads/platform.html
[Bing]:http://brodylab.org/publications-2/brunton-et-al-2013


[![Build Status](https://travis-ci.org/misun6312/GeneralUtils.jl.svg?branch=master)](https://travis-ci.org/misun6312/GeneralUtils.jl)

[![Coverage Status](https://coveralls.io/repos/misun6312/GeneralUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/misun6312/GeneralUtils.jl?branch=master)
