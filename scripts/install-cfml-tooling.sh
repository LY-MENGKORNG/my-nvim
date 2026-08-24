#!/usr/bin/env bash
# Install/update the CFML toolchain used by lua/plugins/cfml.lua.
#
#   * cfmleditor-lsp      -> ~/.local/bin                      (Go LSP server)
#   * tree-sitter parsers -> ~/.local/share/nvim/site/parser   (cfml, cfscript, cfquery)
#   * queries             -> ~/.config/nvim/queries/<lang>
#
# Idempotent: re-run to upgrade. Requires curl, tar, git and a C compiler.
set -euo pipefail

LSP_VERSION="${LSP_VERSION:-v0.1.22}"
GRAMMAR_REF="${GRAMMAR_REF:-master}"

BIN_DIR="$HOME/.local/bin"
PARSER_DIR="$HOME/.local/share/nvim/site/parser"
QUERY_DIR="$HOME/.config/nvim/queries"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

case "$(uname -m)" in
  x86_64)          ARCH=amd64 ;;
  aarch64|arm64)   ARCH=arm64 ;;
  *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

echo "==> cfmleditor-lsp $LSP_VERSION (linux-$ARCH)"
mkdir -p "$BIN_DIR"
curl -fsSL -o "$WORK/lsp.tar.gz" \
  "https://github.com/cfmleditor/cfmleditor-lsp/releases/download/${LSP_VERSION}/cfmleditor-lsp-linux-${ARCH}.tar.gz"
tar xzf "$WORK/lsp.tar.gz" -C "$BIN_DIR" cfmleditor-lsp
chmod +x "$BIN_DIR/cfmleditor-lsp"
"$BIN_DIR/cfmleditor-lsp" version

echo "==> tree-sitter-cfml ($GRAMMAR_REF)"
git clone --depth 1 --branch "$GRAMMAR_REF" -q \
  https://github.com/cfmleditor/tree-sitter-cfml.git "$WORK/ts-cfml"

mkdir -p "$PARSER_DIR"
for g in cfml cfscript cfquery; do
  cc -shared -fPIC -O2 -I "$WORK/ts-cfml/$g/src" "$WORK/ts-cfml/$g"/src/*.c \
     -o "$PARSER_DIR/$g.so"
  echo "    built $g.so"

  mkdir -p "$QUERY_DIR/$g"
  for q in highlights injections indents folds textobjects; do
    src="$WORK/ts-cfml/$g/queries/$q.scm"
    [ -f "$src" ] && cp "$src" "$QUERY_DIR/$g/$q.scm"
  done
done

# --- Neovim compatibility patches for the upstream (Zed-oriented) queries -----
#
# 1. "(?i)" is Rust-regex syntax. Neovim prepends "\v" (very magic) to #match?
#    patterns, where "(?" is a misplaced quantifier -> E866, and even without
#    that the flag never matches. Rewrite to Vim's "\v\c" form.
# 2. "#is-not? local" has no handler in core Neovim; hitting it aborts the
#    entire highlights query for that language. The two rules using it are
#    JavaScript leftovers (module/console/window/document/require) that mean
#    nothing in CFML - ARGUMENTS is already covered by the CFML scopes rule.
python3 - "$QUERY_DIR" <<'PY'
import pathlib, sys
q = pathlib.Path(sys.argv[1])
dead = [
'''((identifier) @variable.builtin
 (#match? @variable.builtin "^(arguments|module|console|window|document)$")
 (#is-not? local))
''',
'''((identifier) @function.builtin
 (#eq? @function.builtin "require")
 (#is-not? local))
''']
for lang in ("cfml", "cfscript", "cfquery"):
    f = q / lang / "highlights.scm"
    if not f.exists():
        continue
    s = f.read_text()
    n = s.count("^(?i)(")
    s = s.replace("^(?i)(", "\\\\v\\\\c^(")
    for d in dead:
        s = s.replace(d, "")
    f.write_text(s)
    print(f"    patched {lang}: {n} regex, is-not? left={s.count('is-not?')}")
PY

echo
echo "Done. Per-project settings go in a .cfmleditor.json at the project root."
