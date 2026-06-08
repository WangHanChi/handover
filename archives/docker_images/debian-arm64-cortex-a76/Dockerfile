# Debian bookworm-slim base for ARMv8.2-A (Cortex-A76 / AArch64)
#
# Pure base OS — no extra packages. Build host is x86_64, so this is built
# for linux/arm64 via buildx + QEMU emulation (see build.sh).
#
# For a fully reproducible build, pin by digest instead of tag, e.g.:
#   FROM --platform=linux/arm64 debian:bookworm-slim@sha256:<digest>
FROM --platform=linux/arm64 debian:bookworm-slim

LABEL org.opencontainers.image.title="debian-arm64-cortex-a76"
LABEL org.opencontainers.image.description="Pure Debian bookworm-slim base for ARM Cortex-A76 (linux/arm64)"
LABEL org.opencontainers.image.licenses="Debian DFSG-free"
