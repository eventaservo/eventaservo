#!/usr/bin/env bash
# frozen_string_literal: true

# Download the GeoLite2-City.mmdb database for offline IP geocoding.
#
# The GeoLite2 database is provided by MaxMind and can be downloaded for free
# (Creative Commons BY-SA 4.0). This script uses a community-maintained mirror
# on jsDelivr CDN that packages the official MaxMind release.
#
# No registration or API key required.
#
# Usage:
#   bin/download-geolite2-db.sh               # downloads to RAILS_ROOT
#   bin/download-geolite2-db.sh /path/to/dir  # downloads to custom path

set -euo pipefail

MIRROR_URL="https://raw.githubusercontent.com/P3TERX/GeoLite.mmdb/download/GeoLite2-City.mmdb"
DEST_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
DEST_FILE="${DEST_DIR}/GeoLite2-City.mmdb"

echo "==> Downloading GeoLite2-City.mmdb..."
echo "    From: ${MIRROR_URL}"
echo "    To:   ${DEST_FILE}"

curl -fSL -o "${DEST_FILE}" "${MIRROR_URL}"

echo "==> Done! $(ls -lh "${DEST_FILE}" | awk '{print $5}') downloaded."
