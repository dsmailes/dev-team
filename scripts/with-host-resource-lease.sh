#!/bin/sh
# Run one command while holding a host-wide named resource lease.
set -eu

usage() {
  cat <<'EOF'
Usage: with-host-resource-lease.sh [--root PATH] [--timeout SECONDS] RESOURCE -- COMMAND [ARG...]

Acquire a host-wide lease using an atomic directory, run COMMAND, then release it.
The default root is ${DEV_TEAM_HOST_RESOURCE_ROOT:-${TMPDIR:-/tmp}/dev-team-host-resources}.
Use a local path shared by the apps that need to coordinate. A lease with a
numeric owner PID that is no longer alive is reclaimed automatically. Malformed
or unverifiable owner records remain unavailable for manual inspection.
EOF
}

lease_root=${DEV_TEAM_HOST_RESOURCE_ROOT:-${TMPDIR:-/tmp}/dev-team-host-resources}
timeout=600

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      lease_root=$2
      shift 2
      ;;
    --timeout)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      timeout=$2
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

[ "$#" -ge 3 ] || { usage >&2; exit 2; }
resource=$1
shift
[ "$1" = "--" ] || { usage >&2; exit 2; }
shift

case "$resource" in
  *[!A-Za-z0-9_.-]*|'')
    echo "error: resource must contain only letters, numbers, dot, underscore, or dash" >&2
    exit 2
    ;;
esac
case "$timeout" in
  *[!0-9]*|'')
    echo "error: timeout must be a non-negative integer" >&2
    exit 2
    ;;
esac

umask 077
mkdir -p "$lease_root"
lease_dir=$lease_root/$resource.lease
owner_file=$lease_dir/owner
started_at=$(date +%s)

describe_owner() {
  if [ -f "$owner_file" ]; then
    sed -n '1,8p' "$owner_file" >&2
  else
    echo "owner record is unavailable" >&2
  fi
}

reclaim_dead_owner() {
  [ -f "$owner_file" ] || return 1
  recorded_pid=$(sed -n 's/^pid=//p' "$owner_file" | sed -n '1p')
  case "$recorded_pid" in
    *[!0-9]*|'') return 1 ;;
  esac
  kill -0 "$recorded_pid" 2>/dev/null && return 1

  stale_dir=$lease_dir.stale.$$
  if mv "$lease_dir" "$stale_dir" 2>/dev/null; then
    echo "warning: reclaimed stale host resource '$resource' from dead pid $recorded_pid" >&2
    rm -rf "$stale_dir"
    return 0
  fi
  return 1
}

while ! mkdir "$lease_dir" 2>/dev/null; do
  if reclaim_dead_owner; then
    continue
  fi
  now=$(date +%s)
  elapsed=$((now - started_at))
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "error: timed out waiting for host resource '$resource' after ${elapsed}s" >&2
    describe_owner
    exit 1
  fi
  sleep 1
done

cleanup() {
  rm -f "$owner_file"
  rmdir "$lease_dir" 2>/dev/null || true
}

trap cleanup 0
trap 'exit 130' 1 2 15

{
  printf 'resource=%s\n' "$resource"
  printf 'pid=%s\n' "$$"
  printf 'acquired_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'command=%s\n' "$1"
} > "$owner_file"

"$@"
