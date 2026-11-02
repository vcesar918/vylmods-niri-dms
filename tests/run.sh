#!/usr/bin/env bash
set -Eeuo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_STATE_HOME="$tmp/state" PATH="$tmp/bin:$PATH"
mkdir -p "$tmp/bin" "$XDG_CONFIG_HOME/niri"
printf '#!/bin/sh\nexit 0\n' > "$tmp/bin/niri"
chmod +x "$tmp/bin/niri"
printf '// original\n' > "$XDG_CONFIG_HOME/niri/config.kdl"
"$root/install.sh" --dry-run --feature niri
! grep -q 'BEGIN vylmods' "$XDG_CONFIG_HOME/niri/config.kdl"
"$root/install.sh" --yes --feature niri
cp "$XDG_CONFIG_HOME/niri/config.kdl" "$tmp/applied"
"$root/install.sh" --yes --feature niri
cmp "$tmp/applied" "$XDG_CONFIG_HOME/niri/config.kdl"
backup=$(find "$XDG_STATE_HOME" -mindepth 1 -maxdepth 1 -type d -print -quit)
"$root/install.sh" --yes --rollback "$backup"
grep -qx '// original' "$XDG_CONFIG_HOME/niri/config.kdl"
printf 'layout {\n    center-focused-column "never"\n}\n' > "$XDG_CONFIG_HOME/niri/config.kdl"
"$root/install.sh" --yes --feature niri
grep -q 'center-focused-column "always"' "$XDG_CONFIG_HOME/niri/config.kdl"
printf 'layout {\n}\n' > "$XDG_CONFIG_HOME/niri/config.kdl"
if "$root/install.sh" --yes --feature niri; then echo 'Expected conflict rejection' >&2; exit 1; fi
cat > "$tmp/bin/rpm" <<'SCRIPT'
#!/bin/sh
exit 1
SCRIPT
cat > "$tmp/bin/dnf" <<'SCRIPT'
#!/bin/sh
printf 'breeze-cursor-theme\n'
SCRIPT
chmod +x "$tmp/bin/rpm" "$tmp/bin/dnf"
"$root/install.sh" --dry-run --feature cursor
"$root/install.sh" --dry-run --feature files
printf 'Tests passed\n' 
