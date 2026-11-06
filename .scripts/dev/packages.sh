#!/bin/bash
# Dev tool packages from the distro repos. Sourced by setup-dev.sh.
# Tools not taken from repos (installed per user by their own scripts):
#   sdkman (java, maven), nvm (node), miniconda, gf2 (built from source)
# CLion: Arch AUR (install_clion.sh), not available on Void.

DEV_PACKAGES_ARCH=(
    base-devel git curl zip unzip    # build tools + what the installers need
    gdb cmake                        # debugger (gf2, CLion) + C/C++ builds
    freetype2 libx11                 # gf2 build deps
    rustup                           # rust toolchains (rustc, cargo)
    go
    tree-sitter-cli                  # nvim-treesitter parser builds
    docker docker-compose docker-buildx
    postgresql
    code                             # VS Code, open-source build (extensions from Open VSX)
)

DEV_PACKAGES_VOID=(
    base-devel git curl zip unzip
    gdb cmake
    freetype-devel libX11-devel
    rustup
    go
    tree-sitter tree-sitter-cli
    docker docker-compose docker-buildx
    postgresql
    vscode                           # VS Code, open-source build (binary: code-oss)
)

# Removed first because they conflict with packages above.
DEV_CONFLICTING_ARCH=(
    rust        # distro rust conflicts with rustup
)
DEV_CONFLICTING_VOID=(
    rust cargo  # use rustup-managed toolchains instead
)
