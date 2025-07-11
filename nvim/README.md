# 💤 LazyVim Configuration

A clean, organized, and optimized Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim) with enhanced Salesforce development support.

## ✨ Features

- 🚀 **Fast Startup** - Optimized lazy loading and minimal bloat
- 🎨 **Beautiful UI** - Catppuccin theme with modern interface
- 🛠️ **Salesforce Ready** - Complete Apex/Visualforce development setup
- 📝 **Smart Completion** - Enhanced LSP with auto-completion
- 🔍 **Powerful Search** - Telescope integration with project management
- 🧹 **Self-Maintaining** - Built-in cleanup and maintenance scripts
- ⌨️ **Intuitive Keymaps** - Organized and well-documented shortcuts

## 🏗️ Structure

```
nvim/
├── init.lua                   # Entry point
├── lua/
│   ├── config/               # Core configuration
│   │   ├── keymaps.lua      # Organized key mappings
│   │   ├── filetype.lua     # File type detection
│   │   └── plugins.lua      # Plugin categories overview
│   └── plugins/             # Plugin configurations (20+ files)
├── scripts/                 # Maintenance & demo scripts
│   ├── install-apex-lsp.sh  # Apex LSP installer
│   ├── fix-apex-lsp.sh      # Apex LSP troubleshooting
│   ├── cleanup-config.sh    # Configuration cleanup
│   ├── demo-sobject-features.sh # SObject features demo
│   └── test-sobject-features.sh # Interactive testing suite
└── doc/                     # Comprehensive documentation
```

## 🚀 Quick Start

1. **Backup existing config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration:**
   ```bash
   git clone <your-repo> ~/.config/nvim
   ```

3. **Start Neovim:**
   ```bash
   nvim
   ```
   Plugins will install automatically.

4. **For Salesforce development:**
   ```bash
   cd ~/.config/nvim
   ./scripts/install-apex-lsp.sh
   ```

## 📚 Documentation

- 📖 **[Complete Guide](doc/nvim-config-guide.md)** - Comprehensive configuration documentation
- 🔧 **[Apex LSP Troubleshooting](doc/apex-lsp-troubleshooting.md)** - Salesforce-specific setup
- 🏗️ **[SObject Definition Guide](doc/salesforce-sobject-guide.md)** - Enhanced SObject exploration with smart context detection

## ⌨️ Key Highlights

| Shortcut | Action |
|----------|--------|
| `<leader>fp` | Find Project |
| `<leader>cs` | Code Symbols Outline |
| `<leader>li` | LSP Status & Diagnostics |
| `<leader>so` | SObject Definition (cursor) |
| `<leader>sO` | Browse All SObjects |
| `<leader>sf` | SObject TypeScript File |
| `<leader>mp` | Salesforce Push |
| `<C-\>` | Toggle Terminal |
| `gd` | Go to Definition |
| `jj/jk/kj` | Exit Insert Mode |

## 🛠️ Maintenance

### Regular Cleanup
```bash
cd ~/.config/nvim
./scripts/cleanup-config.sh
```

### Fix Apex LSP Issues
```bash
./scripts/fix-apex-lsp.sh
```

### Health Check
```vim
:checkhealth
:Lazy check
:Mason
```

## 🎯 Optimizations Applied

### ✅ Performance Improvements
- [x] Lazy loading for all plugins
- [x] Removed redundant plugins (symbols-outline)
- [x] Optimized startup time
- [x] Efficient key mapping organization
- [x] Clean plugin configurations

### ✅ Code Organization
- [x] Categorized plugin structure
- [x] Unified configuration style
- [x] Comprehensive documentation
- [x] Maintenance automation
- [x] Error handling improvements

### ✅ Developer Experience
- [x] Enhanced Salesforce support
- [x] Improved LSP diagnostics
- [x] Better debugging tools
- [x] Quality of life improvements
- [x] Intuitive key mappings

## 📊 Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| Plugin Files | 23 mixed configs | 20 organized configs |
| Key Mappings | Scattered | Categorized & documented |
| Startup Time | Variable | Optimized lazy loading |
| Maintenance | Manual | Automated scripts |
| Documentation | Minimal | Comprehensive |
| LSP Issues | Common | Diagnostic tools |

## 💡 Configuration Philosophy

Based on LazyVim's foundation with these principles:

- **Simplicity** - Clean, understandable configurations
- **Performance** - Fast startup and responsive editing
- **Modularity** - Easy to customize and extend
- **Documentation** - Every feature explained
- **Maintenance** - Self-diagnosing and self-healing

## 🤝 Contributing

When adding features:
1. Follow existing patterns
2. Add proper documentation
3. Test thoroughly
4. Keep it simple

---

*Optimized and cleaned up configuration - ready for productive development!*
