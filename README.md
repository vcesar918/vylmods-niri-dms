# vylmods-niri-dms

A small, configuration-first foundation for managing a Fedora + Niri desktop. The first feature proposes Niri column centering and a default column width. The cursor feature can install Fedora’s Breeze cursor package; DMS applies the selected cursor theme. Other desktop components are detected but not configured.

## Usage

Run `./install.sh --detect` to inspect available commands. Review a proposed change with `./install.sh --dry-run --feature niri`, then run `./install.sh --feature niri` to apply it. `--yes` explicitly accepts the confirmation for unattended use. `all` runs the Niri, cursor, file manager, and Ghostty features. An existing Niri configuration and the `niri` executable are required; the proposed complete configuration is checked with `niri validate` before writing. For an existing layout, the installer changes a single unambiguous `center-focused-column` setting to `always`, preserving other settings; ambiguous layouts require manual review. Validation uses a temporary file beside the configuration so relative includes resolve normally.

A backup is created in `${XDG_STATE_HOME:-~/.local/state}` before updating. Restore it using the command printed by the installer, or `./install.sh --rollback BACKUP_DIRECTORY`; rollback asks before replacing the current file. Use `--dry-run --rollback BACKUP_DIRECTORY` to inspect the operation.

## Limitations

Niri is a scrolling tiling compositor: column centering and default column width do not guarantee every new window is individually centered or preserve its last manually chosen size. Existing application-specific rules are left for manual integration. The installed Niri validator determines whether the configuration syntax is supported; no specific Niri or DMS version is assumed. DMS extension capabilities and integration remain future investigation. The feature has not been verified on a live Fedora/Niri desktop.

Run `bash tests/run.sh` for the isolated filesystem tests. Tests use a fake Niri validator and cannot establish compatibility with a real Niri version.

## Breeze Dark cursor

Run `./install.sh --dry-run --feature cursor` to check the Fedora package, then `./install.sh --feature cursor` to install it if needed. Installation requires sudo and confirmation; `--yes` accepts the installer prompt. The feature never adds repositories. In DMS Settings, open Theme & Colors → Cursor and select Breeze Dark. DMS owns its generated Niri cursor configuration; the installer does not overwrite it. Log out and back in if applications retain an old cursor. To reverse the selection, choose your previous theme in DMS. The package is retained unless you explicitly remove it yourself.

## Dux Files

Dux Files is the upstream DMS-associated file manager (`dfiles`). Run `./install.sh --dry-run --feature files` to check availability, then `./install.sh --feature files` to install the `dux-files` package from an already enabled DNF repository, with confirmation and sudo. The installer does not add a repository. Launch with `dfiles show` or the application launcher. It does not set the default file manager or portal; the package may register D-Bus activation for FileManager1, which can affect “show in folder” behavior. Remove the package separately with DNF if desired, after reviewing its proposed transaction.

## Ghostty padding

Use `./install.sh --dry-run --feature ghostty`, then `./install.sh --feature ghostty`. The feature requires an existing `~/.config/ghostty/config`, checks the proposed file with `ghostty +validate-config`, and sets top padding to 2 and bottom padding to 20 points. Existing padding is backed up. Configurations with included files or duplicate padding settings require manual review. Open a new window or split to see the change. Restore the backup with the printed rollback command.

## Screenshot shortcut

`./install.sh --dry-run --feature screenshot` checks the Niri configuration and its includes for a Super+S binding, then validates the proposed configuration. `./install.sh --feature screenshot` backs up the configuration and adds Super+S to open Niri's screenshot selection interface. Niri's existing screenshot-path controls where images are saved. The shortcut check is conservative; if the config or includes cannot be inspected, the installer stops for manual review. Use the printed rollback command to restore the backup.
