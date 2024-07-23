"""
Zotero's default directory: `~/Zotero`
"""
default_zotero_dir() = joinpath(homedir(), "Zotero")
"""
Zotero's default storage: `~/Zotero/storage`
"""
default_zotero_storage() = joinpath(default_zotero_dir(), "storage")
"""
Zotero's default db: `~/Zotero/zotero.sqlite`
"""
default_zotero_db() = joinpath(default_zotero_dir(), "zotero.sqlite")
"""
Better Bibtex's default db: `~/Zotero/better-bibtex.sqlite`
"""
default_better_bibtex_db() = joinpath(default_zotero_dir(), "better-bibtex.sqlite")
"""
Papis default executable: `which papis`
"""
default_papis() = Sys.which("papis")

"""
$(SIGNATURES)

Generate a directory name within the papis root.
"""
papis_directory(papis_root, year, key) = joinpath(papis_root, length(year) <= 0 ? "misc" : year, key)
"""
$(SIGNATURES)

Make some words into camelCase.
"""
camelCase(s) = lowercasefirst(join(split(titlecase(s)), ""))
"""
$(SIGNATURES)

Generate a citation key for those who do not have one.
"""
generate_citationkey(lastname, year) = camelCase(lastname) * year
"""
$(SIGNATURES)

Format a list of names.
"""
format_name_list(authors) = join(authors, " and ")
