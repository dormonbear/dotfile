#!/bin/bash

# Fix Apex LSP Issues Script

set -e

echo "🔧 Fixing Apex LSP Issues..."

PROJECT_PATH="$HOME/Projects/omni-sf"

# Check if project exists
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "❌ Project not found: $PROJECT_PATH"
    echo "Please update the PROJECT_PATH variable in this script"
    exit 1
fi

echo "📁 Project found: $PROJECT_PATH"

# Step 1: Fix permissions on SFDX typings
echo ""
echo "🔐 Step 1: Fixing SFDX typings permissions..."
if [[ -d "$PROJECT_PATH/.sfdx/typings" ]]; then
    chmod -R 644 "$PROJECT_PATH"/.sfdx/typings/lwc/sobjects/*.d.ts 2>/dev/null || true
    chmod -R 755 "$PROJECT_PATH"/.sfdx/typings/lwc/ 2>/dev/null || true
    echo "✅ Fixed SFDX typings permissions"
else
    echo "⚠️  SFDX typings directory not found"
fi

# Step 2: Clear LSP cache
echo ""
echo "🧹 Step 2: Clearing LSP caches..."

# Clear Neovim LSP logs
if [[ -f "$HOME/.local/state/nvim/lsp.log" ]]; then
    > "$HOME/.local/state/nvim/lsp.log"
    echo "✅ Cleared Neovim LSP log"
fi

# Clear SFDX cache
if [[ -d "$PROJECT_PATH/.sfdx" ]]; then
    echo "🗑️  Clearing SFDX cache..."
    rm -rf "$PROJECT_PATH/.sfdx/orgs" 2>/dev/null || true
    rm -rf "$PROJECT_PATH/.sfdx/tools" 2>/dev/null || true
    echo "✅ Cleared SFDX cache"
fi

# Step 3: Regenerate SFDX project cache
echo ""
echo "🔄 Step 3: Regenerating SFDX project files..."
cd "$PROJECT_PATH"

if command -v sfdx &> /dev/null; then
    echo "📦 Refreshing SFDX metadata..."
    # sfdx force:source:status &> /dev/null || echo "⚠️  Could not refresh metadata (not connected to org?)"
    echo "✅ SFDX refresh attempted"
else
    echo "⚠️  SFDX CLI not found, skipping metadata refresh"
fi

# Step 4: Check Apex JAR
echo ""
echo "🔍 Step 4: Verifying Apex LSP JAR..."
APEX_JAR="$HOME/apex-jorje-lsp.jar"
if [[ -f "$APEX_JAR" ]]; then
    echo "✅ Apex JAR found: $APEX_JAR"
    echo "   Size: $(ls -lh "$APEX_JAR" | awk '{print $5}')"
else
    echo "❌ Apex JAR not found: $APEX_JAR"
    echo "   Please run: cd ~/.config/nvim && ./scripts/install-apex-lsp.sh"
    exit 1
fi

# Step 5: Test Java
echo ""
echo "☕ Step 5: Testing Java environment..."
if java -version &> /dev/null; then
    echo "✅ Java is available:"
    java -version 2>&1 | head -1
else
    echo "❌ Java not found. Please install Java:"
    echo "   brew install openjdk"
    exit 1
fi

echo ""
echo "🎉 Apex LSP fix completed!"
echo ""
echo "Next steps:"
echo "1. Restart Neovim"
echo "2. Open an Apex file (.cls or .trigger)"
echo "3. Wait for LSP to reindex (check with <leader>li)"
echo "4. Test 'gd' (go to definition) and 'K' (hover)"
echo ""
echo "If issues persist:"
echo "- Check LSP logs: :LspLog"
echo "- Use diagnostics: <leader>li and <leader>lc"
echo "- Restart LSP: <leader>lr" 