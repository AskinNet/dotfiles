#!/bin/bash
# Устанавливаем Zap, если его нет
if [ ! -d "$HOME/.local/share/zap" ]; then
    git clone https://github.com/zap-zsh/zap.git "$HOME/.local/share/zap" --branch release-v1
fi
