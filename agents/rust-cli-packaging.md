---
name: rust-cli-packaging
description: Creates packaging templates and build scripts for a Rust CLI project. Use as the fourth step of rust-cli scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(chmod *), Bash(git *)
---

You are creating packaging templates and build scripts for a Rust CLI project.

## Step 1 — Read project context

Read `Cargo.toml` to get the binary name and version.

## Step 2 — Create packaging/deb/control

```
Package: BINARY_PLACEHOLDER
Version: VERSION_PLACEHOLDER
Architecture: amd64
Maintainer: MAINTAINER_PLACEHOLDER
Description: DESCRIPTION_PLACEHOLDER
# TODO: Add Depends: field once runtime requirements are known
# Example: Depends: libssl3 (>= 3.0), openssh-client
```

## Step 3 — Create packaging/aur/PKGBUILD.template

```bash
# TODO: Review before first AUR release:
#   - Replace sha256sums SKIP with real checksums
#   - Add optdepends if any optional runtime tools are needed
#   - Add any extra install steps (completions, config files, etc.)
pkgname=BINARY_PLACEHOLDER
pkgver=VERSION_PLACEHOLDER
pkgrel=1
pkgdesc='DESCRIPTION_PLACEHOLDER'
arch=('x86_64')
url='https://github.com/OWNER_PLACEHOLDER/REPO_PLACEHOLDER'
license=('MIT')
source=("$pkgname-$pkgver::$url/releases/download/v$pkgver/$pkgname")
sha256sums=('SKIP')

package() {
    install -Dm755 "$srcdir/$pkgname-$pkgver" "$pkgdir/usr/bin/$pkgname"
    # TODO: add man page once docs/man/<binary>.1 is generated
    # install -Dm644 "$srcdir/BINARY_PLACEHOLDER.1" \
    #     "$pkgdir/usr/share/man/man1/BINARY_PLACEHOLDER.1"
}
```

## Step 4 — Create scripts/build-deb.sh

```bash
#!/usr/bin/env bash
# Build a .deb package from the musl binary.
#
# TODO: This is a generated template. Review and update before first release:
#   - Add any runtime dependencies to packaging/deb/control (Depends: field)
#   - Add any config files, systemd units, or shell completions that should
#     be packaged (copy them into the staging directory below)
#   - Test with: dpkg-deb --build dist/<pkg> and install on a clean system
#
set -euo pipefail

BINARY="$1"
VERSION="$2"
TARGET="x86_64-unknown-linux-musl"
PKG="${BINARY}_${VERSION}_amd64"

mkdir -p "dist/${PKG}/DEBIAN"
mkdir -p "dist/${PKG}/usr/bin"
mkdir -p "dist/${PKG}/usr/share/man/man1"

cp "target/${TARGET}/release/${BINARY}" "dist/${PKG}/usr/bin/${BINARY}"

# TODO: copy any additional files here, for example:
# cp packaging/deb/completions/${BINARY}.bash "dist/${PKG}/usr/share/bash-completion/completions/${BINARY}"
# cp packaging/deb/${BINARY}.service "dist/${PKG}/lib/systemd/system/${BINARY}.service"

if [[ -f "docs/man/${BINARY}.1" ]]; then
    gzip -c "docs/man/${BINARY}.1" > "dist/${PKG}/usr/share/man/man1/${BINARY}.1.gz"
fi

sed \
    -e "s/VERSION_PLACEHOLDER/${VERSION}/g" \
    -e "s/BINARY_PLACEHOLDER/${BINARY}/g" \
    packaging/deb/control > "dist/${PKG}/DEBIAN/control"

dpkg-deb --build "dist/${PKG}" "dist/${PKG}.deb"
echo "Built dist/${PKG}.deb"
```

## Step 5 — Create scripts/build-aur.sh

```bash
#!/usr/bin/env bash
# Generate AUR PKGBUILD from template.
#
# TODO: This is a generated template. Review and update before first release:
#   - Verify the sha256sums line — change 'SKIP' to actual checksums for release
#   - Add any optional runtime dependencies (optdepends array)
#   - Add any post-install steps to the package() function if needed
#     (config files, completions, systemd units, etc.)
#   - Test with: makepkg -si in a clean Arch environment
#
set -euo pipefail

BINARY="$1"
VERSION="$2"
OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "OWNER_PLACEHOLDER")
REPO=$(gh repo view --json name -q .name 2>/dev/null || echo "${BINARY}")

mkdir -p dist

sed \
    -e "s/BINARY_PLACEHOLDER/${BINARY}/g" \
    -e "s/VERSION_PLACEHOLDER/${VERSION}/g" \
    -e "s/OWNER_PLACEHOLDER/${OWNER}/g" \
    -e "s/REPO_PLACEHOLDER/${REPO}/g" \
    packaging/aur/PKGBUILD.template > dist/PKGBUILD

echo "Built dist/PKGBUILD"
```

Make both scripts executable:
```
chmod +x scripts/build-deb.sh scripts/build-aur.sh
```

## Step 6 — Commit

```
git add packaging/ scripts/
git commit -m "chore(scaffold): add packaging templates and build scripts"
```

## Step 7 — Report

Confirm all packaging files were created and committed. Note the TODO items
that will need attention during the packaging finalisation tasks.
