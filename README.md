# Dotfiles

我的macOS配置文件仓库。

## 使用方法

### 提取配置文件
将系统中的配置文件复制到 dotfiles 目录：
```bash
./extract.sh
```

### 安装配置文件
将 dotfiles 目录中的配置文件安装到系统：
```bash
./install.sh
```

## 配置文件管理

所有要备份的文件都在 `files.conf` 中配置。

### 配置格式
每行一个文件映射，格式为：
```
系统路径:dotfiles相对路径
```

### 示例配置
```bash
# Shell 配置
$HOME/.zshrc:zshrc
$HOME/.bashrc:bashrc

# 编辑器配置
$HOME/.vimrc:vimrc
$HOME/.config/nvim:config/nvim

# Git 配置
$HOME/.gitconfig:gitconfig

# 目录示例
$HOME/.config/alacritty:config/alacritty
```

### 配置说明
- 支持环境变量（如 `$HOME`）
- 支持文件和目录
- 自动创建必要的目录结构

## Homebrew 软件包管理

脚本支持自动备份和恢复 Homebrew 安装的软件包。

### 启用 Homebrew 备份
在 `files.conf` 中设置：
```bash
# Homebrew 配置
# 设置为 true 来备份/恢复 Homebrew 软件包
BACKUP_BREW=true
```

### 备份内容
- `Brewfile` - 完整的依赖清单（推荐）
- `Brewfile.packages` - formula 软件包列表
- `Brewfile.casks` - cask 应用列表

### 恢复说明
- 优先使用 `Brewfile` 进行完整恢复
- 如果没有 `Brewfile`，会分别安装 packages 和 casks
