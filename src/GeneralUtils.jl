__precompile__()

"""
A package for fitting data from auditory evidence accumulation task (Poisson clicks task) 
to evidence accumulation model.
"""
module GeneralUtils

# 3rd party
# using PyCall
# using PyPlot
# using ForwardDiff

export 
    
# non-GUI utilities
    append_to_file,
    replacer,
    print_vector,
    print_vector_g,
    two_level_copy,
    next_file,
    num2fixed_string,
    ascii_key_ize,
    symbol_key_ize,
    vectorize_dict,

# GUI utilities
    safe_axes,
    axisWidthChange,
    axisHeightChange,
    axisMove,
    remove_xtick_labels,
    remove_ytick_labels,
    install_nearest_point_callback,
    install_callback_reporter,
    remove_BP,
    remove_all_BPs,
    get_current_fig_position,
    set_current_fig_position,
    capture_current_figure_configuration,

# Gradient utilities
    FDversion,
    make_dict,
    to_args_format,
    ForwardDiffZeros,
    get_eltype,
    get_value,
    vgh,
    keyword_vgh

include("non_gui_utils.jl")
# include("gui_utils.jl")
include("gradient_utils.jl")

end # module
