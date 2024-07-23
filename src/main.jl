@static if VERSION >= v"1.8"
    errno::Cint = 0
else
    errno = 0
end

function parse_arguments(args)
    settings = ArgParseSettings(
        prog = "ZoteroToPapis",
        description = "Migrate Zotero+BetterBibtex database to Papis.",
        epilog = "Please, report bugs at https://github.com/klafyvel/ZoteroToPapis.jl.",
        version = @project_version,
        add_version = true,
    )
    add_arg_table!(
        settings,
        "--zotero-db", Dict(
            :help => "Path of the Zotero database.",
            :action => :store_arg,
            :default => default_zotero_db(),
        ),
        "--better-bibtex-db", Dict(
            :help => "Path of the Better Bibtex database.",
            :action => :store_arg,
            :default => default_better_bibtex_db(),
        ),
        "--zotero-storage", Dict(
            :help => "Path of the Zotero storage.",
            :action => :store_arg,
            :default => default_zotero_storage(),
        ),
        "--papis-root", Dict(
            :help => "Path of the Papis root.",
            :action => :store_arg,
            :default => BaseDirs.User.documents("papers"),
        ),
        "--keep-external", Dict(
            :help => "If enabled, keep files not in Zotero storage where they are.",
            :action => :store_true,
        ),
        "--no-progress", Dict(
            :help => "If set, disable progress display.",
            :action => :store_true,
        ),
        "--no-papis-update", Dict(
            :help => "If set, disable papis update after import.",
            :action => :store_true,
        ),
        "--no-papis-doctor", Dict(
            :help => "If set, disable papis doctor after import (the doctor requires papis update).",
            :action => :store_true,
        ),
        "--no-duplication-mitigation", Dict(
            :help => "If set, disable the mitigation measures when trying to import a duplicate.",
            :action => :store_true,
        ),
    )
    parse_args(args, settings)
end

function main(args)
    parsed_arguments = parse_arguments(args)

    zoterodb_path = parsed_arguments["zotero-db"]
    betterbibtexdb_path = parsed_arguments["better-bibtex-db"]
    papis_root = parsed_arguments["papis-root"]
    zotero_storage = parsed_arguments["zotero-storage"]
    move_external = !parsed_arguments["keep-external"]
    showprogress = !parsed_arguments["no-progress"]
    papisupdate = !parsed_arguments["no-papis-update"]
    papisdoctor = !parsed_arguments["no-papis-doctor"]
    append_zotero_id_on_duplicate = !parsed_arguments["no-duplication-mitigation"]
    zotero_db = SQLite.DB(zoterodb_path)
    betterbibtex_db = SQLite.DB(betterbibtexdb_path)
    entries = create_zotero_entries(; zotero_db, betterbibtex_db, papis_root, zotero_storage, showprogress)
    export_zotero_entries(entries; papis_root, showprogress, move_external, append_zotero_id_on_duplicate)
    if papisupdate
        papis_update(default_papis(), papisdoctor)
    end
    errno
end

# Only works for Julia 1.12
@static if isdefined(Base, Symbol("@main"))
    @main
end
