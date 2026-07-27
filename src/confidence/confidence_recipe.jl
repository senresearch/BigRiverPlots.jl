################### 
# CONFIDENCE PLOT #
###################


"""
	Recipe for Confidence plots plots.
"""

@userplot ConfidencePlot

@recipe function f(h::ConfidencePlot) 
    # check types of the input arguments
    if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
        !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
        error("Confidence Plots should be given three vectors.  Got: $(typeof(h.args))")
    end
    # Note: if confidence or interval not symmetric, then ε (3rd argument) should be a 
    # vector of tuple.
    # collect(zip(vCI1, vCI2));

    #############
	# Arguments #
	#############
    x, y, ε = h.args
    x_vline = [0]
    v_significant = (x+ε).*(x-ε) .> 0

    #####################
	# Marker attributes #
	#####################
    # set a default value for an attribute with `-->`
    # xlabel --> "Effect size"
    # ylabel --> "Variables"
    markershape --> :rect

    ###################
	# Axis attributes #
	###################
    # set up the subplots
    legend := false
    link := :both
    # framestyle := [:none :axes :none]
    # yaxis := false 
    y_foreground_color_axis := :white
    y_foreground_color_border := :white
    ylims := (-0.5,length(y)+0.25)
    grid := false
    
    guidefontsize --> 15
	fontfamily --> "Helvetica"

    ########################
    # Main confidence plot #
    ########################
    @series begin
        seriestype := :scatter
        xerror := ε
        linecolor := :black#nothing
        # get the seriescolor passed by the user
        c = get(plotattributes, :seriescolor, :auto)
        # highlight big errors, otherwise use the user-defined color
        # seriescolors --> ifelse.(v_significant, :blue, :lightblue)
        zcolor --> v_significant
        color -->  :Blues_3
          
        x, y
    end
    
    ##############################
    # Vertical red line at x = 0 #
    ##############################
    @series begin
        seriestype := :vline
        linecolor := :red
        primary := false
        alpha := 0.5
        x_vline
    end
end 
