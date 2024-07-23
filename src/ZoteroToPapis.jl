module ZoteroToPapis

using YAML
using SQLite
using ProgressMeter
using DataFrames
using OrderedCollections
using SHA
using DocStringExtensions
using BaseDirs
using Dates
using ArgParse

include("logging.jl")
include("defaults.jl")
include("database_queries.jl")
include("types.jl")
include("zotero_importer.jl")
include("biblatex_doctor.jl")
include("papis_exporter.jl")

include("main.jl")

if Base.VERSION >= v"1.4.2"
    @assert precompile(main, (Vector{String},))
    @assert precompile(parse_arguments, (Vector{String},))
    Base.precompile(Tuple{typeof(Core.kwcall), @NamedTuple{zotero_db::SQLite.DB, betterbibtex_db::SQLite.DB, papis_root::String, zotero_storage::String, showprogress::Bool}, typeof(create_zotero_entries)})   # time: 0.86989796
    Base.precompile(Tuple{typeof(Core.kwcall), @NamedTuple{papis_root::String, move_external::Bool, append_zotero_id_on_duplicate::Bool}, typeof(export_zotero_entry), ZoteroEntry})   # time: 0.12025428
    # Base.precompile(Tuple{var"#111#threadsfor_fun#14"{var"#111#threadsfor_fun#13#15"{String, Bool, Bool, Progress, Vector{Any}}}, Int64})   # time: 0.11337276
    Base.precompile(Tuple{typeof(Core.kwcall), @NamedTuple{papis_root::String, showprogress::Bool, move_external::Bool, append_zotero_id_on_duplicate::Bool}, typeof(export_zotero_entries), Vector{ZoteroEntry}})   # time: 0.016359227
    Base.precompile(Tuple{typeof(Core.kwcall), @NamedTuple{zotero_storage::String, db::SQLite.DB, dbbb::SQLite.DB, papis_root::String}, typeof(prepare_item), Int64, String, String})   # time: 0.01258725
    Base.precompile(Tuple{typeof(get_collection_path), SQLite.DB, Int64})   # time: 0.00402853
end

end
