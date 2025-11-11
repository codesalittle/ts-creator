# 📦 Timestamp Creator

A fast, robust Windows batch utility for creating timestamped, versioned archives of your projects with a single command.

## ✨ Features

- **🚀 Fast Staging** - Uses `robocopy` for high-speed file copying
- **⏰ Stable Timestamps** - Consistent `yyyy-MM-dd_HH-mm-ss` formatting via PowerShell
- **📝 Project Metadata** - Generates a beautiful `INFO.md` with icons and details
- **🎛️ node_modules Control** - Choose whether to include or exclude dependencies when working with Node
- **✅ Full Validation** - Verifies archive creation and non-zero size
- **🛡️ Error Handling** - Detailed error messages and non-zero exit codes
- **🧹 Auto Cleanup** - Removes temporary staging folders automatically

## 📋 Requirements

- Windows 7 or later
- PowerShell 5.0+ (included with Windows 10/11)
- Command Prompt or PowerShell terminal

## 🚀 Quick Start

1. **Download** `ts-creator.bat`
2. **Place** it in your projects parent directory
3. **Run** from Command Prompt:
   ```cmd ts-creator.bat
   ```
4. **Follow** the interactive prompts
5. **Find** your archive in the `exports\` folder

## 💡 Usage

### Interactive Mode

Run the script and answer the prompts:

```
Enter project folder name (blank = auto-select most recent): my-app
Enter project version (default = 1.0): 2.3.1
Include node_modules? (Y/N, default = N): N
```

### Result

```
exports/
└── my-app_v2.3.1.zip
    ├── my-app/              (your entire project)
    │   ├── src/
    │   ├── package.json
    │   └── ...
    └── INFO.md              (metadata file)
```

### INFO.md Contents

The generated `INFO.md` includes:

- 📦 Project name
- 🏷️ Version number
- ⏰ Timestamp (human-readable)
- 📋 node_modules inclusion status
- 📝 Notes about the archive

## ⚙️ Configuration Options

### Auto-Select Project

Leave project name blank to automatically select the most recently modified folder:

```
Enter project folder name (blank = auto-select most recent): [ENTER]
```

### Default Version

Press Enter without typing to use version `1.0`:

```
Enter project version (default = 1.0): [ENTER]
```

### Exclude node_modules (Default)

Press Enter or type `N` to exclude dependencies:

```
Include node_modules? (Y/N, default = N): [ENTER]
```

This significantly reduces archive size and creation time.

## 📁 Output Structure

### Archive Naming Convention

```
<project-name>_v<version>.zip
```

Examples:
- `my-app_v1.0.zip`
- `api-server_v2.3.1.zip`
- `website_v1.0.0-beta.zip`

### Archive Contents

The ZIP file contains:
1. **Project folder** - Complete copy with all files
2. **INFO.md** - Archive metadata at root level

This structure allows easy extraction while keeping metadata accessible.

## 🔧 Advanced Features

### Timestamp Format

- **Filename**: `yyyy-MM-dd_HH-mm-ss` (filesystem-safe)
- **Display**: `yyyy-MM-dd HH:mm:ss` (human-readable)
- **Locale-safe**: Works across different Windows language settings

### Robocopy Exclusions

When excluding `node_modules`, the script uses:
```batch
robocopy /E /XD node_modules
```

### Compression Level

Uses PowerShell's `Optimal` compression for best size reduction:
```powershell
Compress-Archive -CompressionLevel Optimal
```

## 🛡️ Error Handling

The script handles common issues:

- ❌ **Project folder not found** - Exits with clear error message
- ❌ **Permission denied** - Reports inability to create folders/files
- ❌ **ZIP creation failed** - Cleans up and exits with error code
- ❌ **Empty ZIP file** - Detects zero-byte archives
- ⚠️ **Temp folder cleanup failed** - Warns but continues (leaves path for manual deletion)

All failures return non-zero exit codes for automation/scripting.

## 📊 Performance

Typical performance on modern hardware:

| Project Size | Files | Time (excl. node_modules) | Archive Size |
|--------------|-------|---------------------------|--------------|
| Small        | ~100  | 2-3 seconds               | 1-5 MB       |
| Medium       | ~1000 | 5-10 seconds              | 10-50 MB     |
| Large        | ~5000 | 20-30 seconds             | 50-200 MB    |

*Including `node_modules` significantly increases both time and size.*

## 🐛 Troubleshooting

### "PowerShell is not recognized"

Ensure PowerShell is in your PATH. Try:
```cmd
powershell -Version
```

### "Access is denied"

Run Command Prompt as Administrator or check folder permissions.

### "Temp folder couldn't be deleted"

The script will warn you and provide the path. Manually delete:
```cmd
rd /s /q "C:\Users\...\Temp\project_staging_..."
```

### Compression is slow

Large projects take time. To speed up:
- Exclude `node_modules` (default)
- Archive to an SSD
- Close other intensive applications

## 🔄 Integration

### Use in CI/CD

```batch
call timestamp_project.bat
if errorlevel 1 (
    echo Archive creation failed
    exit /b 1
)
```

### Automation Example

Create a wrapper script to skip prompts (requires modification):
```batch
@echo off
echo my-project> input.txt
echo 1.0>> input.txt
echo N>> input.txt
timestamp_project.bat < input.txt
```

## 📄 License

This project is released under the MIT License