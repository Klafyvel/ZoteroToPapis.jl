function value_from_fieldname(df, name)
    values = df[df.fieldName .== name, :value]
    if length(values) > 0
        first(values)
    else
        nothing
    end
end

"""
$(SIGNATURES)

Return a [`ZoteroEntry`](@ref) corresponding to the item and a list of files and tags.
"""
function prepare_item(itemid, key, typeName; zotero_storage, db, dbbb, papis_root)
    ## Getting data from Database
    df_fields = get_fields(db, itemid)
    df_tags = get_tags(db, itemid)
    df_collections = get_collections(db, itemid)
    df_attachments = get_attachments(db, itemid)
    df_citationkeys = get_citationkey(dbbb, itemid)
    df_creators = get_creators(db, itemid)

    ## Creating tags
    tags = Set()
    for dr in eachrow(df_tags)
        push!(tags, dr.name)
    end
    for dr in eachrow(df_collections)
        path = get_collection_path(db, dr.collectionID)
        for collection in path
            push!(tags, collection)
        end
    end

    ## Creating entry
    fields = Dict{String, Any}()
    for dr in eachrow(df_fields)
        if dr.fieldName ∉ keys(ZOTERO_TO_BIBLATEX_FIELDS)
            continue
        else
            fields[dr.fieldName] = dr.value
        end
    end
    fields["database_id"] = string(itemid)
    fields["database_key"] = string(key)
    authors = [dr.firstName * " " * dr.lastName for dr in eachrow(subset(df_creators, :creatorType => ByRow(≠("editor"))))]
    editor_list = [dr.firstName * " " * dr.lastName for dr in eachrow(subset(df_creators, :creatorType => ByRow(==("editor"))))]
    if !isempty(editor_list)
        fields["editor"] = format_name_list(editor_list)
    end
    citationkey = nrow(df_citationkeys) > 0 ? first(df_citationkeys.citationKey) : nothing

    ## Creating attachments
    files = []
    for dr in eachrow(df_attachments)
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

    ZoteroEntry(typeName, citationkey, authors, fields, files, tags)
end

"""
$(SIGNATURES)

Create [`ZoteroEntry`](@ref) entries from a Zotero dabase.
"""
function create_zotero_entries(; zotero_db, betterbibtex_db, papis_root, zotero_storage, showprogress)
    df_items = get_zotero_items(zotero_db)
    entries = ZoteroEntry[]
    # I don't think we can access the database concurrently
    p = Progress(nrow(df_items); enabled = showprogress, desc = "Loading $(nrow(df_items)) item(s) from Zotero database...")
    for dr in eachrow(df_items)
        push!(
            entries,
            prepare_item(
                dr.itemID, dr.key, dr.typeName;
                zotero_storage, db = zotero_db,
                dbbb = betterbibtex_db, papis_root,
            ),
        )
        next!(p, showvalues = [(:Key, last(entries).citationkey), (Symbol("Zotero ID"), dr.itemID)])
    end
    return entries
end
