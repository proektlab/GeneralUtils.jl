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
# EXAMPLE:

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


## Testing

In a Julia session, run `Pkg.test("GeneralUtils")`.


[unregistered]:http://docs.julialang.org/en/release-0.4/manual/packages/#installing-unregistered-packages
[version]:http://julialang.org/downloads/platform.html
[Bing]:http://brodylab.org/publications-2/brunton-et-al-2013


[![Build Status](https://travis-ci.org/misun6312/GeneralUtils.jl.svg?branch=master)](https://travis-ci.org/misun6312/GeneralUtils.jl)

[![Coverage Status](https://coveralls.io/repos/misun6312/GeneralUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/misun6312/GeneralUtils.jl?branch=master)
