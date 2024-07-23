"""
$(TYPEDEF)

Represents a file on disk.

$(TYPEDFIELDS)
"""
struct File{T}
    "File name"
    filename::String
    "File path"
    filepath::String
    "Is this file stored externally?"
    isexternal::Bool
end
File(mime, filename, filepath, isexternal) = File{MIME(mime)}(filename, filepath, isexternal)

abstract type Entry end

"""
All the item types that we expect from Zotero. Thanks a lot to
https://tug.ctan.org/info/biblatex-cheatsheet/biblatex-cheatsheet.pdf and 
https://www.zotero.org/support/kb/item_types_and_fields. For some missing parts
I had to check https://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf.
"""
const ZOTERO_TO_BIBLATEX_TYPES = Dict(
    "artwork" => "artwork",
    "audioRecording" => "audio",
    "bill" => "legislation",
    "blogPost" => "online",
    "book" => "book",
    "bookSection" => "inbook",
    "case" => "legal",
    "computerProgram" => "software",
    "conferencePaper" => "inproceedings",
    "dictionaryEntry" => "inreference",
    "document" => "misc",
    "email" => "letter",
    "encyclopediaArticle" => "inreference",
    "film" => "movie",
    "forumPost" => "online",
    "hearing" => "jurisdiction",
    "instantMessage" => "online",
    "interview" => "misc",
    "journalArticle" => "article",
    "letter" => "letter",
    "magazineArticle" => "article",
    "manuscript" => "unpublished",
    "map" => "misc",
    "newspaperArticle" => "article",
    "patent" => "patent",
    "podcast" => "online",
    "presentation" => "misc",
    "radioBroadcast" => "audio",
    "report" => "report",
    "statute" => "legislation",
    "thesis" => "thesis",
    "tvBroadcast" => "video",
    "videoRecording" => "video",
    "webpage" => "online",
    "preprint" => "report",
    "dataset" => "dataset",
    "standard" => "standard",
)


"""
Mapping all Zotero fields to BibLaTeX fields. Thanks a lot to
https://tug.ctan.org/info/biblatex-cheatsheet/biblatex-cheatsheet.pdf and 
https://www.zotero.org/support/kb/item_types_and_fields. Fields 
associated to `nothing` are reported in a specific `zotero-field` section.
"""
const ZOTERO_TO_BIBLATEX_FIELDS = Dict(
    "title" => "title",
    "abstractNote" => "abstract",
    "artworkMedium" => nothing,
    "medium" => nothing,
    "artworkSize" => nothing,
    "date" => "date",
    "language" => "language",
    "shortTitle" => "shortitle",
    "archive" => nothing,
    "archiveLocation" => nothing,
    "libraryCatalog" => "library",
    "callNumber" => "library",
    "url" => "url",
    "accessDate" => "urldate",
    "rights" => nothing,
    "extra" => nothing,
    "audioRecordingFormat" => nothing,
    "seriesTitle" => "series",
    "volume" => "volume",
    "numberOfVolumes" => "volumes",
    "place" => "location",
    "label" => "label",
    "publisher" => "publisher",
    "runningTime" => nothing,
    "ISBN" => "isbn",
    "billNumber" => nothing,
    "number" => "number",
    "code" => nothing,
    "codeVolume" => "part",
    "chapter" => "section",
    "codePages" => nothing,
    "pages" => "pages",
    "legislativeBody" => nothing,
    "session" => nothing,
    "history" => nothing,
    "blogTitle" => nothing,
    "publicationTitle" => "journaltitle",
    "websiteType" => nothing,
    "series" => "series",
    "seriesNumber" => "number",
    "edition" => "edition",
    "numPages" => "pagetotal",
    "bookTitle" => "booktitle",
    "caseName" => nothing,
    "court" => nothing,
    "dateDecided" => nothing,
    "docketNumber" => nothing,
    "reporter" => nothing,
    "reporterVolume" => nothing,
    "firstPage" => nothing,
    "versionNumber" => "version",
    "system" => nothing,
    "company" => nothing,
    "programmingLanguage" => nothing,
    "proceedingsTitle" => "eventtitle",
    "conferenceName" => "eventtitle",
    "DOI" => "doi",
    "dictionaryTitle" => "booktitle",
    "subject" => "title",
    "encyclopediaTitle" => "booktitle",
    "distributor" => nothing,
    "genre" => nothing,
    "videoRecordingFormat" => nothing,
    "forumTitle" => "title",
    "postType" => nothing,
    "committee" => nothing,
    "documentNumber" => "number",
    "interviewMedium" => nothing,
    "issue" => "number",
    "seriesText" => nothing,
    "journalAbbreviation" => "shortjournal",
    "ISSN" => "issn",
    "letterType" => nothing,
    "manuscriptType" => nothing,
    "mapType" => nothing,
    "scale" => nothing,
    "country" => nothing,
    "assignee" => nothing,
    "issuingAuthority" => nothing,
    "patentNumber" => "number",
    "filingDate" => "date",
    "applicationNumber" => "number",
    "priorityNumbers" => nothing,
    "issueDate" => "date",
    "references" => nothing,
    "legalStatus" => nothing,
    "episodeNumber" => "number",
    "audioFileType" => nothing,
    "presentationType" => nothing,
    "meetingName" => nothing,
    "programTitle" => "title",
    "network" => nothing,
    "reportNumber" => "number",
    "reportType" => nothing,
    "institution" => "institution",
    "nameOfAct" => nothing,
    "codeNumber" => "number",
    "publicLawNumber" => "number",
    "dateEnacted" => "date",
    "thesisType" => nothing,
    "university" => "institution",
    "studio" => "editor",
    "websiteTitle" => "title",
    "repository" => "url",
    "archiveID" => nothing,
    "authority" => "editor",
    "identifier" => nothing,
    "repositoryLocation" => "url",
    "format" => nothing,
    "status" => nothing,
    "organization" => "organization",
)

"""
$(TYPEDEF)

Represents a Zotero entry.

$(TYPEDFIELDS)
"""
struct ZoteroEntry <: Entry
    "Zotero item type. Must be one of the keys of [`ZOTERO_TO_BIBLATEX_TYPES`](@ref)."
    type::String
    "Citation key."
    citationkey::String
    "Authors."
    authors::Vector{String}
    "Fields that will be exported. The keys must be in [`ZOTERO_TO_BIBLATEX_FIELDS`](@ref)."
    fields::Dict{String, Any}
    "All the extra fields that BibLaTeX doesn't know."
    zotero_extra_fields::Dict{String, Any}
    "The files associated to a Zotero entry."
    files::Vector{File}
    "The tags associated to an entry."
    tags::Set{String}
    "Year, it's practical to store it."
    year::String
end
function ZoteroEntry(t, key, authors, fields, files, tags)
    if t ∉ keys(ZOTERO_TO_BIBLATEX_TYPES)
        error("Unknown Zotero item type $t")
    end
    kept_fields = Dict{String, Any}()
    extra_fields = Dict{String, Any}()
    for (k, v) in fields
        if k in keys(ZOTERO_TO_BIBLATEX_FIELDS)
            kept_fields[k] = v
        else
            extra_fields[k] = v
        end
    end
    year = first(split(get(fields, "date", "0000-00-00"), "-"))
    if isnothing(key)
        if length(authors) > 0
            first_author_lastname = last(split(first(authors)))
        else
            first_author_lastname = "unknown_$(hash(join(values(fields))))_"
        end
        key = generate_citationkey(first_author_lastname, year)
    end
    ZoteroEntry(t, key, authors, kept_fields, extra_fields, files, tags, year)
end

"""
$(TYPEDEF)

Represents a BibLaTeX entry.

$(TYPEDFIELDS)
"""
struct BibLaTeXEntry <: Entry
    "BibLaTeX item type. Must be one of the values of [`ZOTERO_TO_BIBLATEX_TYPES`](@ref)."
    type::String
    "Citation key."
    ref::String
    "Authors."
    authors::Vector{String}
    "Fields that will be exported. The keys must be in the values of [`ZOTERO_TO_BIBLATEX_FIELDS`](@ref)."
    fields::Dict{String, Any}
    "All the extra fields that BibLaTeX doesn't know."
    zotero_extra_fields::Dict{String, Any}
    "The files associated to a BibLaTeX entry."
    files::Vector{File}
    "The tags associated to an entry."
    tags::Set{String}
    "Date of the zotero conversion."
    conversion_date::DateTime
    function BibLaTeXEntry(t, ref, authors, fields, extra_fields, files, tags, conversion_date)
        if t ∉ values(ZOTERO_TO_BIBLATEX_TYPES)
            error("Unknown BibLaTeX item type $t")
        end
        if keys(fields) ⊈ values(ZOTERO_TO_BIBLATEX_FIELDS)
            error("Unknown BibLaTeX fields type $(setdiff(keys(fields), values(ZOTERO_TO_BIBLATEX_FIELDS)))")
        end
        new(t, ref, authors, fields, extra_fields, files, tags, conversion_date)
    end
end

BibLaTeXEntry(z::ZoteroEntry) = BibLaTeXEntry(
    ZOTERO_TO_BIBLATEX_TYPES[z.type],
    z.citationkey,
    z.authors,
    filter((!isnothing) ∘ first, Dict([ZOTERO_TO_BIBLATEX_FIELDS[k] => v for (k, v) in z.fields])),
    z.zotero_extra_fields,
    z.files,
    z.tags,
    Dates.now(),
)
to_dict(b::BibLaTeXEntry) = OrderedDict(
    [
        "type" => b.type,
        "ref" => b.ref,
        "author_list" => b.authors,
        [k => escape_string(v) for (k, v) in b.fields]...,
        "zotero_extra_fields" => b.zotero_extra_fields,
        "files" => [file.filename for file in b.files],
        "tags" => collect(b.tags),
        "zotero_import_date" => b.conversion_date,
    ],
)
