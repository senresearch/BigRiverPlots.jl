########
# Data #
########

x = randn(7)
y = ["NA", "DO", "ZC", "UX", "MK", "XQ", "YN"]

ε = rand(Uniform(0.1, 2), 7)

##########################
# Test Confidence Recipe #
##########################

plot_obj = confidenceplot(x, y, ε);

println("Confidence plot attributes :x test: ", @test plot_obj[1][2].plotattributes[:x] == x);
println("Confidence plot attributes :y test: ", @test plot_obj[1][2].plotattributes[:y] == collect(0.5:1:6.5));
println("Confidence plot attributes :ε test: ", @test plot_obj[1][2].plotattributes[:xerror] == ε);

