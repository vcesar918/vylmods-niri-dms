#!/usr/bin/env bash
files_apply() {
  if command -v dfiles >/dev/null 2>&1; then
    log 'Dux Files (dfiles) is already installed.'; return 0
  fi
  command -v dnf >/dev/null 2>&1 && command -v rpm >/dev/null 2>&1 || {
    log 'Dux Files installation requires Fedora RPM and DNF; no changes made.'; return 1;
  }
  dnf -q repoquery --available dux-files | grep -q . || {
    log 'dux-files is unavailable in enabled repositories. No repository was added; check the official DMS Fedora installation guidance.'; return 1;
  }
  log 'Install dux-files using the currently enabled DNF repositories.'
  if ((dry_run)); then log 'Dry run: package installation skipped.'; return 0; fi
  confirm 'Install dux-files with sudo dnf?' || return 1
  sudo dnf install -y dux-files
  command -v dfiles >/dev/null 2>&1 || { log 'Installation completed but dfiles was not found on PATH.'; return 1; }
  log 'Installed Dux Files. Launch it with dfiles show or its desktop launcher.'
  log 'No default application or portal configuration was changed. Dux Files can provide FileManager1 D-Bus activation.'
}
