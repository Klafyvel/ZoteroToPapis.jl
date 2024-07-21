function value_from_fieldname(df, name)
    values = df[df.fieldName .== name, :value]
    if length(values) > 0
        first(values)
    else
        ""
    end
end

ZOTERO_FROM_BIBTEX_FIELDNAMES = Dict(
    [
        "doi" => "DOI"
        "url" => "url"
        "booktitle" => "bookTitle"
        "address" => "place"
        "chapter" => "section"
        "edition" => "edition"
        "institution" => "institution"
        "journal" => "publicationTitle"
        "number" => "issue"
        "organization" => "organization"
        "pages" => "pages"
        "publisher" => "publisher"
        "school" => "university"
        "series" => "series"
        "volume" => "volume"
        "title" => "title"
    ],
)
BIBTEX_FROM_ZOTERO_TYPES = Dict(
    [
        "annotation" => "misc"
        "attachment" => "attachment"
        "blogPost" => "misc"
        "book" => "book"
        "bookSection" => "inbook"
        "computerProgram" => "misc"
        "conferencePaper" => "proceedings"
        "document" => "misc"
        "encyclopediaArticle" => "article"
        "journalArticle" => "article"
        "manuscript" => "book"
        "newspaperArticle" => "article"
        "note" => "misc"
        "preprint" => "journalArticle"
        "report" => "techreport"
        "thesis" => "phdthesis"
        "videoRecording" => "misc"
        "webpage" => "misc"

    ],
)

struct File{T}
    filename::String
    filepath::String
    isexternal::Bool
end
File(mime, filename, filepath, isexternal) = File{MIME(mime)}(filename, filepath, isexternal)

"""
$(SIGNATURES)

Return a BibInternal.Entry corresponding to the item and a list of files and tags.
"""
function prepare_item(itemid, key, typeName; zotero_storage, db, dbbb, papis_root = BaseDirs.User.documents("papers"))
    ## Getting data from Database
    fields = get_fields(db, itemid)
    tags = get_tags(db, itemid)
    collections = get_collections(db, itemid)
    attachments = get_attachments(db, itemid)
    citationkeys = get_citationkey(dbbb, itemid)
    creators = get_creators(db, itemid)

    ## Creating tags
    tags_set = Set()
    for dr in eachrow(tags)
        push!(tags_set, dr.name)
    end
    for dr in eachrow(collections)
        path = get_collection_path(db, dr.collectionID)
        for collection in path
            push!(tags_set, collection)
        end
    end

    ## Creating BibInternal entry
    bibtex_fields = Dict{String, String}()
    for (bibtex_fieldname, zotero_fieldname) in ZOTERO_FROM_BIBTEX_FIELDNAMES
        bibtex_fields[bibtex_fieldname] = value_from_fieldname(fields, zotero_fieldname)
    end

    # Special cases
    bibtex_fields["author"] = join([dr.firstName * " " * dr.lastName for dr in eachrow(creators)], " and ")
    date_str = split(value_from_fieldname(fields, "date"))
    year = ""
    if length(date_str) > 0
        date_str = split(date_str[1], "-")
        if length(date_str) == 3
            bibtex_fields["day"] = date_str[3]
            bibtex_fields["month"] = date_str[2]
            bibtex_fields["year"] = date_str[1]
            year = date_str[1]
        end
    end
    bibtex_fields["_type"] = BIBTEX_FROM_ZOTERO_TYPES[typeName]
    used_fields = [values(ZOTERO_FROM_BIBTEX_FIELDNAMES)..., "date"]
    other_fields = subset(fields, :fieldName => ByRow(x -> x ∉ used_fields))
    for dr in eachrow(other_fields)
        bibtex_fields[dr.fieldName] = dr.value
    end
    bibtex_fields["id"] = string(itemid)
    citationkey = nrow(citationkeys) > 0 ? first(citationkeys.citationKey) : ""
    if length(citationkey) <= 0
        if nrow(creators) > 0
            citationkey = generate_citationkey(first(creators.lastName), year)
        else
            citationkey = generate_citationkey("unknown author $(hash(join(values(bibtex_fields))))", year)
        end
    end

    ## Creating attachments
    files = []
    for dr in eachrow(attachments)
        isexternal = !startswith(dr.path, "storage:")
        if isexternal
            filename = basename(dr.path)
            filepath = dirname(dr.path)
        else
            filename = split(dr.path, ":")[2]
            filepath = joinpath(zotero_storage, dr.key)
        end
        push!(files, File(dr.contentType, filename, filepath, isexternal))
    end

    (entry = BibInternal.Entry(citationkey, bibtex_fields), tags = tags_set, files = files)
end

"""
$(SIGNATURES)

Create BibInternal.jl entries from a Zotero dabase.
"""
function create_bibinternals(; zotero_db, betterbibtex_db, papis_root, zotero_storage, showprogress)
    df_items = get_zotero_items(zotero_db)
    items = []
    # I don't think we can access the database concurrently
    p = Progress(nrow(df_items); enabled = showprogress, desc = "Loading $(nrow(df_items)) item(s) from Zotero database...")
    for dr in eachrow(df_items)
        push!(
            items,
            prepare_item(
                dr.itemID, dr.key, dr.typeName;
                zotero_storage, db = zotero_db,
                dbbb = betterbibtex_db, papis_root,
            ),
        )
        next!(p, showvalues = [(:Key, last(items).entry.id), (Symbol("Zotero ID"), dr.itemID)])
    end
    return items
end
