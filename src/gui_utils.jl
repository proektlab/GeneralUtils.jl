using PyCall
using PyPlot

"""
safe_axes(axh; further_params...)

If you're going to make axh the current axes, this function
first makes axh's figure the current figure. Some Julias
break without that.

Any optional keyword-value arguments are passed on to axes()
"""

function safe_axes(axh; further_params...)
    figure(axh[:figure][:number])
    axes(axh; Dict(further_params)...)
end


"""
    ax = axisWidthChange(factor; lock="c", ax=nothing)
"""
function axisWidthChange(factor; lock="c", ax=nothing)
    if isnothing(ax); ax=gca(); end
    x, y, w, h = ax[:get_position]()[:bounds]
    
    if lock=="l"; 
    elseif lock=="c" || lock=="m"; x = x + w*(1-factor)/2; 
    elseif lock=="r"; x = x + w*(1-factor);
    else error("I don't know lock type ", lock)
    end
    
    w = w*factor;
    ax[:set_position]([x, y, w, h])
    
    return ax
end
   

"""
ax = axisHeightChange(factor; lock="c", ax=nothing)
"""
function axisHeightChange(factor; lock="c", ax=nothing)
    if isnothing(ax); ax=gca(); end
    x, y, w, h = ax[:get_position]()[:bounds]
    
    if lock=="b"; 
    elseif lock=="c" || lock=="m"; y = y + h*(1-factor)/2; 
    elseif lock=="t"; y = y + h*(1-factor);
    else error("I don't know lock type ", lock)
    end
    
    h = h*factor;
    ax[:set_position]([x, y, w, h])
    
    return ax
end


"""
   ax = axisMove(xd, yd; ax=nothing)
"""
function axisMove(xd, yd; ax=nothing)
    if isnothing(ax); ax=gca(); end
    x, y, w, h = ax[:get_position]()[:bounds]

    x += xd
    y += yd
    
    ax[:set_position]([x, y, w, h])
    return ax
end


"""
[] = remove_xtick_labels(ax=NaN)

Given an axis object, or an array of axes objects, replaces each xtick label string with the empty string "". 

If no axis is passed, uses gca() to work with the current axis.


"""
function remove_xtick_labels(ax=nothing)

    if isnothing(ax)
        ax = gca()
    end
    
    if typeof(ax) <: Array
        for a in ax
            remove_xtick_labels(a)
        end
        return
    end
    
    nlabels = length(ax[:xaxis][:get_ticklabels]())

    newlabels = Array{String,1}(nlabels)
    for i=1:length(newlabels);
        newlabels[i] = ""
    end
    
    ax[:xaxis][:set_ticklabels](newlabels)
    return
end



"""
[] = remove_ytick_labels(ax=NaN)

Given an axis object, or an array of axes objects, replaces each ytick label string with the empty string "". 

If no axis is passed, uses gca() to work with the current axis.


"""
function remove_ytick_labels(ax=nothing)

    if isnothing(ax)
        ax = gca()
    end
    
    if typeof(ax) <: Array
        for a in ax
            remove_ytick_labels(ax)
        end
        return
    end
    
    nlabels = length(ax[:yaxis][:get_ticklabels]())

    newlabels = Array{String,1}(nlabels)
    for i=1:length(newlabels);
        newlabels[i] = ""
    end
    
    ax[:yaxis][:set_ticklabels](newlabels)
    return
end


# If the Python path does not already have the local directory in it
if PyVector(pyimport("sys")["path"])[1] != ""
    # Then the following line is PyCall-ese for "add the current directory to the Python path"
    unshift!(PyVector(pyimport("sys")["path"]), "")
end
# We use Python to enable callbacks from the figures:
@pyimport kbMonitorModule



__permanent_BP_store = []   # The user doesn't need to worry about this variable, it is here to ensure that 
                            # kbMonitorModule.kb_monitor objects created inside the install_nearest_callback() 
                            # function do not get deleted upon exit of that function

"""
BP = install_nearest_point_callback(fighandle, user_callback; user_data=nothing)

This function makes the figure indicated by fighandle interactive: any time the mouse is clicked 
while pointing inside any of the axes of the figure, the function user_callback() will be called,
and will be passed parameters that indicate which of the points drawn in the axis is the one
closest to the clicked point (closest in Euclidean data units).

**WARNING** because this runs through PyCall, any errors in your user_callback function will sadly
not show up.  The function will simply fail to work. So be careful and debug with lots of print statements.


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


# EXAMPLE:

pygui(true)

```jldoctest
function mycallback(xy, r, h, ax)
    @printf("(%.3f,%.3f), r=%3f ", xy[1], xy[2], r);
    print(h)
    print(ax)
    print("\n")
end

BP = install_nearest_point_callback(figure(2), mycallback)
plot([2,2])
```

"""
function install_nearest_point_callback(fighandle, user_callback; user_data=nothing)
    
    function point_nearest_to_click(BP)
        bpe = BP[:buttonlist]()
        # Remove any leading clicks that weren't inside an axis:
        while length(bpe)>0 && ((isnothing(bpe[1][1])) || (bpe[1][1]==Void))
            bpe = bpe[2:end]
        end
        if length(bpe)>0
            ax = BP[:buttonlist]()[1][1]   # the axis we're working with
            x  = BP[:buttonlist]()[1][2]   # the x of the clicked point
            y  = BP[:buttonlist]()[1][3]   # the y of the clicked point

            ch = ax[:get_children]()       # all children of the axis

            idx    = nothing    # this'll be the index of the data point closest to the clickpoint
            minJ   = nothing    # the smallest squared distance between data point and clickpoint found so far
            handle = nothing    # the matplotlib handle of the line object for which the closes data point is found
            dx     = nothing    # closest data point x position
            dy     = nothing    # closest data point y position

            # Look over all children of the axis:
            for child in ch
                # But only consider line objects:
                if contains(pystring(child), "lines.Line2D")
                    D = child[:get_data]()    # D will be a Tuple with xdata, ydata vectors
                elseif contains(pystring(child), "PathCollection")
                    D = child[:get_offsets]()    # D will be a matrix with xdata, ydata columns
                    D = (D[:,1], D[:,2])         # Turn it into a Tuple like for Line2D objects
                end
                if contains(pystring(child), "lines.Line2D") || contains(pystring(child), "PathCollection")
                    J = (D[1] - x).^2 + (D[2] - y).^2
                    ix = indmin(J)
                    if isnothing(idx) || J[ix] < minJ   # if we did not yet have a minimum candidate or this one is better
                        idx = ix; minJ = J[ix]; handle = child   # store our candidate
                        dx = D[1][ix]; dy = D[2][ix]
                    end
                end
            end

            # @printf("install: Am about to call the user callback\n")
            if !isnothing(minJ)
                if isnothing(BP[:get_userdata]())
                    user_callback((dx,dy), sqrt(minJ), handle, ax)
                else
                    user_callback((dx,dy), sqrt(minJ), handle, ax, BP[:get_userdata]())
                end
            end
            # @printf("install: Just returned from the user callback\n")

            # After dealing with all the buttonclick callbacks and so on, bring focus back to the figure that was clicked:
            figure(ax[:figure][:number])
        end

        # We've dealt with the buttonclick, clear the buttonlist
        # @printf("Am about to clear the button list on button "); print(BP); print("\n")
        BP[:clear_buttonlist]()
    end

    BP = kbMonitorModule.kb_monitor(fighandle, callback = point_nearest_to_click, userData=user_data)
    global __permanent_BP_store = [__permanent_BP_store ; BP]

    return BP
end


"""
    userdata = install_callback_reporter(xy, r, axhandle, dothandle, userdata)

Useful as a debugging tool for `install_nearest_point_callback()`: can be used
with that function as a callback; when called, simply prints out its parameters.
Returns userdata, does not print it.

"""
function install_callback_reporter(xy, r, linehandle, axhandle, userdata=nothing)
    @printf("xy=(%g,%g), r=%g\n", xy[1], xy[2], r)
    print("Line Handle:\n"); print(linehandle); print("\n")
    print("Axis Handle:\n"); print(axhandle); print("\n")
    # print("User Data:\n"); print(userdata); print("\n")
    
    return userdata
end



"""
    remove_BP(BP::PyCall.PyObject)

Disconnects a kbMonitorModule.kb_monitor object from its figure
"""
function remove_BP(BP::PyCall.PyObject)
    if contains(pystring(BP), "kbMonitorModule.kb_monitor")
        BP[:__del__]()
        
        i = find(__permanent_BP_store .== BP)
        if length(i)>0;  
            i = i[1]; 
            global __permanent_BP_store = __permanent_BP_store[[1:(i-1) ; (i+1):end]]
        end
    end
end


"""
    remove_all_BPs()

    Disconnects *all* kbMonitorModule.kb_monitor objects from their figures.
"""
function remove_all_BPs()
    for BP in __permanent_BP_store
        BP[:__del__]()
    end
    
    global __permanent_BP_store = []
end

"""

    (x, y, w, h) = get_current_fig_position()   

Works only when pygui(true) and when the back end is QT. Has been tested only with PyPlot.
"""
function get_current_fig_position()    
    # if !contains(pystring(plt[:get_current_fig_manager]()), "FigureManagerQT")
    try
        if contains(pystring(plt[:get_current_fig_manager]()), "Tk") 
            g = split(plt[:get_current_fig_manager]()[:window][:geometry](), ['x', '+'])
            w = parse(Int64, g[1])
            h = parse(Int64, g[2])
            x = parse(Int64, g[3])
            y = parse(Int64, g[4])
        elseif contains(pystring(plt[:get_current_fig_manager]()), "QT")
            x = plt[:get_current_fig_manager]()[:window][:pos]()[:x]()
            y = plt[:get_current_fig_manager]()[:window][:pos]()[:y]()
            w = plt[:get_current_fig_manager]()[:window][:width]()
            h = plt[:get_current_fig_manager]()[:window][:height]()
        else
            error("Only know how to work with matplotlib graphics backends that are either Tk or QT")
        end
            
        return (x, y, w, h)
    catch
        error("Failed to get current figure position. Is pygui(false) or are you using a back end other than QT or Tk?")
    end
end

"""

    set_current_fig_position(x, y, w, h)   

Works only when pygui(true) and when the back end is QT. Has been tested only with PyPlot.
"""
function set_current_fig_position(x, y, w, h)    
    # if !contains(pystring(plt[:get_current_fig_manager]()), "FigureManagerQT")
    try
        if contains(pystring(plt[:get_current_fig_manager]()), "Tk") 
            plt[:get_current_fig_manager]()[:window][:geometry](@sprintf("%dx%d+%d+%d", w, h, x, y))
        elseif contains(pystring(plt[:get_current_fig_manager]()), "QT")
            plt[:get_current_fig_manager]()[:window][:setGeometry](x, y, w, h)
        else
            error("Only know how to work with matplotlib graphics backends that are either Tk or QT")
        end
    catch
        error("Failed to set current figure position. Is pygui(false) or are you using a back end other than QT?")
    end
end


"""
    C = capture_current_figure_configuration()

Collects the positions of all current figures and 
prints out to the screen code, that can be copy-pasted,
that would reproduce that positioning configuration.

# PARAMETERS:

None

# RETURNS:

- C    A matrix that is nfigures-by-5 in size. You probably
    don't want this, you probably want the text printed to
    the screen, but here just in case.  Each row will have,
    in order: figure number, x, y, width, height
"""
function capture_current_figure_configuration()
    @printf("The following code will reproduce your current figure placement:\n\n")
    C = []
    for f in sort(plt[:get_fignums]())
        figure(f)
        x, y, w, h = get_current_fig_position()
        @printf("figure(%d); set_current_fig_position(%d, %d, %d, %d)   # x, y, width, height\n", 
            f, x, y, w, h)
        C = [C ; [f x y w h]]
    end
    return C
end


