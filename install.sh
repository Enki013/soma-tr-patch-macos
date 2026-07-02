#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$ROOT_DIR/patch"
DEFAULT_SOMA_DIR="/Applications/SOMA"
SOMA_DIR="${SOMA_DIR:-$DEFAULT_SOMA_DIR}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/Library/Application Support/SOMA-TR-Yama/backups}"
DRY_RUN=0

usage() {
  cat <<'USAGE'
SOMA Turkce Yama macOS installer

Usage:
  ./install.sh [--soma-dir /path/to/SOMA] [--backup-dir /path/to/backups] [--dry-run]

Options:
  --soma-dir     SOMA kurulum klasoru. Varsayilan: /Applications/SOMA
  --backup-dir   Orijinal dosyalarin yedeklenecegi klasor.
  --dry-run      Dosya kopyalamadan kontrol yapar.
  -h, --help     Yardim metnini gosterir.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --soma-dir)
      SOMA_DIR="$2"
      shift 2
      ;;
    --backup-dir)
      BACKUP_ROOT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Bilinmeyen arguman: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -d "$PATCH_DIR" ]]; then
  echo "Patch klasoru bulunamadi: $PATCH_DIR" >&2
  exit 1
fi

if [[ ! -d "$SOMA_DIR" ]]; then
  echo "SOMA klasoru bulunamadi: $SOMA_DIR" >&2
  echo "Ornek: ./install.sh --soma-dir '/Applications/SOMA'" >&2
  exit 1
fi

if [[ ! -d "$SOMA_DIR/Soma.app" && ! -d "$SOMA_DIR/Contents" ]]; then
  echo "Bu klasor SOMA kurulumu gibi gorunmuyor: $SOMA_DIR" >&2
  exit 1
fi

backup_dir="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
manifest="$backup_dir/manifest.txt"
patched_count=0

while IFS= read -r -d '' patch_file; do
  rel="${patch_file#$PATCH_DIR/}"
  target="$SOMA_DIR/$rel"

  if [[ ! -f "$target" ]]; then
    echo "Hedef dosya bulunamadi: $target" >&2
    exit 1
  fi

  patched_count=$((patched_count + 1))
done < <(find "$PATCH_DIR" -type f -name '*.lang' -print0)

echo "SOMA klasoru: $SOMA_DIR"
echo "Yama dosyasi: $patched_count"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run tamam: dosya kopyalanmadi."
  exit 0
fi

mkdir -p "$backup_dir"
: > "$manifest"

while IFS= read -r -d '' patch_file; do
  rel="${patch_file#$PATCH_DIR/}"
  target="$SOMA_DIR/$rel"
  backup_file="$backup_dir/$rel"

  mkdir -p "$(dirname "$backup_file")"
  cp -p "$target" "$backup_file"
  cp -p "$patch_file" "$target"
  printf '%s\n' "$rel" >> "$manifest"
  echo "Yuklendi: $rel"
done < <(find "$PATCH_DIR" -type f -name '*.lang' -print0 | sort -z)

echo
echo "Kurulum tamam."
echo "Yedek: $backup_dir"
echo "Geri almak icin:"
echo "  ./uninstall.sh --soma-dir \"$SOMA_DIR\" --backup-dir \"$backup_dir\""
