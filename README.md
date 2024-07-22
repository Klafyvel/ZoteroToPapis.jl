# ZoteroToPapis

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://klafyvel.github.io/ZoteroToPapis.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://klafyvel.github.io/ZoteroToPapis.jl/dev/)
[![Build Status](https://github.com/klafyvel/ZoteroToPapis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/klafyvel/ZoteroToPapis.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Migrate Zotero+BetterBibtex database to Papis.

# Installation

You need a working Julia installation, then simply `] add https://github.com/Klafyvel/ZoteroToPapis.jl`.

If you're gonna use the script often, you may add an alias:
```bash
alias ZoteroToPapis="julia -e 'using ZoteroToPapis; exit(ZoteroToPapis.main(ARGS))' --"
```
If you are using Julia 1.12 or later, it can simply be
```bash
alias ZoteroToPapis="julia -m ZoteroToPapis"
```

# Usage

```
usage: ZoteroToPapis [--zotero-db ZOTERO-DB]
                     [--better-bibtex-db BETTER-BIBTEX-DB]
                     [--zotero-storage ZOTERO-STORAGE]
                     [--papis-root PAPIS-ROOT] [--keep-external]
                     [--no-progress] [--no-papis-update]
                     [--no-papis-doctor] [--no-duplication-mitigation]
                     [--version] [-h]

Migrate Zotero+BetterBibtex database to Papis.

optional arguments:
  --zotero-db ZOTERO-DB
                        Path of the Zotero database. (default:
                        "~/Zotero/zotero.sqlite")
  --better-bibtex-db BETTER-BIBTEX-DB
                        Path of the Better Bibtex database. (default:
                        "~/Zotero/better-bibtex.sqlite")
  --zotero-storage ZOTERO-STORAGE
                        Path of the Zotero storage. (default:
                        "~/Zotero/storage")
  --papis-root PAPIS-ROOT
                        Path of the Papis root. (default:
                        "XDG_DOCUMENTS_DIR/papers")
  --keep-external       If enabled, keep files not in Zotero storage
                        where they are.
  --no-progress         If set, disable progress display.
  --no-papis-update     If set, disable papis update after import.
  --no-papis-doctor     If set, disable papis doctor after import (the
                        doctor requires papis update).
  --no-duplication-mitigation
                        If set, disable the mitigation measures when
                        trying to import a duplicate.
  --version             show version information and exit
  -h, --help            show this help message and exit

Please, report bugs at https://github.com/klafyvel/ZoteroToPapis.jl.
```
