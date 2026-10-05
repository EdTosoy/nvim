# Neovim ownership and recovery

Home Manager supplies Neovim, tools and this native configuration. Lazy manages
plugins. `lazy-lock.json` records the reviewed plugin revisions, including Lazy
itself; it is a snapshot, not Lazy's writable operational lock.

On first startup, the snapshot seeds `stdpath("data")/lazy-lock.json` only if that
file is absent. Lazy bootstraps at the snapshot's commit and installs missing
plugins using the operational lock. The seeded copy is made writable even when
Home Manager's snapshot is read-only. Existing locks and plugin checkouts are not
reset by normal startup. Downloads require network access and the declared build
tools. Treesitter installs missing parsers; its build hook runs `TSUpdate` using
the recorded Treesitter plugin's parser definitions.

## Restore the reviewed versions

Close other Neovim instances first. For the default Linux XDG paths:

```sh
config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
mkdir -p "$data"
cp "$config/lazy-lock.json" "$data/lazy-lock.json"
chmod u+w "$data/lazy-lock.json"
nvim --headless '+Lazy! restore' +qa
```

This deliberately replaces the operational lock and restores plugin checkouts.
Fresh data requires no copy: startup seeds the lock automatically. Parser
binaries, plugin downloads, caches and history remain outside Git. To rebuild
parsers for the restored Treesitter definitions, run `:TSUpdate` intentionally;
existing parsers are not reset by ordinary startup.

## Intentional updates

1. Run `:Lazy update` intentionally, then test the editor and relevant projects.
2. Review the writable lock changes and copy the tested lock into the **repository
   checkout's** `lazy-lock.json` (not Home Manager's read-only deployed file).
3. Commit the snapshot with any related configuration changes in this repository;
   then commit its new submodule revision in the workstation repository.

Lazy itself is pinned to the snapshot's commit. To upgrade Lazy, explicitly
select a reviewed commit in its checkout, record that revision in the snapshot
and operational lock, deploy the updated configuration, and test before committing.
Do not use `:Lazy update` as a recovery operation.

## Captured baseline

The snapshot records all 26 configured plugins from the working Neovim 0.12.4
environment. Every recorded commit matches its installed checkout. The old live
lock also contains `firenvim`, which is no longer configured and is deliberately
excluded. Lazy is recorded at `306a05526ada86a7b30af95c5cc81ffba93fef97`;
nvim-lspconfig is recorded at `43ed3797b266e1ee8d222e491379ad471c9d3146`.

Parser binaries are not part of this snapshot. Missing parsers are compiled from
the pinned Treesitter plugin's definitions; ordinary `install` skips existing
parsers, while `TSUpdate` can rebuild them. This restores plugin source revisions,
not byte-identical generated binaries or external toolchain artifacts.
The recorded Python grammar definition uses the fixed `v0.25.0` tag rather than
a commit hash, so parser recovery also relies on that upstream tag remaining
unchanged. No parser definitions are refreshed during recovery.

Angular uses the pinned nvim-lspconfig native `cmd` function to probe project
`node_modules` and the installed `ngserver` location, and to read the project's
Angular core version. The local filetypes and root markers remain configured;
the legacy `on_new_config` hook is not used by `vim.lsp.config`.
