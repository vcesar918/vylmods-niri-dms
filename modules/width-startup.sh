#!/usr/bin/env bash
width_startup_apply() {
  local target="$config_home/niri/config.kdl" helper="$ROOT/features/niri_width.py" temp backup
  command -v niri >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1 || { log 'Niri and Python 3 are required; no changes made.'; return 1; }
  [[ -f $target && ! -L $target && -f $helper ]] || { log "Expected a regular Niri configuration and width helper: $target"; return 1; }
  temp=$(mktemp "$(dirname -- "$target")/.niri-width-startup.XXXXXX")
  trap 'rm -f -- "${temp:-}"' RETURN
  python3 "$ROOT/lib/width-startup-edit.py" "$target" "$temp" "$helper" || { log 'Could not safely update startup; no changes made.'; return 1; }
  niri validate -c "$temp" || { log 'Niri rejected the proposed configuration; no changes made.'; return 1; }
  if cmp -s "$target" "$temp"; then log 'Width helper startup is already configured.'; return 0; fi
  log "Validated automatic width helper startup for $target"
  ((dry_run)) && { log 'Dry run: no files changed.'; return 0; }
  confirm 'Back up and enable width helper on Niri startup?' || return 1
  mkdir -p -- "$state_home"
  backup=$(mktemp -d "$state_home/niri-width-startup-backup.XXXXXX")
  chmod 700 "$backup"
  cp -p -- "$target" "$backup/original"
  printf '%s\n' "$target" > "$backup/target"
  cat "$temp" > "$target"
  log "Updated $target; restore with: $ROOT/install.sh --rollback $backup"
  log 'The helper starts at your next Niri session. Keep the repository at its current location.'
}
