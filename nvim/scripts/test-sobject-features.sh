#!/bin/bash

# Test script for Salesforce SObject enhanced features
# This script creates test Apex files to demonstrate the smart context detection

set -e

echo "🧪 Testing Enhanced SObject Features"
echo "===================================="
echo ""

# Check if we're in a config directory
if [ ! -d "nvim" ]; then
    echo "❌ Please run this script from ~/.config directory"
    exit 1
fi

# Create test directory
TEST_DIR="test-sobject"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Creating test Apex files..."

# Test file 1: Object declarations
cat > ObjectDeclarations.cls << 'EOF'
public class ObjectDeclarations {
    // Test 1: Simple object declarations
    // Place cursor on Account, Contact, Opportunity and test <leader>so
    Account acc = new Account(Name = 'Test Account');
    Contact con = new Contact(LastName = 'Test');
    Opportunity opp = new Opportunity(Name = 'Test Opp');
    
    // Test 2: Custom objects  
    // Place cursor on CustomObject__c and test <leader>so
    CustomObject__c custom = new CustomObject__c();
    
    // Test 3: Standard objects with namespace
    User currentUser = new User();
    Profile userProfile = new Profile();
}
EOF

# Test file 2: Field access patterns
cat > FieldAccess.cls << 'EOF'
public class FieldAccess {
    public void testFieldAccess() {
        Account acc = new Account();
        
        // Test 4: Direct field access
        // Place cursor on Name, Email, Phone and test <leader>so
        acc.Name = 'Test Account';
        acc.Phone = '555-1234';
        acc.Description = 'Test description';
        
        Contact con = new Contact();
        con.Email = 'test@example.com';
        con.AccountId = acc.Id;
        con.Birthdate = Date.today();
        
        // Test 5: Lookup field access
        // Place cursor on AccountId to see lookup relationship
        System.debug('Account ID: ' + con.AccountId);
    }
}
EOF

# Test file 3: SOQL queries
cat > SOQLQueries.cls << 'EOF'
public class SOQLQueries {
    public void testSOQLPatterns() {
        // Test 6: SOQL FROM clauses
        // Place cursor on Account, Contact, Opportunity and test <leader>so
        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Contact> contacts = [SELECT Id, Email FROM Contact];
        List<Opportunity> opps = [SELECT Id, Amount FROM Opportunity];
        
        // Test 7: SOQL field references
        // Place cursor on Name, Email, Amount and test <leader>so
        List<Account> richAccounts = [
            SELECT Id, Name, Phone, Description, Type 
            FROM Account 
            WHERE Name LIKE '%Test%'
        ];
        
        // Test 8: Complex SOQL with relationships
        List<Contact> contactsWithAccounts = [
            SELECT Id, Name, Email, Account.Name, Account.Type
            FROM Contact 
            WHERE Account.Name != null
        ];
    }
}
EOF

# Test file 4: Picklist and lookup examples
cat > PicklistAndLookups.cls << 'EOF'
public class PicklistAndLookups {
    public void testSpecialFields() {
        Account acc = new Account();
        
        // Test 9: Picklist fields
        // Place cursor on Type, Industry and test <leader>so to see picklist values
        acc.Type = 'Customer - Direct';
        acc.Industry = 'Technology';
        acc.Rating = 'Hot';
        
        Opportunity opp = new Opportunity();
        // Test 10: More picklist fields
        opp.StageName = 'Prospecting';
        opp.LeadSource = 'Web';
        opp.Type = 'New Customer';
        
        Contact con = new Contact();
        // Test 11: Lookup fields
        // Place cursor on AccountId, ReportsToId to see lookup relationships
        con.AccountId = acc.Id;
        con.ReportsToId = con.Id; // Self-lookup
    }
}
EOF

# Test file 5: Custom fields example
cat > CustomFields.cls << 'EOF'
public class CustomFields {
    public void testCustomFields() {
        // Test 12: Custom objects with custom fields
        // Note: These may not exist in your org, but test the pattern recognition
        
        // Place cursor on CustomObject__c and custom field names
        CustomObject__c custom = new CustomObject__c();
        custom.Custom_Field__c = 'Test Value';
        custom.Another_Custom_Field__c = 100;
        custom.Lookup_Field__c = 'some-id';
        
        // Test 13: Namespaced objects
        // MyNamespace__CustomObject__c nsCustom = new MyNamespace__CustomObject__c();
        // nsCustom.MyNamespace__Custom_Field__c = 'Namespaced Value';
    }
}
EOF

echo "✅ Test files created successfully!"
echo ""
echo "🎯 Testing Instructions:"
echo "========================"
echo ""
echo "1. Open any test file in Neovim:"
echo "   nvim $TEST_DIR/ObjectDeclarations.cls"
echo ""
echo "2. Test smart context detection:"
echo "   • Place cursor on 'Account' in line 4"
echo "   • Press <leader>so"
echo "   • Should show Account definition"
echo ""
echo "3. Test field-level detection:"
echo "   • Open FieldAccess.cls"
echo "   • Place cursor on 'Name' in 'acc.Name = ...'"
echo "   • Press <leader>so"
echo "   • Should show Account definition and jump to Name field"
echo ""
echo "4. Test SOQL pattern recognition:"
echo "   • Open SOQLQueries.cls"
echo "   • Place cursor on 'Contact' in 'FROM Contact'"
echo "   • Press <leader>so"
echo "   • Should show Contact definition"
echo ""
echo "5. Test enhanced field information:"
echo "   • Open PicklistAndLookups.cls"
echo "   • Place cursor on 'Type' in 'acc.Type = ...'"
echo "   • Press <leader>so"
echo "   • Should show Account definition with Type field highlighted"
echo "   • Look for picklist values in the definition window"
echo ""
echo "6. Test browse all SObjects:"
echo "   • Press <leader>sO (capital O)"
echo "   • Type to filter objects"
echo "   • Select any object to view definition"
echo ""
echo "7. Test command-line interface:"
echo "   :SObjectDescribe Account"
echo "   :SObjectDescribe Account Name"
echo "   :SObjectHelp"
echo ""
echo "8. Test definition window navigation:"
echo "   • In any definition window, try:"
echo "   • / to search for 'required'"
echo "   • * to search for word under cursor"
echo "   • n/N to navigate search results"
echo "   • q or Esc to close"
echo ""

echo "📊 Test File Summary:"
echo "===================="
echo "• ObjectDeclarations.cls - Basic object detection"
echo "• FieldAccess.cls - Field-level context detection"  
echo "• SOQLQueries.cls - SOQL pattern recognition"
echo "• PicklistAndLookups.cls - Special field types"
echo "• CustomFields.cls - Custom object patterns"
echo ""

echo "🎉 Ready to test! Try the examples above."
echo ""
echo "💡 Pro tip: Watch the notification messages to see what the system detected!"
echo ""
echo "🧹 Cleanup: rm -rf $TEST_DIR (when done testing)" 