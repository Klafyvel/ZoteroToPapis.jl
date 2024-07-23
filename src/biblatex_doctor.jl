const _AUTHOR_TITLE_DATE_REQUIREMENTS = ["author", "title", "date"]

"""
Required fields for each of the BibLaTeX type we can generate (see also 
[`ZOTERO_TO_BIBLATEX_TYPES`](@ref)). The required fields for each type can be 
found in the [BibLaTeX manual](https://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf).
"""
const BIBLATEX_REQUIRED_FIELDS = Dict{String, Vector{Union{String, Vector{String}}}}(
    "article" => ["author", "title", "journaltitle", "date"],
    "artwork" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "audio" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "book" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "dataset" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "inbook" => ["author", "title", "booktitle", "date"],
    "inproceedings" => ["author", "title", "booktitle", "date"],
    "inreference" => ["author", "title", "editor", "booktitle", "date"],
    "jurisdiction" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "legal" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "legislation" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "letter" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "misc" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "movie" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "online" => [["author", "editor"], "title", "date", ["doi", "eprint", "url"]],
    "patent" => ["author", "title", "number", "date"],
    "report" => ["author", "title", "type", "institution", "date"],
    "software" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "standard" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "thesis" => ["author", "title", "type", "institution", "date"],
    "unpublished" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
    "video" => _AUTHOR_TITLE_DATE_REQUIREMENTS,
)

"""
Keys to look for a replacement for required fields.
"""
const BIBLATEX_REPLACEMENT_FIELDS = Dict{String, Vector{String}}(
    "author" => [],
    "booktitle" => ["booktitleaddon", "title", "origtitle", "shortitle", "titleaddon", "booksubtitle", "subtitle"],
    "date" => ["year"],
    "doi" => [],
    "editor" => [],
    "eprint" => ["doi", "url"],
    "institution" => ["organization"],
    "journaltitle" => [],
    "number" => [],
    "title" => ["title", "origtitle", "shortitle", "titleaddon", "subtitle"],
    "type" => [],
    "url" => [],
)

"""
A type that knows how to fill a missing required field.
"""
abstract type AbstractSubstituter end
"""
$(SIGNATURES)

Replace a missing field. Should return the new value of the field or nothing if 
no alternative were found.
"""
function replace_missing_field end

function replace_missing_field(fields::Vector, entry)
    result = nothing
    for field in fields
        result = replace_missing_field(field, entry)
        if !isnothing(result)
            break
        end
    end
    result
end
function replace_missing_field(field, entry)
    static_replacement = replace_missing_field(StaticSubstituter(), field, entry)
    result = nothing
    if !isnothing(static_replacement)
        entry.fields[field] = static_replacement
        result = static_replacement
    elseif haskey(BIBLATEX_DYNAMIC_SUBSTITUTERS, field)
        dynamic_replacement = replace_missing_field(BIBLATEX_DYNAMIC_SUBSTITUTERS[field], field, entry)
        if !isnothing(dynamic_replacement)
            entry.fields[field] = dynamic_replacement
            result = dynamic_replacement
        end
    end
    result
end

"""
$(TYPEDEF)

Tries to replace a missing required field with the value of another field.

$(TYPEDFIELDS)
"""
struct StaticSubstituter <: AbstractSubstituter end

function replace_missing_field(::StaticSubstituter, fieldname::String, entry::BibLaTeXEntry)
    for possible_substitution in BIBLATEX_REPLACEMENT_FIELDS[fieldname]
        if possible_substitution ∈ keys(entry.fields)
            return entry.fields[possible_substitution]
        end
    end
    return nothing
end

import FunctionWrappers: FunctionWrapper
struct DynamicSubstituter <: AbstractSubstituter
    fun::FunctionWrapper{Union{String, Nothing}, Tuple{String, BibLaTeXEntry}}
end
replace_missing_field(s::DynamicSubstituter, fieldname, entry) = s.fun(fieldname, entry)

format_author_list(authors) = join(authors, " and ")

const BIBLATEX_DYNAMIC_SUBSTITUTERS = Dict(
    "url" => DynamicSubstituter(
        (fieldname, entry) -> if haskey(entry.fields, "doi")
            "https://doi.org/$(entry.fields["doi"])"
        else
            nothing
        end,
    ),
    "author" => DynamicSubstituter(
        (fieldname, entry) -> if !isempty(entry.authors)
            format_author_list(entry.authors)
        else
            nothing
        end,
    ),
)

isa_good_field_value(v::AbstractVecOrMat) = !isempty(v)
isa_good_field_value(::Nothing) = false
isa_good_field_value(s::String) = !isempty(s)
isa_good_field_value(_) = true

is_field_missing(fields::Vector, entry) = all([is_field_missing(field, entry) for field in fields])
is_field_missing(field, entry) = !haskey(entry.fields, field) || !isa_good_field_value(entry.fields[field])

function substitute_missing_required!(entry)
    required_fields = BIBLATEX_REQUIRED_FIELDS[entry.type]
    for field in required_fields
        if is_field_missing(field, entry)
            replace_missing_field(field, entry)
        end
    end
end

function missing_required(entry)
    required_fields = BIBLATEX_REQUIRED_FIELDS[entry.type]
    actually_defined_fields = keys(
        filter(entry.fields) do (k, v)
            isa_good_field_value(v)
        end,
    )
    setdiff(required_fields, actually_defined_fields)
end
