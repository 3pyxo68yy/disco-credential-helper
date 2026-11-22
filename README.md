# disco-credential-helper

x86-64-v1 build of [aws/rolesanywhere-credential-helper](https://github.com/aws/rolesanywhere-credential-helper) for the **disco** Kubernetes cluster.

## Why

The disco nodes are QEMU VMs whose CPUs expose only the x86-64-v1 baseline
(no SSE4.2, no POPCNT, no AVX). Every official
`public.ecr.aws/rolesanywhere/credential-helper` image (verified across all
published tags, 1.7.0 → 1.8.6) crashes on those CPUs at startup:

    Fatal glibc error: CPU does not support x86-64-v2

This repo rebuilds the upstream source at a pinned tag with the default
`GOAMD64=v1` (the upstream Makefile sets no GOAMD64) and packages the binary
on `debian:bookworm-slim` (v1-compatible glibc). The result is pushed to
`ghcr.io/3pyxo68yy/disco-credential-helper` as a **public** package so the
cluster can pull it anonymously — no credentials in the cluster, no private
registry in the cluster.

## Images

| tag | meaning |
|---|---|
| `v1.8.6-goamd64v1` | upstream tag v1.8.6, built for x86-64-v1 CPUs |
| `latest` | same as the most recent build |

The tag always encodes the upstream tag: `<upstream-tag>-goamd64v1`.

## Rebuilding (e.g. to pick up upstream v1.8.7)

    gh workflow run build.yml -f tag=v1.8.7

then update the image pin in
`stacks/external-secrets/main.tf` and
`ops/external-secrets-loop/values-override.yaml` in the disco repo.

## Contents

- `Dockerfile` — `debian:bookworm-slim` + the one static-ish Go binary
- `.github/workflows/build.yml` — the whole build; it checks out
  `aws/rolesanywhere-credential-helper` at the requested tag, runs the
  upstream `make release`, and pushes `linux/amd64` to ghcr.io
- no secrets, no private code — the binary is 100% upstream source
