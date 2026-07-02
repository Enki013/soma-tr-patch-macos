# SOMA Turkish Localization macOS Installer

This package adapts the **SOMA Turkish localization patch**, originally prepared for Windows, so it can be applied to the macOS version of SOMA.

## Installation

Open Terminal, enter this folder, and run:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

If SOMA is installed in a different location, specify its path manually:

```bash
./install.sh --soma-dir "/Applications/SOMA"
```

To check what the installer would do without making any changes, run:

```bash
./install.sh --dry-run
```

## Uninstall / Restore

The installer automatically creates backups of the original files it modifies.

To restore the latest backup:

```bash
./uninstall.sh
```

To restore a specific backup:

```bash
./uninstall.sh --backup-dir "$HOME/Library/Application Support/SOMA-TR-Yama/backups/YYYYMMDD-HHMMSS"
```

## Notes

* This installer is intended for the macOS version of SOMA.
* The localization files are based on the Turkish patch originally prepared for Windows.
* Always make sure the game is closed before installing or uninstalling the patch.
