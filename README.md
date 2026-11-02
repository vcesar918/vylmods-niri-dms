# vylmods-niri-dms

A small, configuration-first foundation for managing a Fedora + Niri desktop. The first feature proposes Niri column centering and a default column width. DMS and other desktop components are detected but not configured or installed yet. No packages or services are changed.

## Usage

Run `./install.sh --detect` to inspect available commands. Review a proposed change with `./install.sh --dry-run --feature niri`, then run `./install.sh --feature niri` to apply it. `--yes` explicitly accepts the confirmation for unattended use. `all` currently means only the Niri feature. An existing Niri configuration and the `niri` executable are required; the proposed complete configuration is checked with `niri validate` before writing. Existing layout or window-rule blocks require manual review and cause the installer to stop. The installer does not alter those blocks.

A backup is created in `${XDG_STATE_HOME:-~/.local/state}` before updating. Restore it using the command printed by the installer, or `./install.sh --rollback BACKUP_DIRECTORY`; rollback asks before replacing the current file. Use `--dry-run --rollback BACKUP_DIRECTORY` to inspect the operation.

## Limitations

Niri is a scrolling tiling compositor: column centering and default column width do not guarantee every new window is individually centered or preserve its last manually chosen size. Existing application-specific rules are left for manual integration. The installed Niri validator determines whether the configuration syntax is supported; no specific Niri or DMS version is assumed. DMS extension capabilities and integration remain future investigation. The feature has not been verified on a live Fedora/Niri desktop.

Run `bash tests/run.sh` for the isolated filesystem tests. Tests use a fake Niri validator and cannot establish compatibility with a real Niri version.
