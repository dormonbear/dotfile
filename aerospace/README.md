# AeroSpace 多模式配置系统

这个配置系统为 AeroSpace 窗口管理器提供了三种不同的显示器模式，可以根据您的工作环境自动或手动切换。

## 📋 三种模式

### 🏢 Office Mode (两台外接显示器)
- **左侧显示器 (DELL P2417H, 竖屏)**: 奇数工作区 (1, 3, 5, 7, 9)
- **右侧显示器 (DELL U2718QM, 横屏)**: 偶数工作区 (2, 4, 6, 8, 0)
- 适用于办公室环境，有两台外接显示器的情况

### 🏠 Home Mode (内置显示器 + 一台外接显示器)
- **内置显示器**: 主要工作区 (1, 2, 3, 4, 5)
- **外接显示器**: 辅助工作区 (6, 7, 8, 9, 0)
- 适用于家庭环境，笔记本 + 一台显示器的情况

### 💻 Single Mode (只有内置显示器)
- **内置显示器**: 所有工作区 (1-9, 0)
- 更紧凑的间距设置
- 适用于移动办公或只使用笔记本屏幕的情况

## 🚀 快速开始

### 1. 自动切换
```bash
cd ~/.config/aerospace
./switch-mode.sh auto
```

### 2. 手动切换
```bash
# 切换到 Office 模式
./switch-mode.sh office

# 切换到 Home 模式
./switch-mode.sh home

# 切换到 Single 模式
./switch-mode.sh single
```

### 3. 查看状态
```bash
./switch-mode.sh status
```

## 📁 文件结构

```
~/.config/aerospace/
├── aerospace.toml           # 当前活动配置
├── aerospace-office.toml    # Office 模式配置
├── aerospace-home.toml      # Home 模式配置
├── aerospace-single.toml    # Single 模式配置
├── switch-mode.sh           # 智能切换脚本
├── aerospace.toml.backup    # 配置备份
└── README.md               # 说明文档
```

## ⌨️ 快捷键说明

所有模式都使用相同的快捷键：

### 工作区切换
- `Alt + 1-9, 0`: 切换到对应工作区
- `Alt + Tab`: 在最近的两个工作区间切换
- `Alt + Ctrl + 1-9, 0`: 将工作区召唤到当前显示器

### 窗口操作
- `Alt + H/J/K/L`: 在窗口间导航 (左/下/上/右)
- `Alt + Shift + H/J/K/L`: 移动窗口
- `Alt + Shift + 1-9, 0`: 移动窗口到指定工作区
- `Alt + Space`: 切换浮动/平铺模式
- `Alt + Ctrl + F`: 全屏

### 布局调整
- `Alt + /`: 切换水平/垂直平铺
- `Alt + ,`: 切换手风琴布局
- `Alt + Shift + =/-`: 调整窗口大小

### 服务模式 (`Alt + Shift + ;`)
- `F`: 切换浮动/平铺布局
- `R`: 重置布局
- `B`: 平衡窗口大小
- `Esc`: 重新加载配置
- `Backspace`: 关闭除当前窗口外的所有窗口

## 🔧 高级用法

### 创建桌面快捷方式
```bash
./switch-mode.sh shortcuts
```
这会在桌面创建一个 "AeroSpace Shortcuts" 文件夹，包含各种模式的快捷方式。

### 自动化切换
您可以将切换脚本添加到以下位置实现自动化：

1. **登录时自动检测**：添加到 `~/.zshrc` 或 `~/.bashrc`
```bash
# 在 shell 配置文件中添加
~/.config/aerospace/switch-mode.sh auto >/dev/null 2>&1
```

2. **使用 Hammerspoon 监听显示器变化**
3. **使用 Raycast 创建快速切换命令**

### 应用程序自动分配

不同模式下应用程序的默认分配：

#### Office Mode
- Terminal (Ghostty) → 工作区 1 (左侧显示器)
- Browser/Notes/Chat → 工作区 2 (右侧显示器)
- IntelliJ → 工作区 3 (左侧显示器)
- Chrome Canary → 工作区 4 (右侧显示器)
- WebStorm → 工作区 5 (左侧显示器)

#### Home Mode
- 日常应用 (Terminal, Browser, Chat) → 内置显示器 (工作区 1-5)
- 开发工具 (IDE, Editor) → 外接显示器 (工作区 6-9)

#### Single Mode
- 所有应用分散在不同工作区以避免拥挤

## 🔍 故障排除

### 显示器未正确识别
1. 检查显示器连接
2. 运行 `./switch-mode.sh status` 查看当前状态
3. 手动指定模式而不是使用 auto

### 配置未生效
1. 确保 AeroSpace 正在运行
2. 运行 `aerospace reload-config` 手动重新加载
3. 检查 `aerospace.toml.backup` 是否存在备份

### 恢复默认配置
```bash
# 如果有备份
cp ~/.config/aerospace/aerospace.toml.backup ~/.config/aerospace/aerospace.toml

# 或者选择特定模式
./switch-mode.sh office  # 或 home、single
```

## 📝 自定义配置

您可以根据需要修改各个模式的配置文件：

- `aerospace-office.toml` - 办公室双显示器配置
- `aerospace-home.toml` - 家庭单外接显示器配置  
- `aerospace-single.toml` - 单显示器配置

修改后重新运行切换脚本即可应用更改。

## 🎯 最佳实践

1. **使用自动模式**: 大多数情况下使用 `auto` 让脚本自动检测
2. **合理分配应用**: 根据工作流程调整应用程序的自动分配
3. **备份配置**: 在大幅修改前备份您的配置文件
4. **快捷键习惯**: 熟练掌握工作区切换快捷键以提高效率

## 🤝 支持

如果遇到问题或有改进建议，请检查：
1. AeroSpace 官方文档：https://nikitabobko.github.io/AeroSpace/
2. 确认 AeroSpace 版本兼容性
3. 查看系统日志中的 AeroSpace 相关信息 