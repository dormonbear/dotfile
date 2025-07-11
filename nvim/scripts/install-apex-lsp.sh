#!/bin/bash

# Apex LSP Installation Script for Neovim

set -e

echo "=== Apex LSP Installation Script ==="

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java first:"
    echo "   brew install openjdk"
    echo "   or install from: https://adoptium.net/"
    exit 1
fi

echo "✅ Java is available:"
java -version

# Define variables
APEX_LSP_URL="https://github.com/forcedotcom/apex-jorje-lsp/releases/download/v0.0.2/apex-jorje-lsp.jar"
INSTALL_PATH="$HOME/apex-jorje-lsp.jar"

echo ""
echo "=== Downloading Apex LSP JAR ==="
echo "URL: $APEX_LSP_URL"
echo "Target: $INSTALL_PATH"

# Download the JAR file
if curl -L -o "$INSTALL_PATH" "$APEX_LSP_URL"; then
    echo "✅ Downloaded apex-jorje-lsp.jar successfully"
else
    echo "❌ Failed to download apex-jorje-lsp.jar"
    echo "Please manually download from:"
    echo "https://github.com/forcedotcom/apex-jorje-lsp/releases"
    exit 1
fi

# Verify the file
if [[ -f "$INSTALL_PATH" ]]; then
    echo "✅ File exists: $INSTALL_PATH"
    echo "   Size: $(ls -lh "$INSTALL_PATH" | awk '{print $5}')"
else
    echo "❌ File not found: $INSTALL_PATH"
    exit 1
fi

# Test the JAR file
echo ""
echo "=== Testing Apex LSP ==="
if java -jar "$INSTALL_PATH" --help &>/dev/null; then
    echo "✅ Apex LSP JAR is working correctly"
else
    echo "⚠️  Could not test JAR file (this might be normal)"
fi

echo ""
echo "=== Installation Complete ==="
echo "Apex LSP is installed at: $INSTALL_PATH"
echo ""
echo "Next steps:"
echo "1. Restart Neovim"
echo "2. Open an Apex file (.cls or .trigger)"
echo "3. Use :lua vim.lsp.buf.hover() to test LSP functionality"
echo "4. Use 'gd' to test go-to-definition"
echo ""
echo "Troubleshooting commands in Neovim:"
echo "- <leader>li : Show LSP info"
echo "- <leader>lc : Check Apex LSP status"
echo "- <leader>lr : Restart LSP" 