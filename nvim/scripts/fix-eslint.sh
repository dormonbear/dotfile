#!/bin/bash

# Fix ESLint LSP Issues in Neovim

set -e

echo "🔧 Fixing ESLint LSP Issues"
echo "==========================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install with Mason
install_with_mason() {
    echo "📦 Installing ESLint tools with Mason..."
    nvim --headless -c "MasonInstall eslint-lsp" -c "qa" 2>/dev/null || echo "Mason install may have failed"
    nvim --headless -c "MasonInstall eslint_d" -c "qa" 2>/dev/null || echo "Mason install may have failed"
}

# Function to install globally with npm
install_globally() {
    if command_exists npm; then
        echo "🌐 Installing ESLint globally with npm..."
        npm install -g eslint @eslint/js eslint-lsp
        echo "✅ ESLint installed globally"
    else
        echo "❌ npm not found. Please install Node.js and npm first."
        return 1
    fi
}

echo ""
echo "🔍 Checking current ESLint status..."

# Check if ESLint is available
if command_exists eslint; then
    echo "✅ ESLint command found: $(which eslint)"
    eslint --version
else
    echo "❌ ESLint command not found"
fi

# Check if ESLint LSP is available
if command_exists vscode-eslint-language-server; then
    echo "✅ ESLint LSP found: $(which vscode-eslint-language-server)"
else
    echo "❌ ESLint LSP not found"
fi

echo ""
echo "🚀 Recommended solutions:"
echo ""

# Offer solutions
echo "1️⃣  Install with Mason (Recommended - integrated with Neovim)"
echo "2️⃣  Install globally with npm (System-wide)"
echo "3️⃣  Disable ESLint LSP temporarily"
echo "4️⃣  Check current setup"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📦 Installing ESLint tools with Mason..."
        
        # Check if Neovim is available
        if ! command_exists nvim; then
            echo "❌ Neovim not found"
            exit 1
        fi
        
        echo "  - Installing eslint-lsp..."
        nvim --headless +"lua require('mason.api.command').MasonInstall({'eslint-lsp'})" +qa 2>/dev/null || true
        
        echo "  - Installing eslint_d..."
        nvim --headless +"lua require('mason.api.command').MasonInstall({'eslint_d'})" +qa 2>/dev/null || true
        
        echo ""
        echo "✅ Mason installation completed"
        echo "📝 Note: You may need to restart Neovim for changes to take effect"
        ;;
        
    2)
        echo ""
        install_globally
        ;;
        
    3)
        echo ""
        echo "🚫 Disabling ESLint LSP temporarily..."
        
        # Create a temporary override
        cat > ~/.config/nvim/lua/config/disable-eslint.lua << 'EOF'
-- Temporary ESLint LSP disable
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "eslint" then
      vim.lsp.stop_client(client.id)
      vim.notify("ESLint LSP disabled (temporary)", vim.log.levels.WARN)
    end
  end,
})
EOF
        
        # Add require to init.lua if not exists
        if ! grep -q "disable-eslint" ~/.config/nvim/init.lua 2>/dev/null; then
            echo 'require("config.disable-eslint")' >> ~/.config/nvim/init.lua
        fi
        
        echo "✅ ESLint LSP temporarily disabled"
        echo "📝 To re-enable, delete ~/.config/nvim/lua/config/disable-eslint.lua"
        ;;
        
    4)
        echo ""
        echo "🔍 Current setup analysis:"
        echo ""
        
        # Check Mason installation
        if [[ -d "$HOME/.local/share/nvim/mason/bin" ]]; then
            echo "📁 Mason bin directory: $HOME/.local/share/nvim/mason/bin"
            ls -la "$HOME/.local/share/nvim/mason/bin" | grep -E "(eslint|vscode)" || echo "  No ESLint tools found"
        else
            echo "❌ Mason bin directory not found"
        fi
        
        echo ""
        echo "🌍 Global installations:"
        echo "  ESLint: $(which eslint 2>/dev/null || echo 'Not found')"
        echo "  npm: $(which npm 2>/dev/null || echo 'Not found')"
        echo "  node: $(which node 2>/dev/null || echo 'Not found')"
        
        echo ""
        echo "📝 Neovim LSP status:"
        echo "  Run in Neovim: :Mason to check installed tools"
        echo "  Run in Neovim: :LspInfo to check active servers"
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "🎯 Next steps:"
echo "1. Restart Neovim"
echo "2. Open a JavaScript/TypeScript file"
echo "3. Check LSP status with: :LspInfo"
echo "4. If issues persist, run: :Mason to install tools manually"
echo ""

echo "💡 Troubleshooting tips:"
echo "- Use :checkhealth mason to verify Mason setup"
echo "- Use :Mason to manage LSP tools"
echo "- Use <leader>li to check LSP status (custom keymap)"
echo ""

echo "✅ ESLint fix script completed!" 