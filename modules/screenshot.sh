#!/usr/bin/env bash
screenshot_apply() {
  local target="$config_home/niri/config.kdl" temp backup
  command -v niri >/dev/null 2>&1 || { log 'Niri is missing; no changes made.'; return 1; }
  [[ -f $target && ! -L $target ]] || { log "Expected a regular Niri config: $target"; return 1; }
  if grep -Fqx '// vylmods: Super+S screenshot' "$target"; then
    log 'Screenshot marker already exists; inspect the binding before changing it.'; return 0
  fi
  temp=$(mktemp "$(dirname -- "$target")/.niri-screenshot.XXXXXX")
  trap 'rm -f -- "${temp:-}"' RETURN
  python3 "$ROOT/lib/screenshot-edit.py" "$target" "$temp" || { log 'Could not safely add the shortcut; no changes made.'; return 1; }
  niri validate -c "$temp" || { log 'Niri rejected the proposed shortcut; no changes made.'; return 1; }
  log "Validated Super+S screenshot shortcut for $target"
  ((dry_run)) && { log 'Dry run: no files changed.'; return 0; }
  confirm 'Back up and add Super+S screenshot shortcut?' || return 1
  mkdir -p -- "$state_home"
  backup=$(mktemp -d "$state_home/niri-screenshot-backup.XXXXXX")
  chmod 700 "$backup"
  cp -p -- "$target" "$backup/original"
  printf '%s\n' "$target" > "$backup/target"
  cat "$temp" > "$target"
  log "Updated $target; restore with: $ROOT/install.sh --rollback $backup"
}
