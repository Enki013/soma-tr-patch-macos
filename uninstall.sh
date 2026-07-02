#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SOMA_DIR="/Applications/SOMA"
SOMA_DIR="${SOMA_DIR:-$DEFAULT_SOMA_DIR}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/Library/Application Support/SOMA-TR-Yama/backups}"
BACKUP_DIR=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
SOMA Turkce Yama macOS uninstaller

Usage:
  ./uninstall.sh [--soma-dir /path/to/SOMA] [--backup-dir /path/to/backup] [--dry-run]

Options:
  --soma-dir     SOMA kurulum klasoru. Varsayilan: /Applications/SOMA
  --backup-dir   Geri yuklenecek yedek klasoru. Verilmezse en yeni yedek kullanilir.
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
      BACKUP_DIR="$2"
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

if [[ -z "$BACKUP_DIR" ]]; then
  if [[ ! -d "$BACKUP_ROOT" ]]; then
    echo "Yedek klasoru bulunamadi: $BACKUP_ROOT" >&2
    exit 1
  fi
  BACKUP_DIR="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
fi

if [[ -z "$BACKUP_DIR" || ! -d "$BACKUP_DIR" ]]; then
  echo "Gecerli yedek bulunamadi." >&2
  exit 1
fi

manifest="$BACKUP_DIR/manifest.txt"
if [[ ! -f "$manifest" ]]; then
  echo "Yedek manifest dosyasi yok: $manifest" >&2
  exit 1
fi

if [[ ! -d "$SOMA_DIR" ]]; then
  echo "SOMA klasoru bulunamadi: $SOMA_DIR" >&2
  exit 1
fi

restore_count=0
while IFS= read -r rel; do
  [[ -z "$rel" ]] && continue
  backup_file="$BACKUP_DIR/$rel"
  target="$SOMA_DIR/$rel"

  if [[ ! -f "$backup_file" ]]; then
    echo "Yedek dosya eksik: $backup_file" >&2
    exit 1
  fi

  if [[ ! -f "$target" ]]; then
    echo "Hedef dosya bulunamadi: $target" >&2
    exit 1
  fi

  restore_count=$((restore_count + 1))
done < "$manifest"

echo "SOMA klasoru: $SOMA_DIR"
echo "Yedek: $BACKUP_DIR"
echo "Geri yuklenecek dosya: $restore_count"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run tamam: dosya kopyalanmadi."
  exit 0
fi

while IFS= read -r rel; do
  [[ -z "$rel" ]] && continue
  cp -p "$BACKUP_DIR/$rel" "$SOMA_DIR/$rel"
  echo "Geri yuklendi: $rel"
done < "$manifest"

echo
echo "Geri yukleme tamam."
