using Printf

"""
    append_to_file(filename, str)

Opens filename, appends str to it, and closes filename.

If filename is not a string but us type Base.PipeEndpoint (an IO stream)
then simply prints to it, without trying to open or close
"""
function append_to_file(filename, str)
    if typeof(filename)<:IO
        @printf(filename, "%s", str)
    else
        fstr = open(filename, "a")
        @printf(fstr, "%s", str)
        close(fstr)
    end
end



"""
evaluated_expression = replacer(P::String, mypars)

Given a string representing an expression to be evaluated, and a dictionary of 
keys that are strings representing variables with values that are numbers,
parses the string into an expression, and substitutes any variables matching
the keys in mypars with the corresponding numeric values; finally, evaluates the
expression and returns the result.

# PARAMETERS:

- P::String   The expression to be evaluated, for example "t1*10 + sqrt(t2)"

- mypars      A dictionary mapping variable names to values, for example 
                Dict("t1"=>5, "t2"=>100)

# RETURNS:

The result of evaluating the corresponding expression. Any variables that cannot
be instantiated into values will result in an Undefvar error

# EXAMPLE:

```jldoctest
julia>  replacer("t1*10+sqrt(t2)", Dict("t"=>-3, "t1"=>5, "t2"=>100))

15

```

"""
function replacer(P::String, mypars)
    return replacer(parse(P), mypars)
end


"""
evaluated_expression = replacer(P::Expr, mypars)

Given an expression to be evaluated, and a dictionary of 
keys that are strings representing variables with values that are numbers,
substitutes any variables matching
the keys in mypars with the corresponding numeric values; finally, evaluates the
expression and returns the result.

# PARAMETERS:

- P::String   The expression to be evaluated, for example parse("t1*10 + sqrt(t2))"

- mypars      A dictionary mapping variable names to values, for example 
                Dict("t1"=>5, "t2"=>100)

# RETURNS:

The result of evaluating the corresponding expression. Any variables that cannot
be instantiated into values will result in an Undefvar error

# EXAMPLE:

```jldoctest
julia>  replacer(parse("t1*10+sqrt(t2))", Dict("t"=>-3, "t1"=>5, "t2"=>100))

15

```

"""
function replacer(P, mypars)   # run through an expression tree, replacing known symbols with their values, then evaluate
    mypars = symbol_key_ize(mypars)
    ks = collect(keys(mypars))

    if typeof(P)<:Symbol
        idx = find(ks .== P)
        if length(idx)>0
            P = mypars[ks[idx[1]]]
        end
        return P
    end
    for i=1:length(P.args)
        if typeof(P.args[i])<:Expr || typeof(P.args[i])<:Symbol
            P.args[i] = replacer(P.args[i], mypars)
        end
    end
    # @printf("P = \n"); print(P)
    return eval(P)
end


"""
function print_vector(vec)

Takes a vector and uses @printf to put it on the screen with [%.3f, %.3f] format. 

If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.
"""
function print_vector(vec)
    print_vector(stdout, vec)
end


"""
function print_vector(stream::IO, vec)

Takes a vector and uses @sprintf to put it on stream IO with [%.3f, %.3f] format. 

If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.
"""
function print_vector(stream::IO, vec)

    if typeof(vec)==Symbol
        mystr = string(vec)
        @printf(stream, "%s = ", mystr);
        print_vector(stream, eval(vec))
        @printf(stream, "\n");
        return
    end
    
    @printf stream "["
    for p in [1:length(vec);]
        @printf(stream, "%.3f", vec[p])
        if p < length(vec) @printf(stream, ", "); end
    end
    @printf(stream, "]")
end


"""
function print_vector_g(vec)

Takes a vector and uses @printf to put it on the screen with [%g, %g] format. 

If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.
"""
function print_vector_g(vec)
    print_vector_g(stdout, vec)
end


"""
function print_vector_g(stream::IO, vec)

Takes a vector and uses @printf to put it on stream with [%g, %g] format. 

If passed a symbol (which must evaluate to a vector), then prints the string for that symbol,
an equals sign, the vector, and ends by adding a carriage return \n.
"""
function print_vector_g(stream::IO, vec)

    if typeof(vec)==Symbol
        mystr = string(vec)
        @printf(stream, "%s = ", mystr);
        print_vector_g(stream, eval(vec))
        @printf(stream, "\n");
        return
    end
    
    @printf stream "["
    for p in [1:length(vec);]
        @printf(stream, "%g", vec[p])
        if p < length(vec) @printf(stream, ", "); end
    end
    @printf(stream, "]")
end


"""
y = two_level_copy(x)

Like copy(x), but can go down a level. Can handle both Arrays and Dicts, otherwise gets confused.

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

"""
function two_level_copy(x)
    if typeof(x)<:Array
        y = copy(x)
        for elem in x
            if typeof(elem)<:Tuple; y[i]=elem; 
            else y[i] = copy(elem) end;
        end
    elseif typeof(x)<:Dict
        y = copy(x)
        allkeys = keys(x)
        for i in allkeys
            if typeof(x[i])<:Tuple; y[i]=x[i]; 
            else y[i] = copy(x[i]) end;
        end
    else
        error(@sprintf("two_level_copy: Don't know how to handle type %s\n", typeof(x)))
    end
    return y
end




"""
new_fname = next_file(fbasename, ndigits)

Returns a numbered and presumably unused filename starting with the string fbasename, followed by an integer
digit. The returned integer will be one higher than the number of existing filenames starting with fbasename,
and will be written with ndigits numbers, using leading zeros if necessary.

# EXAMPLE:

If there are already 8 files starting with "Mydir/model" then

> next_file("Mydir/model_", 4)

"Mydir/model_0009"
"""
function next_file(fbasename, ndigits)
    mydir  = dirname(fbasename)
    myfile = basename(fbasename)
    if length(mydir)>0
        fnames = readdir(mydir)
    else
        fnames = readdir()
    end
    matched_filenames = Array{Bool}(length(fnames))
    for fname in fnames
        matched_filenames[i] = ismatch(Regex(@sprintf("^%s", myfile)), fname)
    end
    
    mynum = length(find(matched_filenames))+1
    myname = @sprintf("%d", mynum)
    while length(myname)<ndigits
        myname = "0" * myname
    end

    if length(mydir)>0
        return mydir * "/" * myfile * myname
    else
        return myfile * myname
    end
end


"""
    fstring = num2fixed_string(n, ndigits)

Returns a string version of a positive integer, with
however many leading zeros are necessary to have
ndigits characters.

"""
function num2fixed_string(n, ndigits)
    if ndigits<=0
        error("ndigits must be bigger than zero")
    end
    
    if n<0
        error("n must be positive")
    end
    
    myname = @sprintf("%d", n)
    while length(myname)<ndigits
        myname = "0"*myname
    end
    
    return myname
end


"""
ad = ascii_key_ize(d)

Given a dictionary that has keys that can be converted to strings, returns a copy with all 
keys converted to strings
"""
function ascii_key_ize(d)
    ad = Dict()
    for k in keys(d)
        get!(ad, string(k), d[k])
    end
    return ad
end



"""
sd = symbol_key_ize(d)

Given a dictionary that has keys that can be converted to Symbols, returns a copy with all 
keys converted to Symbols
"""
function symbol_key_ize(d)
    sd = Dict()
    for k in keys(d)
        get!(sd, Symbol(k), d[k])
    end
    return sd
end


"""
vks = vectorize_dict(dictionary, ks)

Given a dictionary (in which) all keys are either strings or Symbols, and all values are Float64s),
and an array ks of keys into that dictionary, returns a Float64 array the same size as ks containing
the values. Each key is checked as either itself or the string version of itself or the Symbol version 
of itself.

Thus the following all return the same

a = Dict(:this=>33.4, "that"=>28.7)

vectorize_dict(a, ["this", "that"])
vectorize_dict(a, [:this, "that"])
vectorize_dict(a, [:this, :that])
"""
function vectorize_dict(dictionary, ks)
    output = Array{Float64}(size(ks))
    for key in ks
        if haskey(dictionary, key)
            output[i] = dictionary[key]
        elseif typeof(key)<:Symbol && haskey(dictionary, string(key))
            output[i] = dictionary[string(key)]
        elseif typeof(key)<:String && haskey(dictionary, Symbol(key))
            output[i] = dictionary[Symbol(key)]
        else
            print("Troublesome key: "); print(key); print("\n")
            error("Found neither key nor string(key) nor Symbol(key) in the dictionary")
        end
    end
    return output
end