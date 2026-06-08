#!/usr/bin/env bash
#
# Build a linux/arm64 (Cortex-A76 / AArch64) Debian base image on an x86_64
# host and export it as a gzipped tarball for offline `docker load`.
set -euo pipefail

cd "$(dirname "$0")"

IMAGE="debian-arm64-cortex-a76"
TAG="bookworm-slim"
PLATFORM="linux/arm64"
OUT="${IMAGE}-${TAG}.tar"

# 1. Register QEMU so the x86_64 host can build/run arm64 images.
#    (Idempotent — safe to run every time.)
docker run --privileged --rm tonistiigi/binfmt --install arm64

# 2. Cross-build the arm64 image and load it into the local docker engine.
docker buildx build --platform "${PLATFORM}" -t "${IMAGE}:${TAG}" --load .

# 3. Export to a tar, then also produce a gzip copy. Keep BOTH files
#    (-k keeps the original .tar). Remove any stale output first.
rm -f "${OUT}" "${OUT}.gz"
docker save "${IMAGE}:${TAG}" -o "${OUT}"
gzip -kf "${OUT}"

echo
echo "Created:"
echo "  $(pwd)/${OUT}     ($(du -h "${OUT}" | cut -f1))"
echo "  $(pwd)/${OUT}.gz  ($(du -h "${OUT}.gz" | cut -f1))"
echo "Next: 把這兩個檔手動上傳到 GitHub Release(見 README.md)"
