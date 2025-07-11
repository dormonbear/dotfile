#!/bin/bash

# Neovim Configuration Cleanup & Maintenance Script

set -e

echo "🧹 Neovim Configuration Cleanup & Maintenance"
echo "=============================================="

NVIM_CONFIG="$HOME/.config/nvim"
NVIM_DATA="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"

# Function to get directory size
get_size() {
    if [[ -d "$1" ]]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "N/A"
    fi
}

# Function to backup directory
backup_dir() {
    local dir="$1"
    local backup_name="$2"
    if [[ -d "$dir" ]]; then
        cp -r "$dir" "${dir}_backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        echo "✅ Backed up $backup_name"
    fi
}

echo ""
echo "📊 Current sizes:"
echo "  Config: $(get_size "$NVIM_CONFIG")"
echo "  Data:   $(get_size "$NVIM_DATA")"
echo "  State:  $(get_size "$NVIM_STATE")"
echo "  Cache:  $(get_size "$NVIM_CACHE")"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with cleanup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting cleanup process..."

# 1. Clean plugin cache and data
echo ""
echo "🗑️  Step 1: Cleaning plugin data..."
if [[ -d "$NVIM_DATA/lazy" ]]; then
    echo "  - Cleaning Lazy.nvim cache..."
    rm -rf "$NVIM_DATA/lazy/state.json" 2>/dev/null || true
    rm -rf "$NVIM_DATA/lazy/cache" 2>/dev/null || true
fi

# 2. Clean LSP logs and cache
echo ""
echo "📝 Step 2: Cleaning LSP data..."
if [[ -f "$NVIM_STATE/lsp.log" ]]; then
    size=$(get_size "$NVIM_STATE/lsp.log")
    echo "  - LSP log size: $size"
    > "$NVIM_STATE/lsp.log"  # Truncate instead of delete
    echo "  ✅ Truncated LSP log"
fi

# Clean mason data
if [[ -d "$NVIM_DATA/mason" ]]; then
    echo "  - Cleaning Mason cache..."
    rm -rf "$NVIM_DATA/mason/download" 2>/dev/null || true
    rm -rf "$NVIM_DATA/mason/.cache" 2>/dev/null || true
fi

# 3. Clean swap, undo, and backup files
echo ""
echo "💾 Step 3: Cleaning temporary files..."
for dir in "swap" "undo" "backup"; do
    target_dir="$NVIM_STATE/$dir"
    if [[ -d "$target_dir" ]]; then
        file_count=$(find "$target_dir" -type f 2>/dev/null | wc -l)
        if [[ $file_count -gt 0 ]]; then
            echo "  - Cleaning $dir files ($file_count files)..."
            rm -rf "$target_dir"/* 2>/dev/null || true
        fi
    fi
done

# 4. Clean cache
echo ""
echo "🗂️  Step 4: Cleaning cache..."
if [[ -d "$NVIM_CACHE" ]]; then
    echo "  - Cleaning general cache..."
    rm -rf "$NVIM_CACHE"/* 2>/dev/null || true
fi

# 5. Clean treesitter parsers (optional)
echo ""
read -p "Do you want to clean TreeSitter parsers? (they will be re-downloaded) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ -d "$NVIM_DATA/nvim-treesitter" ]]; then
        echo "  - Cleaning TreeSitter parsers..."
        rm -rf "$NVIM_DATA/nvim-treesitter" 2>/dev/null || true
        echo "  ✅ TreeSitter parsers cleaned"
    fi
fi

# 6. Validate configuration
echo ""
echo "🔍 Step 5: Validating configuration..."
if command -v nvim &> /dev/null; then
    echo "  - Testing Neovim startup..."
    if nvim --headless -c "lua vim.print('Config OK')" -c "qa" 2>/dev/null; then
        echo "  ✅ Configuration is valid"
    else
        echo "  ⚠️  Configuration may have issues"
    fi
else
    echo "  ⚠️  Neovim not found in PATH"
fi

# 7. Check for orphaned plugins
echo ""
echo "🔌 Step 6: Checking for orphaned plugins..."
if [[ -d "$NVIM_DATA/lazy" ]]; then
    echo "  - Plugin directories:"
    ls -la "$NVIM_DATA/lazy" 2>/dev/null | grep "^d" | wc -l | xargs echo "    Total plugins installed:"
fi

# 8. Configuration summary
echo ""
echo "📋 Step 7: Configuration summary..."
echo "  - Plugin files:"
find "$NVIM_CONFIG/lua/plugins" -name "*.lua" 2>/dev/null | wc -l | xargs echo "    Custom plugins:"
echo "  - Key configuration files:"
for file in "init.lua" "lua/config/keymaps.lua" "lua/config/options.lua" "lua/config/lazy.lua"; do
    if [[ -f "$NVIM_CONFIG/$file" ]]; then
        echo "    ✅ $file"
    else
        echo "    ❌ $file (missing)"
    fi
done

echo ""
echo "📊 After cleanup sizes:"
echo "  Config: $(get_size "$NVIM_CONFIG")"
echo "  Data:   $(get_size "$NVIM_DATA")"
echo "  State:  $(get_size "$NVIM_STATE")"
echo "  Cache:  $(get_size "$NVIM_CACHE")"

echo ""
echo "🎉 Cleanup completed!"
echo ""
echo "📝 Recommendations:"
echo "  1. Restart Neovim to ensure everything works"
echo "  2. Run :Lazy sync to update plugins"
echo "  3. Run :Mason to check tool installations"
echo "  4. Test your most used features"
echo ""
echo "📖 If you encounter issues:"
echo "  - Check :checkhealth"
echo "  - Review error messages with :messages"
echo "  - Check LSP status with <leader>li"
echo ""

# Optional: Show plugin statistics
if command -v nvim &> /dev/null; then
    echo "🔌 Plugin statistics:"
    echo "  To see detailed plugin info, run in Neovim:"
    echo "    :Lazy profile"
    echo "    :Lazy log"
fi 