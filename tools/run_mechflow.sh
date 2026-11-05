#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MECHFLOW_ROOT="${MECHFLOW_ROOT:-"$PROJECT_ROOT/../mechflow"}"

if [[ ! -f "$MECHFLOW_ROOT/packages/server/dist/bin.js" ]]; then
  echo "Mechflow is not built at: $MECHFLOW_ROOT" >&2
  echo "From that folder, run: corepack pnpm@9.15.9 install && corepack pnpm@9.15.9 -r build" >&2
  exit 1
fi

node "$PROJECT_ROOT/tools/export_mechflow_model.mjs" --watch &
EXPORTER_PID=$!
cleanup() {
  kill "$EXPORTER_PID" 2>/dev/null || true
  wait "$EXPORTER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

cd "$MECHFLOW_ROOT"
node "$MECHFLOW_ROOT/packages/server/dist/bin.js" --models "$PROJECT_ROOT/simulation/models"
