#!/usr/bin/env bash
set -Eeuo pipefail

if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR is not defined."
    exit 1
fi

mkdir -p "$DATA_DIR/mariadb"
mkdir -p "$DATA_DIR/wordpress"

echo "Data directories ready."