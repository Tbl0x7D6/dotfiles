#!/bin/bash

# Dotfiles 安装脚本
# 用于将 dotfiles 目录中的配置文件安装到系统

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
CONFIG_FILE="$SCRIPT_DIR/files.conf"

echo "开始安装配置文件从 $DOTFILES_DIR"

# 读取brew配置
BACKUP_BREW=false
if grep -q "^BACKUP_BREW=true" "$CONFIG_FILE" 2>/dev/null; then
    BACKUP_BREW=true
fi

# 检查配置文件是否存在
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 安装函数
install_file() {
    local source="$1"
    local target="$2"

    # 展开环境变量
    target=$(eval echo "$target")

    if [[ -e "$DOTFILES_DIR/$source" ]]; then
        # 创建目标目录
        mkdir -p "$(dirname "$target")"

        # 备份现有文件
        if [[ -e "$target" ]]; then
            echo "备份现有文件: $target -> $target.backup"
            cp -r "$target" "$target.backup"
        fi

        if [[ -d "$DOTFILES_DIR/$source" ]]; then
            echo "安装目录: $source -> $target"
            cp -r "$DOTFILES_DIR/$source" "$target"
        else
            echo "安装文件: $source -> $target"
            cp "$DOTFILES_DIR/$source" "$target"
        fi
    else
        echo "源文件不存在: $DOTFILES_DIR/$source"
    fi
}

# 安装 Homebrew 软件包
install_brew() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装，跳过安装"
        echo "请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return
    fi

    echo "开始安装 Homebrew 软件包..."

    # 优先使用 Brewfile
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        echo "使用 Brewfile 安装软件包..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
        return
    fi

    # 备选方案：分别安装 packages 和 casks
    if [[ -f "$DOTFILES_DIR/Brewfile.packages" ]]; then
        echo "安装 formula 软件包..."
        while IFS= read -r package; do
            [[ -z "$package" ]] && continue
            echo "安装: $package"
            brew install "$package" 2>/dev/null || echo "安装失败: $package"
        done < "$DOTFILES_DIR/Brewfile.packages"
    fi

    if [[ -f "$DOTFILES_DIR/Brewfile.casks" ]]; then
        echo "安装 cask 应用..."
        while IFS= read -r cask; do
            [[ -z "$cask" ]] && continue
            echo "安装: $cask"
            brew install --cask "$cask" 2>/dev/null || echo "安装失败: $cask"
        done < "$DOTFILES_DIR/Brewfile.casks"
    fi
}

# 读取配置文件并处理每一行
while IFS= read -r line; do
    # 跳过注释和空行
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # 处理 brew 配置
    if [[ "$line" =~ ^BACKUP_BREW= ]]; then
        continue
    fi

    # 解析源路径和目标路径
    if [[ "$line" =~ ^([^:]+):(.+)$ ]]; then
        system_path="${BASH_REMATCH[1]}"
        dotfiles_path="${BASH_REMATCH[2]}"
        install_file "$dotfiles_path" "$system_path"
    else
        echo "配置行格式错误: $line"
    fi
done < "$CONFIG_FILE"

# 安装 Homebrew（如果启用）
if [[ "$BACKUP_BREW" == "true" ]]; then
    install_brew
fi

echo "配置文件安装完成！"
