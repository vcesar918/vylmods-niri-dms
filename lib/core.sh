#!/usr/bin/env bash
log() { printf '%s\n' "$*" >&2; }
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
state_home=${XDG_STATE_HOME:-$HOME/.local/state}
detect() {
  for app in niri dms ghostty sddm pipewire wireplumber; do
    if command -v "$app" >/dev/null 2>&1; then printf '%s: installed (%s)\n' "$app" "$(command -v "$app")"; else printf '%s: missing\n' "$app"; fi
  done
  if command -v niri >/dev/null 2>&1; then niri --version || true; fi
  if command -v dms >/dev/null 2>&1; then dms version || true; fi
}
confirm() {
  ((dry_run || approved)) && return 0
  [[ -t 0 ]] || { log 'Confirmation required; use --yes for noninteractive execution.'; return 1; }
  read -r -p "$1 [y/N] " answer
  [[ $answer == y || $answer == Y || $answer == yes || $answer == YES ]]
}
rollback() {
  local dir=$1 target saved
  [[ -f $dir/target && -f $dir/original ]] || { log 'Invalid backup directory'; return 1; }
  IFS= read -r target < "$dir/target"
  [[ $target == "$config_home/niri/config.kdl" && ! -L $target ]] || { log 'Backup target is not the expected Niri configuration'; return 1; }
  log "Restore $target from $dir"
  confirm 'Restore this backup, replacing the current file?' || return 1
  ((dry_run)) && return 0
  cp -- "$dir/original" "$target"
}
