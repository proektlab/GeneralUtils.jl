using GeneralUtils
using Base.Test

# write your own tests here
# @test 1 == 2

println(num2fixed_string(32, 4))

println(print_vector_g([1, 2, pi]))

# println(next_file("FarmFields/farm_E_", 4))

# @test num2fixed_string(32, 4) == ""0032""

# @test print_vector_g([1, 2, pi]) == "[1, 2, 3.14159]"

# @test next_file("FarmFields/farm_E_", 4) == "FarmFields/farm_E_0141"

#  EXAMPLE OF INSTALL_NEAREST_POINT_CALLBACK()

pygui(true); figure(1); clf()

function mycallback(xy, r, h, ax, udata)
    @printf("(%.3f,%.3f), r=%3f ", xy[1], xy[2], r);
    print(h)
    print(ax)
    print("\n")
    print(udata)
    print("\n")    
end

BP = install_nearest_point_callback(figure(1), mycallback, user_data=["my" "vector" "of" "strings"])
plot([2,2])

# Ok, now go ahead and click!


# Now test storing some data directly in the BP's user data field:

type histo_data
    names::Array{String}
    values::Array{Float64}
    axisHandles::Array{PyCall.PyObject}
    LineHandles::Array{PyCall.PyObject}
    files::Array{String} 
end

HD = histo_data(["this", "that"], [20 30 ; 41.1 23.2], [gca()], [], [])

BP[:set_userdata](HD)

HD2 = BP[:get_userdata]()

#  EXAMPLE OF RADIO BUTTONS


pygui(true); figure(1); clf();
ax = gca()
function rad_callback(label)
    @printf("%s\n", label);
end

rad = kbMonitorModule.radio_buttons(ax, ("Plot trials", "Don't plot trials", "Something else"), rad_callback)

@printf("Current value selected is %s\n", rad[:value_selected])


#  EXAMPLE OF TEXT BUTTON


pygui(true); figure(1); clf();
ax = gca()
function tbox_callback(str)
    @printf("%s\n", str);
end

tbox = kbMonitorModule.text_box(ax, "Something", "23", user_callback=tbox_callback)


pygui(true)
figure(1)

# x, y, w, h = get_current_fig_position()
set_current_fig_position(1300, 250, 600, 700)

capture_current_figure_configuration()

# @test num2fixed_string(32, 4) == "0032"
# @test num2fixed_string(32, 4) == "0032"


