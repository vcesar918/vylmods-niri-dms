#!/usr/bin/env bash
cursor_apply() {
  local package=breeze-cursor-theme
  command -v rpm >/dev/null 2>&1 && command -v dnf >/dev/null 2>&1 || {
    log 'Breeze cursor installation requires Fedora RPM and DNF; no changes made.'; return 1;
  }
  if rpm -q "$package" >/dev/null 2>&1; then
    log "$package is already installed."
  else
    dnf -q repoquery --available "$package" | grep -q . || {
      log "Package $package is unavailable in the configured repositories; no changes made."; return 1;
    }
    log "Install Fedora package: $package"
    if ((dry_run)); then
      log 'Dry run: package installation skipped.'
    else
      confirm "Install $package with sudo dnf?" || return 1
      sudo dnf install -y "$package"
      rpm -q "$package" >/dev/null || { log 'Package installation could not be verified.'; return 1; }
    fi
  fi
  log 'Select Breeze Dark in DMS Settings → Theme & Colors → Cursor. DMS manages its Niri cursor configuration.'
  log 'To undo, select your previous cursor theme in DMS. Package removal is a separate manual action.'
}
