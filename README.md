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

julia> replacer("t1*10+sqrt(t2)", Dict("t"=>-3, "t1"=>5, "t2"=>100))
60.0

```

- `print_vector`: Takes a vector and uses @sprintf to put it on stream IO with [%.3f, %.3f] format. If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.


```julia

julia> print_vector([1, 2, pi])
[1.000, 2.000, 3.142]
```

- `two_level_copy`: Like copy(x), but can go down a level. Can handle both Arrays and Dicts, otherwise gets confused.

```julia

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

#If there are already 8 files starting with "Mydir/model" then

julia> next_file("Mydir/model_", 4)
"Mydir/model_0009"

```

- `num2fixed_string`: Returns a string version of a positive integer, with however many leading zeros are necessary to have
ndigits characters.

```julia

julia> num2fixed_string(32, 4)
"0032"

```

- `ascii_key_ize`: Given a dictionary that has keys that can be converted to strings, returns a copy with all keys converted to strings.

- `symbol_key_ize`: Given a dictionary that has keys that can be converted to Symbols, returns a copy with all keys converted to Symbols.

- `vectorize_dict`: Given a dictionary (in which) all keys are either strings or Symbols, and all values are Float64s), and an array ks of keys into that dictionary, returns a Float64 array the same size as ks containing the values. Each key is checked as either itself or the string version of itself or the Symbol version 
of itself.


```julia
# Thus the following all return the same

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

- `safe_axes`: If you're going to make axh the current axes, this function first makes axh's figure the current figure. Some Julias break without that. Any optional keyword-value arguments are passed on to axes()

- `remove_xtick_labels`: Given an axis object, or an array of axes objects, replaces each xtick label string with the empty string "". If no axis is passed, uses gca() to work with the current axis.

- `remove_ytick_labels`: Given an axis object, or an array of axes objects, replaces each ytick label string with the empty string "". If no axis is passed, uses gca() to work with the current axis.

- `install_nearest_point_callback`: This function makes the figure indicated by fighandle interactive: any time the mouse is clicked while pointing inside any of the axes of the figure, the function user_callback() will be called, and will be passed parameters that indicate which of the points drawn in the axis is the one closest to the clicked point (closest in Euclidean data units).

**WARNING** because this runs through PyCall, any errors in your user_callback function will sadly
not show up.  The function will simply fail to work. So be careful and debug with lots of print statements.

```
BP = install_nearest_point_callback(fighandle, user_callback; user_data=nothing)

# PARAMETERS:

- fighandle       A matplotlib figure handle, e.g. the result of figure(2)

- user_callback   A function, which must take 4 or 5 parameters (see below). These will be passed to it as:


* PARAMETERS OF YOUR FUNCTION USER_CALLBACK:

        - xy          A 2-element tuple, indicating the (x,y) position of the drawn point closest to the clicked point

        - r           A scalar, indicating the Euclidean distance between the clicked location and xy

        - linehandle  A matplotlib handle to a Lines2D object (e.g., the result of plot([1,2], [3, 10])) or a PathCollection object (as returned by scatter()).

        - axhandle    A matplotlib handle to the axis (e.g., the result of gca()) in which the event occurred.

        - user_data   If `install_nearest_point_callback()` was called user_data set to something, then 
                      your function will be called with *five* parameters, and the last one will be the contents of
                      the user_data

# OPTIONAL PARAMETERS FOR INSTALL_NEAREST_POINT_CALLBACK():

- user_data       Data to be stored internally and made available to the callback function. Default
                  is nothing, in which case the callback function is called with 4 params


# RETURNS:

- BP     A PyCall.PyObject kbMonitorModule_kb_monitor object. This object contains the underlying engine
linking the figure to the callback function. To disconnect that link, call "remove_BP(BP)". To disconnect
*all* existing BP-function links, call "remove_all_BPs()".
```

```julia
pygui(true)

function mycallback(xy, r, h, ax)
    @printf("(%.3f,%.3f), r=%3f ", xy[1], xy[2], r);
    print(h)
    print(ax)
    print("\n")
end

BP = install_nearest_point_callback(figure(2), mycallback)
plot([2,2])
```

- `install_callback_reporter`: Useful as a debugging tool for `install_nearest_point_callback()`: can be used with that function as a callback; when called, simply prints out its parameters. Returns userdata, does not print it.

- `remove_BP`: Disconnects a kbMonitorModule.kb_monitor object from its figure.

- `remove_all_BPs`: Disconnects *all* kbMonitorModule.kb_monitor objects from their figures.

- `get_current_fig_position`: Works only when pygui(true) and when the back end is QT. Has been tested only with PyPlot.

- `set_current_fig_position`: Works only when pygui(true) and when the back end is QT. Has been tested only with PyPlot.

- `capture_current_figure_configuration`: Collects the positions of all current figures and prints out to the screen code, that can be copy-pasted, that would reproduce that positioning configuration.

```

C = capture_current_figure_configuration()

# PARAMETERS:

None

# RETURNS:

- C    A matrix that is nfigures-by-5 in size. You probably
    don't want this, you probably want the text printed to
    the screen, but here just in case.  Each row will have,
    in order: figure number, x, y, width, height

```


### Gradient Utilities
Several of the functions defined here are related to doing differentiation with respect to parameters that are defined as keyword-value parameters in the function to be differentiated. Some functions defined here are:

- `make_dict`: If you're working with keyword-value pairs, you will want to manipulate sets of those. make_dict() is a function that helps you do that, for example, for merging current selected parameter values with a superset of default values (see below).  In addition, make_dict() is central to the gradient- and hessian-taking functions defined here that operate on keyword-value pairs. The reason is that make_dict() can take a vector (as one of its parameters) and turn it into keyword-value pairs, and we need this transformation to work with the ForwardDiff package, since that package only operates on functions of vectors.

The ForwardDiff package takes gradients of functions of vectors. `make_dict()` was originally written as an internal function to keyword_vgh(), essentially for turning keyword-value pairs into a vector that ForwardDiff could work with. The main goal was to make gradient-taking flexible, so the user could easily switch between different chosen parameters. However, make_dict() turns out to be useful externally, for the user, also.

The basic usage of make_dict is to take a list of strings, and a vector of numeric values of the same length, and turn those into a dictionary that Julia can use when passing paramaters. Thus, for example,

> `tester(;a=10, b=20)`

is equivalent to


> `tester(;make_dict(["a", "b"], [10, 20])...)`

which can be used to pass all the various desired parameter values as a single vector, which is what ForwardDiff needs, and is how keyword_vgh() works.

> (**An aside on Julia symbols and passing sets of keyword-values to functions**: The `...` is Julia-speak for "this argument contains a set of multiple keyword-value pairs."  In Julia, that can be either a dictionary of Symbol=>value pairs, or a list of (Symbol, value) tuples). 

> `make_dict()` itself returns a dictionary, so `make_dict(["a", "b"], [10, 20])` returns `Dict(:a=>10, :b=>20)`.  A Julia Symbol stands for a variable; you can go back and forth between strings and Symbols by using, for example, `Symbol("a")` to get `:a`, or use `string(:a)` to get `"a"`.)

The typical thing a user will use make_dict() for is to merge paramater values with a superset of default parameter values. For example, suppose you have defined a scalar function

> `function tester(;a=1, b=2, c=3, d=4)`

You can decide you want your default parameter values to be as defined here:

> `defaults = Dict(:a=>10, :b=20, :c=>30, :d=>40)`

Given that, you can call `tester()` with this set of values by calling `tester(;defaults...)`.


Now suppose you've done a minimization search over two of these paramaters. Let's say that you indicate your choice of those parameters in `args = ["a", "c"]`. And let's say the resulting values for them are in the two-long vector `pars`.  You want to call `tester()` with the default parameter values _except_ for whatever is indicated in `args` and `pars`. To do that, you use the optional third argument of `make_dict()` as follows:

> `tester(;make_dict(args, pars, defaults)...)`


```julia
julia> make_dict(["this", "that", ["there", 2]], [10, 20, 3, 4])
Dict{Any,Any} with 3 entries:
  :this  => 10
  :that  => 20
  :there => [3,4]

julia> make_dict(["doo", "gaa"], [10, 20], Dict(:blob=>100, :gaa=>-44))
Dict{Symbol,Int64} with 3 entries:
  :gaa  => 20
  :blob => 100
  :doo  => 10

```
- `FDversion`: Here we're going to define a closure over x so that when this code runs, it sets the local variable x to report ForwardDiff's verison number; then we export the function FDversion, that simply returns x.  When we call FDversion(), it simply returns the value of x, stored locally inside the let block. So it is extremely fast.

- `ForwardDiffZeros`: Use instead of zeros(). Creates a matrix of zeros, of size m rows by n columns, with elements appropriate for differentiation by ForwardDiff. If nderivs==0 or difforder==0 then the elements will be regular Float64, not ForwardDiff types.

```
M = ForwardDiffZeros(m, n; nderivs=0, difforder=0)

PARAMETERS:
===========

m        Integer, number of rows

n        Integer, number of columns


OPTIONAL PARAMETERS:
====================

nderivs=0       The number of variables that we'll be differentiating with respect to. In other
                words, this number is equal to the length of the gradient. If this is left as zero (the default) then 
                the data type will be regular Float64

difforder=0     The order of the derivative we will want to take.  Zero means nothing, stick with
                regular Float64, 1 means gradient, 2 means hessian

RETURNS:
========

An m-by-n matrix of zeros that can be used with ForwardDiff.
```

- `get_eltype`: vars should be a tuple of variables. If any of them is a ForwardDiff Dual, this function returns the typeof of that one (the first one encountered); otherwise it returns Float64.

- `get_value`: If you're going to @print something that might be a ForwardDiff Dual, use this function. It'll return the value of the number if it is a Dual and just the number if it was not a Dual, suitable for
printing.

```julia
@printf("%g\n", get_value(x))
    
# will work regardless of whether x is a ForwardDiff Dual, a Float64, or an Int64 

```

- `vgh`: Wrapper for ForwardDiff.hessian!() that computes and returns all three of a function's value, gradient, and hessian.

```julia
function tester(x::Vector)

    return sum(x.*x)
end

value, grad, hess = vgh(tester, [10, 3.1])
```

- `keyword_vgh`: Wrapper for vgh() that computes and returns all three of a function's value, gradient, and hessian, but now uses make_dict() to apply it to a function that only takes keyword-value pairs. 
*Note that func MUST also take the keyword parameters nderivs and difforder*. If you declare any vectors or matrices inside func() (or inside any function inside func()), use ForwardDiffZeros with these two parameters, do NOT use zeros(). Your gradients will come out as zero is you use zeros().

```
value, gradient, hessian = keyword_vgh(func, args, x0)

# PARAMETERS

* func    A function that takes keyword-value pairs only, including nderivs and difforder.  I.e., it must be a function declared as `function func(; nderivs=0, difforder=0, other_kw_value_pairs)` or as `function func(; nderivs=0, difforder=0, other_kw_value_pairs_dict...)`
* args    A list of strings indicating names of variables to work with
* x0      A vector with the value of the variables indicates in args.  **See make_dict() for how to pass both scalars and vectors as variables**

# IMPORTANT JULIA BUG

If you modify func, it is possible that keyword_vgh() will still work on the previously defined version. AACK!  
That's horrible! Alice Yoon's tip on the workaround: instead of func(), use (;params...) -> func(; params...) and then
everything will be fine. Perhaps this bug will be fixed in Julia 0.6
```

```julia
function tester(;a=10, b=20, c=30, nderivs=0, difforder=0)
    M = ForwardDiffZeros(3, 3; nderivs=nderivs, difforder=difforder)
    M[1,1] = a^2*10
    M[2,2] = b*20
    M[3,3] = a*sqrt(c)*30.1
    return trace(M)
end

value, grad, hess = keyword_vgh(tester, ["a", "c"], [10, 3.1])

value, grad, hess = keyword_vgh((;params...) -> tester(;params...), ["a", "c"], [10, 3.1])

```

## Testing

In a Julia session, run `Pkg.test("GeneralUtils")`.


[unregistered]:http://docs.julialang.org/en/release-0.4/manual/packages/#installing-unregistered-packages
[version]:http://julialang.org/downloads/platform.html
[Bing]:http://brodylab.org/publications-2/brunton-et-al-2013


[![Build Status](https://travis-ci.org/misun6312/GeneralUtils.jl.svg?branch=master)](https://travis-ci.org/misun6312/GeneralUtils.jl)

[![Coverage Status](https://coveralls.io/repos/misun6312/GeneralUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/misun6312/GeneralUtils.jl?branch=master)
