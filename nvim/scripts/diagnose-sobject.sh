#!/bin/bash

# SObject功能诊断脚本
# 帮助检查<leader>so功能是否正常工作

echo "🔍 SObject 功能诊断"
echo "==================="
echo ""

# 检查配置文件是否存在
CONFIG_FILE="nvim/lua/plugins/salesforce-objects.lua"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "✅ 配置文件存在: $CONFIG_FILE"

# 检查语法错误
echo ""
echo "🔍 检查 Lua 语法..."
if lua -e "dofile('$CONFIG_FILE')" 2>/dev/null; then
    echo "✅ Lua 语法正确"
else
    echo "❌ Lua 语法错误，请检查配置文件"
    echo "运行以下命令查看详细错误："
    echo "lua -e \"dofile('$CONFIG_FILE')\""
    exit 1
fi

# 创建临时测试文件
echo ""
echo "📝 创建测试文件..."
TEST_FILE="test_sobject.cls"
cat > "$TEST_FILE" << 'EOF'
public class TestSObject {
    public void test() {
        Account acc = new Account();
        acc.Name = 'Test';
        Contact con = new Contact();
        con.Email = 'test@example.com';
    }
}
EOF

echo "✅ 测试文件已创建: $TEST_FILE"
echo ""

echo "🧪 测试步骤："
echo "============"
echo ""
echo "1. 重启 Neovim:"
echo "   请完全退出 Neovim 并重新启动以加载新配置"
echo ""
echo "2. 打开测试文件:"
echo "   nvim $TEST_FILE"
echo ""
echo "3. 测试 <leader>so 功能:"
echo "   • 将光标放在 'Account' 上"
echo "   • 按下 <leader>so"
echo "   • 应该显示 Account 对象定义"
echo ""
echo "4. 如果仍然不工作，在 Neovim 中运行以下命令检查："
echo ""
echo "   :lua print('Testing SObject function')"
echo "   :lua vim.notify('SObject test', vim.log.levels.INFO)"
echo "   :WhichKey <leader>s  -- 查看所有 <leader>s 开头的快捷键"
echo "   :verbose map <leader>so  -- 检查快捷键是否已定义"
echo ""
echo "5. 检查错误信息："
echo "   :messages  -- 查看所有系统消息"
echo "   :checkhealth  -- 运行健康检查"
echo ""
echo "6. 手动测试命令："
echo "   :SObjectHelp  -- 显示帮助信息"
echo "   :SObjectDescribe Account  -- 手动查询 Account"
echo ""

# 检查依赖
echo "🔍 检查依赖..."
echo ""

# 检查 sf CLI
if command -v sf &> /dev/null; then
    echo "✅ Salesforce CLI (sf) 已安装"
    SF_VERSION=$(sf --version 2>/dev/null | head -1)
    echo "   版本: $SF_VERSION"
else
    echo "⚠️  Salesforce CLI (sf) 未安装"
    echo "   这可能影响某些功能，但基本的 SObject 定义查看仍应该工作"
fi

# 检查项目类型
if [ -f "sfdx-project.json" ]; then
    echo "✅ 检测到 Salesforce 项目 (sfdx-project.json)"
else
    echo "⚠️  当前目录不是 Salesforce 项目"
    echo "   某些功能可能受限，但基本的对象定义查看应该仍然可用"
fi

echo ""
echo "🎯 常见解决方案："
echo "================"
echo ""
echo "如果 <leader>so 仍然不工作："
echo ""
echo "1. 完全重启 Neovim"
echo "   有时配置需要完全重启才能生效"
echo ""
echo "2. 检查 LazyVim 插件状态："
echo "   在 Neovim 中运行 :Lazy"
echo "   确保所有插件都已正确加载"
echo ""
echo "3. 检查快捷键冲突："
echo "   在 Neovim 中运行 :verbose map <leader>so"
echo "   看是否有其他插件占用了这个快捷键"
echo ""
echo "4. 临时使用命令模式："
echo "   如果快捷键不工作，可以直接使用命令："
echo "   :SObjectDescribe Account"
echo ""
echo "5. 查看日志文件："
echo "   ~/.local/state/nvim/lsp.log"
echo "   ~/.cache/nvim/lazy.log"
echo ""

echo "🧹 清理测试文件..."
rm -f "$TEST_FILE"
echo "✅ 清理完成"
echo ""
echo "📞 如果问题仍然存在，请提供以下信息："
echo "   1. Neovim 版本 (:version)"
echo "   2. 错误消息 (:messages)"
echo "   3. 插件状态 (:Lazy)"
echo "   4. 快捷键状态 (:verbose map <leader>so)" 