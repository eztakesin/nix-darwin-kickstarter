#!/usr/bin/env fish

# Required tools
for tool in curl jq unzip nix-hash
    if not type -q $tool
        echo "❌ Missing required tool: $tool"
        exit 1
    end
end

# Detect VSCode command
if type -q code
    set code_cmd code
else if type -q codium
    set code_cmd codium
else
    echo "❌ VSCode or VSCodium not found in PATH"
    exit 1
end

# Trap SIGINT to clean up temp dirs
function on_interrupt --on-signal INT
    echo "🧹 Cleaning up temp dirs..."
    rm -rf /tmp/vscode_exts_*
    exit 1
end

# List of extensions to exclude (managed by Nix)
set exclude_list \
  rust-lang.rust-analyzer \
  ms-python.python \
  njpwerner.autodocstring \
  ms-toolsai.jupyter-renderers \
  graphql.vscode-graphql \
  prisma.prisma \
  cweijan.vscode-database-client2 \
  esbenp.prettier-vscode \
  davidanson.vscode-markdownlint \
  gencer.html-slim-scss-css-class-completion \
  styled-components.vscode-styled-components \
  gruntfuggly.todo-tree \
  pkief.material-icon-theme \
  ms-vscode.hexeditor \
  streetsidesoftware.code-spell-checker \
  ms-vscode.anycode \
  wix.vscode-import-cost \
  christian-kohler.path-intellisense \
  alexdima.copy-relative-path

# Function to check if an extension is in the exclude list
function is_excluded
    set ext $argv[1]
    for e in $exclude_list
        if test "$e" = "$ext"
            return 0
        end
    end
    return 1
end

# Function to fetch version and hash of an extension
function get_vsixpkg
    set publisher $argv[1]
    set name $argv[2]
    set full "$publisher.$name"

    set tmpdir (mktemp -d -t vscode_exts_XXXXXXXX)
    set zipfile "$tmpdir/$full.zip"
    set url "https://$publisher.gallery.vsassets.io/_apis/public/gallery/publisher/$publisher/extension/$name/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

    if not curl --silent --show-error --retry 3 --fail -L -o $zipfile $url
        echo "❌ Failed to download $full" >&2
        rm -rf $tmpdir
        return
    end

    set ext_version (unzip -qc $zipfile extension/package.json | jq -r .version)
    set ext_hash (nix-hash --flat --sri --type sha256 $zipfile)

    rm -rf $tmpdir

    echo "  {"
    echo "    name = \"$name\";"
    echo "    publisher = \"$publisher\";"
    echo "    version = \"$ext_version\";"
    echo "    sha256 = \"$ext_hash\";"
    echo "  }"
end

# Begin Nix output
echo "{ extensions = ["

for ext in ($code_cmd --list-extensions)
    if is_excluded $ext
        echo "⚠️  Skipping excluded extension: $ext" >&2
        continue
    end

    set publisher (echo $ext | cut -d. -f1)
    set name (echo $ext | cut -d. -f2-)
    get_vsixpkg $publisher $name
end

echo "]; }"