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

# pygui(true); figure(1); clf()

# function mycallback(xy, r, h, ax, udata)
#     @printf("(%.3f,%.3f), r=%3f ", xy[1], xy[2], r);
#     print(h)
#     print(ax)
#     print("\n")
#     print(udata)
#     print("\n")    
# end

# BP = install_nearest_point_callback(figure(1), mycallback, user_data=["my" "vector" "of" "strings"])
# plot([2,2])

# # Ok, now go ahead and click!


# # Now test storing some data directly in the BP's user data field:

# type histo_data
#     names::Array{String}
#     values::Array{Float64}
#     axisHandles::Array{PyCall.PyObject}
#     LineHandles::Array{PyCall.PyObject}
#     files::Array{String} 
# end

# HD = histo_data(["this", "that"], [20 30 ; 41.1 23.2], [gca()], [], [])

# BP[:set_userdata](HD)

# HD2 = BP[:get_userdata]()

# #  EXAMPLE OF RADIO BUTTONS


# pygui(true); figure(1); clf();
# ax = gca()
# function rad_callback(label)
#     @printf("%s\n", label);
# end

# rad = kbMonitorModule.radio_buttons(ax, ("Plot trials", "Don't plot trials", "Something else"), rad_callback)

# @printf("Current value selected is %s\n", rad[:value_selected])


# #  EXAMPLE OF TEXT BUTTON


# pygui(true); figure(1); clf();
# ax = gca()
# function tbox_callback(str)
#     @printf("%s\n", str);
# end

# tbox = kbMonitorModule.text_box(ax, "Something", "23", user_callback=tbox_callback)


# pygui(true)
# figure(1)

# # x, y, w, h = get_current_fig_position()
# set_current_fig_position(1300, 250, 600, 700)

# capture_current_figure_configuration()

if FDversion() >= 0.6
    a = [100, 200]
    b = 34.5
    c = Dict(:gu=>ForwardDiff.Dual{Float64}(1,0))
    get_eltype((a,b,c))
end

function tester(;a=1, b=2, c=3, d=4)
    @printf("a=%g\n", a)
    @printf("b=%g\n", b)
    @printf("c=%g\n", c)
    @printf("d=%g\n", d)
end

defaults = Dict(:a=>10, :b=>20, :c=>30, :d=>40)

@printf("tester():\n")
tester()
@printf("\n")

@printf("tester(;defaults...):\n")
tester(;defaults...)
@printf("\n")

@printf("make_dict([\"a\", \"c\"], [-5, -6]):\n")
print(make_dict(["a", "c"], [-5, -6]))
@printf("\n\n")

@printf("tester(;make_dict([\"a\", \"c\"], [-5, -6])...) changes a and c but doesn't use what is in defaults:\n")
tester(;make_dict(["a", "c"], [-5, -6])...)
@printf("\n")

@printf("tester(;make_dict([\"a\", \"c\"], [-5, -6], defaults)...) changes a and c and *does* use what is in defaults:\n")
tester(;make_dict(["a", "c"], [-5, -6], defaults)...)
@printf("\n")

if FDversion() < 0.6
    # --------------------------------------------------------------
    #
    #         FOR FORWARDDIFF < 0.6   (Julia 0.5.2)
    #
    # --------------------------------------------------------------

    function tester(; a=1, b=2, c=3, nderivs=0, difforder=0)
        # we declare a matrix; when declaring it, we want to make sure that it is a ForwardDiff Dual if we
        # are going to assign it variables that we will differentiate, otherwise we can't do the assignment.
        #
        # This would cause an error if we try to differentiate:
        # y = zeros(1, 3)  
        # 
        # So instead we do this:
        y = ForwardDiffZeros(1, 3, nderivs=nderivs, difforder=difforder)

        y[1] = a
        y[2] = b
        y[3] = c

        return y[1]^3 + y[2]^2 + sqrt(y[3])
    end
    
    
else

    # --------------------------------------------------------------
    #
    #         FOR FORWARDDIFF >= 0.6   (Julia 0.6 and onwards)
    #
    # --------------------------------------------------------------

    function tester(; a=1, b=2, c=3)
        # we declare a matrix; when declaring it, we want to make sure that it is a ForwardDiff Dual if we
        # are going to assign it variables that we will differentiate, otherwise we can't do the assignment.
        #
        # This would cause an error if we try to differentiate:
        # y = zeros(1, 3)  
        # 
        # So instead we do this:
        y = zeros(get_eltype((a,b,c)), 1, 3)
        # Notice the call to get_eltype-- we don't know whether we'll be differentiating w.r.t. a, b, or c,
        # so get_eltype will check them all (and return Float64 if no differentiation is happening)

        y[1] = a
        y[2] = b
        y[3] = c

        return y[1]^3 + y[2]^2 + sqrt(y[3])
    end
        
end


# Now we can do our differentiation
args = ["a", "c"]; 
pars = [3.1, 1.1]; 
if FDversion() < 0.6
    func = x -> tester(;nderivs=length(x), difforder=1, make_dict(args, x)...)

    grad = ForwardDiff.gradient(func, pars)
else
    func = x -> tester(;make_dict(args, x)...)
end

grad = ForwardDiff.gradient(func, pars)
@printf("This is the gradient: "); print_vector_g(grad); print("\n")

if FDversion() < 0.6
    func = x -> tester(;nderivs=length(x), difforder=2, make_dict(args, x)...)
end
hess = ForwardDiff.hessian(func, pars)
@printf("This is the hessian[:] : "); print_vector_g(hess[:]); print("\n")



function tester(x::Vector)

    return sum(x.*x)
end

value, grad, hess = vgh(tester, [10, 3.1])

@printf("Using vgh()\n")
@printf("value=%g, grad=", value); print(grad[:]); @printf(", hess[:]="); print(hess[:]); print("\n");

# -------------

if FDversion() < 0.6
    function tester2(;a=10, b=20, c=30, d=[2, 3], nderivs=0, difforder=0)
        M = ForwardDiffZeros(3, 3; nderivs=nderivs, difforder=difforder)
        M[1,1] = a^2*3
        M[1,2:3] = d
        M[2,2] = b*20
        M[3,3] = a*sqrt(c)*1.1
        return sqrt(sum(M[:].*M[:]))
    end
else
    function tester2(;a=10, b=20, c=30, d=[2, 3])
        M = zeros(get_eltype((a,b,c)), 3, 3)
        M[1,1] = a^2*10
        M[2,2] = b*20
        M[3,3] = a*sqrt(c)*30.1
        return trace(M)
    end
end
    
print(tester2())

value, grad, hess = keyword_vgh((;params...) -> tester2(;params...), ["a", "c", ["d" 2]], [10, 3.1, 1.5, 2.2])

@printf("\n\n-------\n\nDifferent example using keyword_vgh()\n")
@printf("value=%g, grad=", value); print(grad[:]); @printf(", hess[:]="); print(hess[:]); print("\n");









# @test num2fixed_string(32, 4) == "0032"
# @test num2fixed_string(32, 4) == "0032"


