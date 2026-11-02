#!/usr/bin/env bash
ghostty_apply() {
  local target="$config_home/ghostty/config" temp backup
  command -v ghostty >/dev/null 2>&1 || { log 'Ghostty is missing; no changes made.'; return 1; }
  [[ -f $target && ! -L $target ]] || { log "Expected an existing regular Ghostty configuration: $target"; return 1; }
  if grep -Eq '^[[:space:]]*config-file[[:space:]]*=' "$target"; then
    log 'Ghostty configuration includes other files; review their padding settings manually.'; return 1
  fi
  temp=$(mktemp "$(dirname -- "$target")/.vylmods-ghostty.XXXXXX")
  trap 'rm -f -- "${temp:-}"' RETURN
  if ! python3 "$ROOT/lib/ghostty-edit.py" "$target" "$temp"; then log 'Ambiguous padding settings; no changes made.'; return 1; fi
  if ! ghostty +validate-config --config-file="$temp"; then log 'Ghostty could not validate the proposed configuration; no changes made.'; return 1; fi
  if cmp -s "$target" "$temp"; then log 'Ghostty bottom padding already configured.'; return 0; fi
  log "Validated proposed Ghostty padding for $target"
  ((dry_run)) && { log 'Dry run: no files changed.'; return 0; }
  confirm 'Back up and update Ghostty padding?' || return 1
  mkdir -p -- "$state_home"
  backup=$(mktemp -d "$state_home/ghostty-manager-backup.XXXXXX")
  chmod 700 "$backup"
  cp -p -- "$target" "$backup/original"
  printf '%s\n' "$target" > "$backup/target"
  cat "$temp" > "$target"
  log "Updated $target; restore with: $ROOT/install.sh --rollback $backup"
  log 'Open a new Ghostty window or split to use the new padding.'
}
