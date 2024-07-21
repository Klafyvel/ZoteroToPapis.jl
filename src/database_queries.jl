"""
$(SIGNATURES)

Get the list of items in the Zotero database, excluding attachments. The returned
`DataFrame` has the following columns: 
- `itemID`
- `typeName`
- `key`
- `dateAdded`
"""
function get_zotero_items(db)
    query = """
  SELECT
    items.itemID,
    itemTypes.typeName,
    items.key,
    items.dateAdded
  FROM
    items LEFT JOIN itemTypes on items.itemTypeID = itemTypes.itemTypeID
    LEFT JOIN deletedItems on items.itemID = deletedItems.itemID
  WHERE
    itemTypes.itemTypeID = items.itemTypeID
    AND itemTypes.typeName != "attachment"
    AND deletedItems.itemID IS NULL
  ORDER BY
    items.itemID
  """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Get the fields set for a specific item. The returned `DataFrame` has two columns,
`fieldName` and `value`.
"""
function get_fields(db, itemid)
    query = """
        SELECT
          fieldName, value
        FROM
          itemDataValues
          LEFT JOIN itemData ON itemDataValues.valueID = itemData.valueID
          LEFT JOIN fields ON itemData.fieldID = fields.fieldID
          LEFT JOIN items ON itemData.itemID = items.itemID
          LEFT JOIN itemTypes ON items.itemTypeID = itemTypes.itemTypeID
        WHERE
        itemData.itemID = $itemid
        """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Get the tags set for a specific item. The returned `DataFrame` has a single column,
`name`.
"""
function get_tags(db, itemid)
    query = """SELECT
        name
        FROM
        itemTags LEFT JOIN tags on itemTags.tagID = tags.tagID
        WHERE
        itemTags.itemID = $itemid 
        """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Get the collections a specificitem directly belongs to (not their parents). The 
returned `DataFrame` has a two columns, `collectionName` and `collectionID`.
"""
function get_collections(db, itemid)
    query = """SELECT 
          collectionName, collections.collectionID
        FROM 
          collectionItems 
          LEFT JOIN collections ON collections.collectionID = collectionItems.collectionID
        WHERE 
          collectionItems.itemID = $itemid 
    """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Get a tuple of collection names that are the parents of a given collection.
"""
function get_collection_path(db, collectionID)
    query_this_collection = """SELECT
    collectionName, parentCollectionID
  FROM 
    collections
  WHERE
    collectionID=$collectionID
  """
    dr_this_collection = first(DataFrame(DBInterface.execute(db, query_this_collection)))
    if !ismissing(dr_this_collection.parentCollectionID)
        parent_path = get_collection_path(db, dr_this_collection.parentCollectionID)
    else
        parent_path = ()
    end
    (parent_path..., dr_this_collection.collectionName)
end

"""
$(SIGNATURES)

Get the attachments associated with a specific item. The returned `DataFrame` 
has three columns: `contentType`, `path`, and `key`.
"""
function get_attachments(db, itemid)
    query = """SELECT 
        itemAttachments.contentType, itemAttachments.path, items.key
        FROM 
        itemAttachments  left join items on itemAttachments.itemID = items.itemID
        WHERE 
        itemAttachments.path is not NULL AND 
        itemAttachments.parentItemID = $itemid
    """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Retrieve the citation key of an item from the Better Bibtex database.
"""
function get_citationkey(db, itemid)
    query = """SELECT
  *
  FROM 
  citationkey
  WHERE 
  itemID = $itemid
  """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Retrieve the IDs corresponding to a citation key from the Better Bibtex database.
"""
function get_id_from_citationkey(db, citationkey)
    query = """SELECT
  itemID
  FROM 
  citationkey
  WHERE 
  citationKey = "$citationkey"
  """
    DataFrame(DBInterface.execute(db, query))
end

"""
$(SIGNATURES)

Retrieve the creators of an item. The returned `DataFrame` is sorted by author
order and has the following columns:
- `orderIndex`
- `creatorType`
- `firstName`
- `lastName`
"""
function get_creators(db, itemid)
    query = """SELECT 
      itemCreators.orderIndex,
      creatorTypes.creatorType, 
      creators.firstName, 
      creators.lastName 
    FROM 
      itemCreators 
      LEFT JOIN creators ON itemCreators.creatorID = creators.creatorID
      LEFT JOIN creatorTypes on itemCreators.creatorTypeID = creatorTypes.CreatorTypeID
    WHERE 
      itemCreators.itemID = $itemid 
      AND itemCreators.creatorID = creators.creatorID 
      AND itemCreators.creatorTypeID = creatorTypes.CreatorTypeID
    ORDER BY itemCreators.orderIndex
    """
    DataFrame(DBInterface.execute(db, query))
end
