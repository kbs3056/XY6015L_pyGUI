#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$ROOT_DIR/.venv"
PYTHON_EXE=""

find_python() {
  if [[ -x "$VENV_DIR/bin/python" ]]; then
    PYTHON_EXE="$VENV_DIR/bin/python"
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    PYTHON_EXE="$(command -v python3)"
    return 0
  fi

  return 1
}

if ! find_python; then
  echo "Python 3 not found."
  echo "Install Python 3 and run this script again."
  exit 1
fi

echo "Using Python:"
echo "$PYTHON_EXE"

if [[ "$PYTHON_EXE" != "$VENV_DIR/bin/python" ]]; then
  if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    "$PYTHON_EXE" -m venv "$VENV_DIR"
  fi
  PYTHON_EXE="$VENV_DIR/bin/python"
fi

"$PYTHON_EXE" -m pip install --upgrade pip
"$PYTHON_EXE" -m pip install -r "$ROOT_DIR/source_files/requirements.txt"

if ! "$PYTHON_EXE" -m PyInstaller --version >/dev/null 2>&1; then
  echo "PyInstaller not found. Installing it now..."
  "$PYTHON_EXE" -m pip install pyinstaller
fi

cd "$ROOT_DIR"
"$PYTHON_EXE" -m PyInstaller --clean --noconfirm XYGUI.spec

echo
echo "Build complete."
echo "Application folder:"
echo "$ROOT_DIR/dist/XYGUI"
