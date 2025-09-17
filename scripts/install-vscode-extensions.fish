#!/usr/bin/env fish

# List of extensions in publisher.name format
set extensions \
  bbenoist.nix \
  jnoortheen.nix-ide \
  kamadorueda.alejandra \
  golang.go \
  zxh404.vscode-proto3 \
  ms-python.vscode-pylance \
  ms-python.isort \
  ms-python.black-formatter \
  ms-toolsai.jupyter \
  ms-toolsai.jupyter-keymap \
  tamasfe.even-better-toml \
  zainchen.json \
  ms-vscode.cmake-tools \
  timonwong.shellcheck \
  foxundermoon.shell-format \
  editorconfig.editorconfig \
  dbaeumer.vscode-eslint \
  donjayamanne.githistory \
  mhutchie.git-graph \
  codezombiech.gitignore \
  oderwat.indent-rainbow \
  shardulm94.trailing-spaces \
  mechatroner.rainbow-csv \
  yzhang.markdown-all-in-one \
  bierner.markdown-checkbox \
  bierner.markdown-mermaid \
  bradlc.vscode-tailwindcss \
  catppuccin.catppuccin-vsc \
  bierner.emojisense \
  irongeek.vscode-env \
  eg2.vscode-npm-script \
  firefox-devtools.vscode-firefox-debug \
  bodil.file-browser \
  rioj7.commandonallfiles \
  dnicolson.binary-plist

# Detect VSCode command (code or code-insiders)
if type -q code
  set vscode_cmd code
else if type -q code-insiders
  set vscode_cmd code-insiders
else
  echo "❌ VSCode CLI not found. Please install 'code' command from VSCode."
  exit 1
end

echo "✅ Using VSCode command: $vscode_cmd"
echo

# Install each extension
for ext in $extensions
  if $vscode_cmd --list-extensions | grep -q "^$ext\$"
    echo "✅ Already installed: $ext"
  else
    echo "⬇️  Installing: $ext"
    $vscode_cmd --install-extension $ext
  end
end

echo
echo "🎉 All extensions processed!"