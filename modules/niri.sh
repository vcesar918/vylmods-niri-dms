#!/usr/bin/env bash
niri_apply() {
  local target="$config_home/niri/config.kdl" snippet="$ROOT/config/niri/window-management.kdl" temp backup
  command -v niri >/dev/null 2>&1 || { log 'Niri is missing; no configuration changed.'; return 1; }
  [[ -f $target && ! -L $target ]] || { log "Expected an existing regular Niri configuration: $target"; return 1; }
  if rg_marker_exists "$target"; then log 'Managed Niri window settings already present; no changes made.'; return 0; fi
  if grep -Eq '^[[:space:]]*(layout|window-rule)[[:space:]]*\{' "$target"; then
    log 'Existing layout or window rules need manual review; refusing to add potentially conflicting settings.'; return 1
  fi
  temp=$(mktemp "${TMPDIR:-/tmp}/niri-config.XXXXXX")
  trap 'rm -f -- "${temp:-}"' RETURN
  cat "$target" "$snippet" > "$temp"
  if ! niri validate -c "$temp"; then log 'Niri rejected the proposed configuration; no changes made.'; return 1; fi
  log "Validated proposed Niri configuration for $target"
  ((dry_run)) && { log 'Dry run: no files changed.'; return 0; }
  confirm 'Back up and update the Niri configuration?' || return 1
  backup=$(mktemp -d "$state_home/niri-manager-backup.XXXXXX" 2>/dev/null) || { mkdir -p -- "$state_home"; backup=$(mktemp -d "$state_home/niri-manager-backup.XXXXXX"); }
  chmod 700 "$backup"
  cp -p -- "$target" "$backup/original"
  printf '%s\n' "$target" > "$backup/target"
  cat "$temp" > "$target"
  log "Updated $target; restore with: $ROOT/install.sh --rollback $backup"
}
rg_marker_exists() { grep -Fq '// BEGIN vylmods-niri-dms window management' "$1"; }
