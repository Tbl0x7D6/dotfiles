#!/bin/bash

# Dotfiles 提取脚本
# 用于将系统配置文件复制到 dotfiles 目录

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
CONFIG_FILE="$SCRIPT_DIR/files.conf"

echo "开始提取配置文件到 $DOTFILES_DIR"

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

# 提取函数
extract_file() {
    local source="$1"
    local target="$2"

    # 展开环境变量
    source=$(eval echo "$source")

    if [[ -e "$source" ]]; then
        # 创建目标目录
        mkdir -p "$DOTFILES_DIR/$(dirname "$target")"

        if [[ -d "$source" ]]; then
            echo "复制目录: $source -> $target"
            # 如果目标目录已存在，先删除避免嵌套
            if [[ -d "$DOTFILES_DIR/$target" ]]; then
                rm -rf "$DOTFILES_DIR/$target"
            fi
            cp -r "$source" "$DOTFILES_DIR/$target"
        else
            echo "复制文件: $source -> $target"
            cp "$source" "$DOTFILES_DIR/$target"
        fi
    else
        echo "文件不存在: $source"
    fi
}

# 备份 Homebrew 软件包
backup_brew() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装，跳过备份"
        return
    fi

    echo "开始备份 Homebrew 软件包..."

    # 备份已安装的包列表
    brew list --formula > "$DOTFILES_DIR/Brewfile.packages" 2>/dev/null
    echo "已保存 formula 列表到 Brewfile.packages"

    # 备份已安装的 cask 列表
    brew list --cask > "$DOTFILES_DIR/Brewfile.casks" 2>/dev/null
    echo "已保存 cask 列表到 Brewfile.casks"

    # 生成完整的 Brewfile
    brew bundle dump --describe --force --file="$DOTFILES_DIR/Brewfile" 2>/dev/null
    echo "已生成 Brewfile"
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
        source="${BASH_REMATCH[1]}"
        target="${BASH_REMATCH[2]}"
        extract_file "$source" "$target"
    else
        echo "配置行格式错误: $line"
    fi
done < "$CONFIG_FILE"

# 备份 Homebrew（如果启用）
if [[ "$BACKUP_BREW" == "true" ]]; then
    backup_brew
fi

echo "配置文件提取完成！"
