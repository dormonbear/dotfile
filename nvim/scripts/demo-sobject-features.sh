#!/bin/bash

# Salesforce SObject Features Demo
# This script demonstrates the new SObject definition viewing capabilities in Neovim

set -e

echo "🏗️  Salesforce SObject Features Demo"
echo "===================================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if we're in a Salesforce project
if [ ! -f "sfdx-project.json" ]; then
    echo "❌ Error: Not in a Salesforce project directory"
    echo "   Please run this script from a Salesforce project root"
    exit 1
fi

# Check Salesforce CLI
if ! command -v sf &> /dev/null; then
    echo "❌ Error: Salesforce CLI (sf) not found"
    echo "   Please install: npm install -g @salesforce/cli"
    exit 1
fi

# Check if authenticated
if ! sf org display &> /dev/null; then
    echo "❌ Error: Not authenticated to a Salesforce org"
    echo "   Please run: sf org login web"
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Demo script
echo "🎯 SObject Features Overview"
echo "============================"
echo ""
echo "The new Salesforce SObject features provide multiple ways to explore object definitions:"
echo ""

echo "1. 🔍 Quick Definition Lookup"
echo "   Keymap: <leader>so"
echo "   Command: :SObjectDescribe"
echo "   Description: Shows definition for word under cursor"
echo ""

echo "2. 📚 Browse All SObjects"
echo "   Keymap: <leader>sO"
echo "   Command: :SObjectList"
echo "   Description: Opens Telescope picker to browse all SObjects in your org"
echo ""

echo "3. 📄 TypeScript Definition Files"
echo "   Keymap: <leader>sf"
echo "   Command: :SObjectFile"
echo "   Description: Opens cached .d.ts file for SObject"
echo ""

echo "4. ✏️  Manual Lookup"
echo "   Keymap: <leader>sl"
echo "   Description: Prompts for SObject name and shows definition"
echo ""

echo "🚀 Demo Usage Examples"
echo "====================="
echo ""

echo "Example 1: Quick Lookup"
echo "-----------------------"
echo "In Neovim, place cursor on any SObject name and press <leader>so."
echo "This will immediately show the definition for that object."
echo ""

echo "Example 2: Browse All Objects"
echo "-----------------------------"
echo "Press <leader>sO (capital O) to open the SObject browser."
echo "You'll see a Telescope picker with all objects in your org."
echo "Type to filter, use arrow keys to navigate, Enter to select."
echo ""

echo "Example 3: Quick Lookup with Demo"
echo "---------------------------------"
echo "Create a simple Apex class with SObject references:"
echo ""

# Create demo Apex class
cat > demo.cls << 'EOF'
public class SObjectDemo {
    public void exampleMethod() {
        // Place cursor on any SObject name and press <leader>sd
        Account acc = new Account(Name = 'Test Account');
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting');
        
        // Custom objects work too:
        // CustomObject__c custom = new CustomObject__c();
    }
}
EOF

echo "Demo file created: demo.cls"
echo ""
echo "To try the quick lookup:"
echo "1. Open demo.cls in Neovim: nvim demo.cls"
echo "2. Place cursor on 'Account', 'Contact', or 'Opportunity'"
echo "3. Press <leader>so to see the object definition"
echo ""

echo "Example 3: TypeScript Definitions"
echo "---------------------------------"
echo "For Lightning Web Components development:"
echo "1. Place cursor on any SObject name"
echo "2. Press <leader>sf to open the TypeScript definition file"
echo "3. This is useful for autocomplete and type checking in LWC"
echo ""

echo "🎮 Interactive Demo"
echo "==================="
echo ""
echo "Available commands to try:"
echo ""
echo ":SObjectList              - Browse all SObjects"
echo ":SObjectDescribe Account  - Describe Account object"
echo ":SObjectFile Contact      - Open Contact TypeScript definition"
echo ""

# Show some sample SObjects if possible
echo "📊 Sample SObjects in your org:"
echo "==============================="

if sf sobject list --json &> /dev/null; then
    echo "Getting SObject list..."
    sf sobject list --json 2>/dev/null | jq -r '.result[:10][].name' | head -10 | while read sobject; do
        echo "  • $sobject"
    done
    echo "  ... and more"
else
    echo "Standard objects: Account, Contact, Opportunity, Lead, Case"
    echo "Check your org for custom objects ending with __c"
fi

echo ""
echo "🛠️  Advanced Usage"
echo "=================="
echo ""
echo "Definition Window Controls:"
echo "  q / Esc    - Close window"
echo "  /          - Search within definition"
echo "  n / N      - Next/previous search result"
echo ""

echo "Custom Objects:"
echo "  For custom objects, include the __c suffix"
echo "  Example: :SObjectDescribe CustomObject__c"
echo ""

echo "Namespaced Objects:"
echo "  For namespaced objects, include the namespace"
echo "  Example: :SObjectDescribe MyNamespace__CustomObject__c"
echo ""

echo "🔧 Troubleshooting"
echo "=================="
echo ""
echo "Common issues and solutions:"
echo ""
echo "1. 'SObject not found' error:"
echo "   - Check spelling (case-sensitive)"
echo "   - Include __c for custom objects"
echo "   - Verify object exists in your org"
echo ""

echo "2. No objects in list:"
echo "   - Check authentication: sf org display"
echo "   - Verify network connection"
echo "   - Ensure proper permissions"
echo ""

echo "3. TypeScript files not found:"
echo "   - Run: sf sobject list (generates typings)"
echo "   - Check .sfdx/typings/lwc/sobjects/ directory"
echo "   - Plugin falls back to API lookup if files missing"
echo ""

echo "📚 More Information"
echo "=================="
echo ""
echo "For detailed documentation, see:"
echo "  ~/.config/nvim/doc/salesforce-sobject-guide.md"
echo ""
echo "For Apex LSP troubleshooting:"
echo "  ~/.config/nvim/doc/apex-lsp-troubleshooting.md"
echo ""

echo "🎉 Demo Complete!"
echo "================="
echo ""
echo "You're ready to explore Salesforce SObjects in Neovim!"
echo ""
echo "Quick start:"
echo "1. Open Neovim in your Salesforce project"
echo "2. Open any Apex file and place cursor on SObject names"
echo "3. Press <leader>so to see object definition instantly"
echo "4. Press <leader>sO to browse all available SObjects"
echo ""

# Cleanup
if [ -f "demo.cls" ]; then
    echo "Cleaning up demo file..."
    rm demo.cls
fi

echo "Happy coding! 🚀" 