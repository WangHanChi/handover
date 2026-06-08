#!/usr/bin/env bash
#
# Upload the image tarball to a GitHub Release (asset limit 2 GB/file), so it
# never has to be committed into the repo and never hits the 100 MB file cap.
#
# Requires the `gh` CLI, authenticated against github.com/WangHanChi/handover.
set -euo pipefail

cd "$(dirname "$0")"

IMAGE="debian-arm64-cortex-a76"
TAG="bookworm-slim"
ASSETS=("${IMAGE}-${TAG}.tar" "${IMAGE}-${TAG}.tar.gz")
RELEASE_TAG="${1:-docker-debian-arm64-v1}"

for f in "${ASSETS[@]}"; do
  if [[ ! -f "${f}" ]]; then
    echo "error: ${f} not found — run ./build.sh first." >&2
    exit 1
  fi
done

# Create the release if it doesn't exist yet, otherwise just upload the assets.
if gh release view "${RELEASE_TAG}" >/dev/null 2>&1; then
  gh release upload "${RELEASE_TAG}" "${ASSETS[@]}" --clobber
else
  gh release create "${RELEASE_TAG}" "${ASSETS[@]}" \
    --title "Debian arm64 Cortex-A76 base" \
    --notes "Pure debian:bookworm-slim base image for ARM Cortex-A76 (linux/arm64). Import with: docker load -i ${IMAGE}-${TAG}.tar"
fi

echo "Uploaded ${ASSETS[*]} to release ${RELEASE_TAG}."
