#!/bin/bash

# AeroSpace 智能模式切换脚本
# 用法: ./switch-mode.sh [office|home|single|auto]

CONFIG_DIR="$HOME/.config/aerospace"
MAIN_CONFIG="$HOME/.config/aerospace/aerospace.toml"

# 检测当前连接的显示器
detect_display_setup() {
    local monitors=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
    local builtin_check=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -i "built.*in" | wc -l | tr -d ' ')
    
    if [ "$monitors" -eq 2 ] && [ "$builtin_check" -eq 0 ]; then
        echo "office"  # 两台外接显示器
    elif [ "$monitors" -eq 1 ] && [ "$builtin_check" -gt 0 ]; then
        echo "single"  # 只有内置显示器
    elif [ "$monitors" -eq 2 ] && [ "$builtin_check" -gt 0 ]; then
        echo "home"    # 内置显示器 + 一台外接显示器
    else
        echo "unknown"
    fi
}

# 切换配置文件
switch_config() {
    local mode=$1
    local config_file=""
    
    case $mode in
        "office")
            config_file="$CONFIG_DIR/aerospace-office.toml"
            echo "🏢 切换到 Office Mode (两台外接显示器)"
            echo "   左侧显示器: 奇数工作区 (1,3,5,7,9)"
            echo "   右侧显示器: 偶数工作区 (2,4,6,8,0)"
            ;;
        "home")
            config_file="$CONFIG_DIR/aerospace-home.toml"
            echo "🏠 切换到 Home Mode (内置显示器 + 外接显示器)"
            echo "   内置显示器: 主要工作区 (1,2,3,4,5)"
            echo "   外接显示器: 辅助工作区 (6,7,8,9,0)"
            ;;
        "single")
            config_file="$CONFIG_DIR/aerospace-single.toml"
            echo "💻 切换到 Single Mode (只有内置显示器)"
            echo "   所有工作区在内置显示器"
            ;;
        *)
            echo "❌ 未知模式: $mode"
            return 1
            ;;
    esac
    
    if [ ! -f "$config_file" ]; then
        echo "❌ 配置文件不存在: $config_file"
        return 1
    fi
    
    # 备份当前配置
    cp "$MAIN_CONFIG" "$MAIN_CONFIG.backup"
    
    # 复制新配置
    cp "$config_file" "$MAIN_CONFIG"
    
    # 重新加载 AeroSpace 配置
    echo "🔄 重新加载 AeroSpace 配置..."
    aerospace reload-config
    
    echo "✅ 已成功切换到 $mode 模式"
}

# 显示帮助信息
show_help() {
    echo "AeroSpace 智能模式切换脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  office    切换到 Office Mode (两台外接显示器)"
    echo "  home      切换到 Home Mode (内置显示器 + 外接显示器)"
    echo "  single    切换到 Single Mode (只有内置显示器)"
    echo "  auto      自动检测显示器配置并切换"
    echo "  status    显示当前显示器状态"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 auto              # 自动检测并切换"
    echo "  $0 office            # 手动切换到 Office 模式"
    echo "  $0 status            # 查看当前状态"
}

# 显示状态
show_status() {
    local monitors=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
    local builtin_check=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -i "built.*in" | wc -l | tr -d ' ')
    
    echo "📊 当前显示器状态:"
    echo ""
    echo "连接的显示器:"
    aerospace list-monitors 2>/dev/null | while read line; do
        echo "  • $line"
    done
    echo ""
    echo "检测信息: $monitors 个显示器，内置显示器状态: $builtin_check"
    
    local detected_mode=$(detect_display_setup)
    echo "检测到的模式: $detected_mode"
    
    if [ -f "$MAIN_CONFIG.backup" ]; then
        echo "备份配置: 存在"
    else
        echo "备份配置: 不存在"
    fi
}

# 创建桌面快捷方式
create_shortcuts() {
    local shortcuts_dir="$HOME/Desktop/AeroSpace Shortcuts"
    mkdir -p "$shortcuts_dir"
    
    # 创建 Office Mode 快捷方式
    cat > "$shortcuts_dir/Office Mode.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
~/.config/aerospace/switch-mode.sh office
read -p "按任意键继续..."
EOF
    
    # 创建 Home Mode 快捷方式
    cat > "$shortcuts_dir/Home Mode.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
~/.config/aerospace/switch-mode.sh home
read -p "按任意键继续..."
EOF
    
    # 创建 Single Mode 快捷方式
    cat > "$shortcuts_dir/Single Mode.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
~/.config/aerospace/switch-mode.sh single
read -p "按任意键继续..."
EOF
    
    # 创建 Auto Mode 快捷方式
    cat > "$shortcuts_dir/Auto Switch.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
~/.config/aerospace/switch-mode.sh auto
read -p "按任意键继续..."
EOF
    
    chmod +x "$shortcuts_dir"/*.command
    echo "✅ 桌面快捷方式已创建在: $shortcuts_dir"
}

# 主逻辑
case "${1:-auto}" in
    "office"|"home"|"single")
        switch_config "$1"
        ;;
    "auto")
        detected_mode=$(detect_display_setup)
        if [ "$detected_mode" = "unknown" ]; then
            echo "❌ 无法自动检测显示器配置"
            show_status
            exit 1
        else
            echo "🔍 自动检测模式: $detected_mode"
            switch_config "$detected_mode"
        fi
        ;;
    "status")
        show_status
        ;;
    "shortcuts")
        create_shortcuts
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ 未知选项: $1"
        show_help
        exit 1
        ;;
esac 