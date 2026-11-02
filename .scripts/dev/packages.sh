#!/bin/bash
# Dev tool packages from the distro repos. Sourced by setup-dev.sh.
# Tools not taken from repos (installed per user by their own scripts):
#   sdkman (java, maven), nvm (node), miniconda, gf2 (built from source), CLion (JetBrains tarball)

DEV_PACKAGES_ARCH=(
    base-devel git curl zip unzip    # build tools + what the installers need
    gdb                              # debugger (gf2 frontend)
    freetype2 libx11                 # gf2 build deps
    rustup                           # rust toolchains (rustc, cargo)
    go
    tree-sitter-cli                  # nvim-treesitter parser builds
    docker docker-compose docker-buildx
    code                             # VS Code, open-source build (extensions from Open VSX)
)

DEV_PACKAGES_VOID=(
    base-devel git curl zip unzip
    gdb
    freetype-devel libX11-devel
    rustup
    go
    tree-sitter tree-sitter-cli
    docker docker-compose docker-buildx
    vscode                           # VS Code, open-source build (binary: code-oss)
)

# Removed first because they conflict with packages above.
DEV_CONFLICTING_ARCH=(
    rust        # distro rust conflicts with rustup
)
DEV_CONFLICTING_VOID=(
    rust cargo  # use rustup-managed toolchains instead
)
