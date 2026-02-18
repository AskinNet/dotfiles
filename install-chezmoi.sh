#!/bin/sh

set -e


if ! command -v chezmoi >/dev/null 2>&1; then
  bin_dir="$HOME/.local/bin"
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    echo "ERROR: curl or wget required" >&2
    exit 1
  fi
fi

# Инициализация с вашего GitHub-репозитория
exec chezmoi init AskinNet
