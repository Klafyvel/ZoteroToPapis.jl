using ZoteroToPapis
using Test
using Aqua

@testset "ZoteroToPapis.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ZoteroToPapis)
    end
    # Write your tests here.
end
