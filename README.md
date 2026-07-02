# SOMA Turkce Yama macOS Installer

Bu paket, Windows icin hazirlanmis **SOMA Turkce Yama** dosyalarini macOS SOMA kurulumuna uygulanabilir hale getirir.

## Kurulum

Terminal'de bu klasore girip:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

SOMA farkli bir klasordeyse:

```bash
./install.sh --soma-dir "/Applications/SOMA"
```

Kurulumdan once sadece kontrol yapmak icin:

```bash
./install.sh --dry-run
```

## Geri Alma

Installer, degistirdigi orijinal dosyalari otomatik yedekler.

```bash
./uninstall.sh
```

Belirli bir yedegi geri yuklemek icin:

```bash
./uninstall.sh --backup-dir "$HOME/Library/Application Support/SOMA-TR-Yama/backups/YYYYMMDD-HHMMSS"
```
