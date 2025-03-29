using Test
using Moma

@testset "Moma.jl" begin
    @test example_function(2) == 4
    @test example_function(3.5) == 7.0
end 