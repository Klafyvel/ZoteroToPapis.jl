@testset "biblatex_doctor.jl" begin
    @testset "BIBLATEX_REQUIRED_FIELDS is complete" begin
        @test values(ZoteroToPapis.ZOTERO_TO_BIBLATEX_TYPES) ⊂ keys(ZoteroToPapis.BIBLATEX_REQUIRED_FIELDS)
    end
    @testset "BIBLATEX_REPLACEMENT_FIELDS is complete" begin
        required_fields = Set(reduce(vcat, reduce(vcat, values(ZoteroToPapis.BIBLATEX_REQUIRED_FIELDS))))
        @test required_fields ⊂ keys(ZoteroToPapis.BIBLATEX_REPLACEMENT_FIELDS)
    end
    # Write your tests here.
end
