const express = require('express');
const path = require('path');
const fs = require('fs-extra');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Constants
const UPDATES_DIR = path.join(__dirname, 'updates');
const PLATFORM = 'win32';

// Ensure updates directory exists
fs.ensureDirSync(UPDATES_DIR);

// Helper function to get latest version info
async function getLatestVersion() {
  try {
    const files = await fs.readdir(UPDATES_DIR);
    const exeFiles = files.filter(file => file.endsWith('.exe'));
    
    if (exeFiles.length === 0) {
      return null;
    }

    // Get the latest .exe file (by modification time)
    let latestFile = null;
    let latestTime = 0;

    for (const file of exeFiles) {
      const filePath = path.join(UPDATES_DIR, file);
      const stats = await fs.stat(filePath);
      if (stats.mtime.getTime() > latestTime) {
        latestTime = stats.mtime.getTime();
        latestFile = file;
      }
    }

    if (!latestFile) {
      return null;
    }

    // Extract version from filename
    const versionMatch = latestFile.match(/(\d+\.\d+\.\d+)/);
    const version = versionMatch ? versionMatch[1] : '1.0.0';

    // Read SHA512 file if exists
    const sha512File = latestFile + '.sha512';
    let sha512 = '';
    
    try {
      const sha512Path = path.join(UPDATES_DIR, sha512File);
      if (await fs.pathExists(sha512Path)) {
        sha512 = await fs.readFile(sha512Path, 'utf8');
        sha512 = sha512.trim();
      }
    } catch (err) {
      console.warn('SHA512 file not found for', latestFile);
    }

    return {
      version,
      path: `/updates/${latestFile}`,
      sha512,
      releaseDate: new Date(latestTime).toISOString()
    };
  } catch (err) {
    console.error('Error getting latest version:', err);
    return null;
  }
}

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Update endpoint for auto-updater
app.get('/update/:platform/:version', async (req, res) => {
  const { platform, version } = req.params;
  
  if (platform !== PLATFORM) {
    return res.status(404).json({ error: 'Platform not supported' });
  }

  const latestVersion = await getLatestVersion();
  
  if (!latestVersion) {
    return res.status(404).json({ error: 'No updates available' });
  }

  // Check if there's a newer version
  if (latestVersion.version === version) {
    return res.status(204).send(); // No content - up to date
  }

  res.json(latestVersion);
});

// Serve update files
app.use('/updates', express.static(UPDATES_DIR));

// List all available updates
app.get('/updates', async (req, res) => {
  try {
    const files = await fs.readdir(UPDATES_DIR);
    const updates = files.filter(file => file.endsWith('.exe'));
    
    const updateList = await Promise.all(updates.map(async (file) => {
      const filePath = path.join(UPDATES_DIR, file);
      const stats = await fs.stat(filePath);
      const versionMatch = file.match(/(\d+\.\d+\.\d+)/);
      
      return {
        filename: file,
        version: versionMatch ? versionMatch[1] : 'unknown',
        size: stats.size,
        releaseDate: stats.mtime.toISOString(),
        downloadUrl: `/updates/${file}`
      };
    }));

    res.json(updateList);
  } catch (err) {
    res.status(500).json({ error: 'Failed to list updates' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Update server running at http://localhost:${PORT}`);
  console.log(`Updates directory: ${UPDATES_DIR}`);
  console.log(`Platform: ${PLATFORM}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});
