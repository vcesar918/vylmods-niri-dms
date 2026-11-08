#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$ROOT/lib/core.sh"
source "$ROOT/modules/niri.sh"
source "$ROOT/modules/cursor.sh"
source "$ROOT/modules/files.sh"
source "$ROOT/modules/ghostty.sh"
source "$ROOT/modules/screenshot.sh"
usage() { echo 'Usage: install.sh [--dry-run] [--yes] [--feature niri|cursor|files|ghostty|screenshot|all] | --detect | --rollback BACKUP_DIRECTORY'; }
dry_run=0; approved=0; feature=all; action=install; backup_dir=
while (($#)); do
  case $1 in
    --dry-run) dry_run=1;; --yes) approved=1;;
    --feature) (($# >= 2)) || { usage >&2; exit 2; }; feature=$2; shift;;
    --detect) action=detect;;
    --rollback) (($# >= 2)) || { usage >&2; exit 2; }; action=rollback; backup_dir=$2; shift;;
    -h|--help) usage; exit 0;; *) usage >&2; exit 2;;
  esac; shift
done
case $feature in all|niri|cursor|files|ghostty|screenshot) ;; *) echo "Unknown feature: $feature" >&2; exit 2;; esac
if [[ $action == detect ]]; then detect; exit; fi
if [[ $action == rollback ]]; then rollback "$backup_dir"; exit; fi
case $feature in
  niri) niri_apply;;
  cursor) cursor_apply;;
  files) files_apply;;
  ghostty) ghostty_apply;;
  screenshot) screenshot_apply;;
  all) niri_apply; cursor_apply; files_apply; ghostty_apply; screenshot_apply;;
esac
