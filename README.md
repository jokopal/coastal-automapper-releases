# CoastalAutoMapper Releases

## 📦 Installation

### Method 1: Direct Download
1. Download latest installer from [Releases](https://github.com/your-org/coastal-automapper-releases/releases)
2. Run `BlueMap-Setup-1.0.0.exe`
3. Follow installation wizard

### Method 2: Auto-updater
1. Install any version of BlueMap
2. Set environment variable: `BLUEMAP_AUTO_UPDATE=1`
3. Launch application - will auto-check for updates

## 🔄 Auto-updater Configuration

### Enable Auto-updater
```bash
# Method 1: Environment Variable
set BLUEMAP_AUTO_UPDATE=1
BlueMap.exe

# Method 2: System-wide (Recommended)
# Add to Windows Environment Variables
BLUEMAP_AUTO_UPDATE=1
```

### Disable Auto-updater
```bash
set BLUEMAP_AUTO_UPDATE=0
# or simply don't set the variable
```

## 📋 Version History

| Version | Release Date | Changelog | Download |
|---------|--------------|-----------|----------|
| 1.0.0 | 2026-01-31 | Initial release with auto-updater | [Download](updates/BlueMap-Setup-1.0.0.exe) |

## 🛠️ Development

### Build New Release
```bash
cd ../CoastalAutoMapper/electron
npm run release
```

### Deploy Update Server
```bash
cd update-server
npm install
node update-server.js
```

## 📊 Repository Structure

```
coastal-automapper-releases/
├── update-server/          # Update server files
│   ├── updates/            # Large installers (LFS)
│   └── update-server.js    # Node.js server
├── version.json            # Version tracking
├── scripts/                # Build automation
└── docs/                   # Documentation
```

## 🔒 Security

- All installers include SHA512 checksums
- Auto-updater validates file integrity before installation
- Updates can be disabled via environment variable
- No forced updates in development mode
