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

- `append_to_file`: Opens filename, appends str to it, and closes filename.

If filename is not a string but us type Base.PipeEndpoint (an IO stream)
then simply prints to it, without trying to open or close

- `replacer`: Given a string representing an expression to be evaluated, and a dictionary of 
keys that are strings representing variables with values that are numbers,
parses the string into an expression, and substitutes any variables matching
the keys in mypars with the corresponding numeric values; finally, evaluates the
expression and returns the result.

```julia
# EXAMPLE:

replacer("t1*10+sqrt(t2)", Dict("t"=>-3, "t1"=>5, "t2"=>100))
replacer(parse("t1*10+sqrt(t2))", Dict("t"=>-3, "t1"=>5, "t2"=>100))

```

- `print_vector`: Takes a vector and uses @sprintf to put it on stream IO with [%.3f, %.3f] format. 

If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.


- `two_level_copy`: Like copy(x), but can go down a level. Can handle both Arrays and Dicts, otherwise gets confused.

```julia
EXAMPLE:

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

```

- `next_file`: Returns a numbered and presumably unused filename starting with the string fbasename, followed by an integer digit. The returned integer will be one higher than the number of existing filenames starting with fbasename, and will be written with ndigits numbers, using leading zeros if necessary.

```julia
# EXAMPLE:

If there are already 8 files starting with "Mydir/model" then

> next_file("Mydir/model_", 4)

"Mydir/model_0009"

```

- `num2fixed_string`: Returns a string version of a positive integer, with however many leading zeros are necessary to have
ndigits characters.

```julia
# EXAMPLE:

num2fixed_string(32, 4)

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

```

### GUI Utilities
### Gradient Utilities



## Example

### non-GUI Utilities
### GUI Utilities
### Gradient Utilities

The simple example below computes a log likelihood of model with example trial.

```julia
using PBupsModel
using MAT

dt = 0.02

# read test data file
ratdata = matread("data/testdata.mat")

# using TrialData load trial data
RightClickTimes, LeftClickTimes, maxT, rat_choice = TrialData(ratdata["rawdata"], 1)

Nsteps = Int(ceil(maxT/dt))

# known parameter set (9-parameter)
args = ["sigma_a","sigma_s_R","sigma_i","lambda","B","bias","phi","tau_phi","lapse_R"]
x = [1., 0.1, 0.2, -0.5, 6.1, 0.1, 0.3, 0.1, 0.05*2]

# Compute Loglikelihood value
LL = LogLikelihood(RightClickTimes, LeftClickTimes, Nsteps, rat_choice
                ;make_dict(args, x)...)

# Compute Loglikelihood value of many trials
ntrials = 1000
LLs = SharedArray(Float64, ntrials)
LL_total = ComputeLL(LLs, ratdata["rawdata"], ntrials, args, x)

# Compute Gradients 
LL, LLgrad = ComputeGrad(ratdata["rawdata"], ntrials, args, x)

# Compute Gradients 
LL, LLgrad, LLhess = ComputeHess(ratdata["rawdata"], ntrials, args, x)

# Model Optimization
args = ["sigma_a","sigma_s_R","sigma_i","lambda","B","bias","phi","tau_phi","lapse_R"]
init_params = InitParams(args)
result = ModelFitting(args, init_params, ratdata, ntrials)
FitSummary(mpath, fname, result)

# known parameter set (12-parameter including bias parameters)
args_12p = ["sigma_a","sigma_s_R","sigma_s_L","sigma_i","lambda","B","bias","phi","tau_phi","lapse_R","lapse_L","input_gain_weight"]
x_12p = [1., 0.1, 50, 0.2, -0.5, 6.1, 0.1, 0.3, 0.1, 0.05*2, 0.2, 0.4]

# Compute Loglikelihood value of many trials
ntrials = 400
LLs = SharedArray(Float64, ntrials)
LL = ComputeLL(LLs, ratdata["rawdata"], ntrials, args_12p, x_12p)
print(LL)

# Compute Gradients 
LL, LLgrad = ComputeGrad(ratdata["rawdata"], ntrials, args_12p, x_12p)
print(LLgrad)

# Compute Gradients 
LL, LLgrad, LLhess = ComputeHess(ratdata["rawdata"], ntrials, args_12p, x_12p)
print(LLhess)


```

## Testing

In a Julia session, run `Pkg.test("GeneralUtils")`.


[unregistered]:http://docs.julialang.org/en/release-0.4/manual/packages/#installing-unregistered-packages
[version]:http://julialang.org/downloads/platform.html
[Bing]:http://brodylab.org/publications-2/brunton-et-al-2013


[![Build Status](https://travis-ci.org/misun6312/GeneralUtils.jl.svg?branch=master)](https://travis-ci.org/misun6312/GeneralUtils.jl)

[![Coverage Status](https://coveralls.io/repos/misun6312/GeneralUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/misun6312/GeneralUtils.jl?branch=master)
