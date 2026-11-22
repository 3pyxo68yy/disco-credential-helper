# disco cluster build of aws/rolesanywhere-credential-helper.
#
# Why this exists: the official public.ecr.aws/rolesanywhere/credential-helper
# images (every published tag) require an x86-64-v2 CPU. The disco cluster
# nodes are QEMU VMs whose CPUs expose only the x86-64-v1 baseline (no
# SSE4.2/POPCNT/AVX), so the official images die at startup with:
#     Fatal glibc error: CPU does not support x86-64-v2
#
# This image is the upstream binary, built from a pinned upstream tag with
# the default GOAMD64=v1 (the upstream Makefile sets no GOAMD64), on a
# debian:bookworm-slim base whose glibc is v1-compatible. ca-certificates is
# added: bookworm-slim ships without it, and the helper verifies the TLS
# chain to rolesanywhere.<region>.amazonaws.com.
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY upstream/build/bin/aws_signing_helper /usr/local/bin/aws_signing_helper
ENTRYPOINT ["aws_signing_helper"]
