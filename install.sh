#!/bin/bash
# raspi-config-cn 安装脚本
# 版本: version-20260303--cn--1.0
# 作者: xiaciyidingde

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main"
INSTALL_DIR="/usr/local/bin"
TARGET_FILE="raspi-config-cn"
SYMLINK_NAME="smp"
EXPECTED_VERSION="20260303"

print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 权限运行此脚本"
        echo "使用方法: sudo bash install.sh"
        exit 1
    fi
}



# 检查版本兼容性
check_version() {
    if command -v dpkg &> /dev/null; then
        INSTALLED_VERSION=$(dpkg -s raspi-config 2>/dev/null | grep "^Version:" | awk '{print $2}' | cut -d'-' -f1 || echo "unknown")
        if [ "$INSTALLED_VERSION" != "$EXPECTED_VERSION" ] && [ "$INSTALLED_VERSION" != "unknown" ]; then
            print_warning "检测到 raspi-config 版本: $INSTALLED_VERSION"
            print_warning "本汉化版基于版本: $EXPECTED_VERSION"
            print_warning "版本不匹配可能导致部分功能异常"
            read -p "是否继续安装? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "安装已取消"
                exit 0
            fi
        fi
    fi
}

# 检查命令冲突
check_conflicts() {
    if command -v $SYMLINK_NAME &> /dev/null; then
        EXISTING_CMD=$(which $SYMLINK_NAME)
        if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ] && [ "$(readlink -f "$INSTALL_DIR/$SYMLINK_NAME")" = "$INSTALL_DIR/$TARGET_FILE" ]; then
            print_info "检测到本项目之前安装的 '$SYMLINK_NAME' 软链接，将被更新"
            return 0
        fi
        print_warning "检测到已存在的 '$SYMLINK_NAME' 命令: $EXISTING_CMD"
        print_info "将跳过创建 '$SYMLINK_NAME' 软链接以避免冲突"
        SKIP_SYMLINK=1
    fi
}

# 下载文件
download_file() {
    print_info "正在下载 raspi-config-cn..."
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$REPO_URL/$TARGET_FILE" -o "/tmp/$TARGET_FILE"
    elif command -v wget &> /dev/null; then
        wget -qO "/tmp/$TARGET_FILE" "$REPO_URL/$TARGET_FILE"
    else
        print_error "未找到 curl 或 wget，请先安装其中之一"
        exit 1
    fi
    
    if [ ! -f "/tmp/$TARGET_FILE" ]; then
        print_error "下载失败"
        exit 1
    fi
    
    print_success "下载完成"
}

# 安装文件
install_file() {
    print_info "正在安装到 $INSTALL_DIR..."
    
    if [ -f "$INSTALL_DIR/$TARGET_FILE" ]; then
        print_info "备份现有文件..."
        cp "$INSTALL_DIR/$TARGET_FILE" "$INSTALL_DIR/$TARGET_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp "/tmp/$TARGET_FILE" "$INSTALL_DIR/$TARGET_FILE"
    chmod +x "$INSTALL_DIR/$TARGET_FILE"
    
    print_success "主文件安装完成"
}

create_symlink() {
    if [ "$SKIP_SYMLINK" = "1" ]; then
        print_info "跳过创建软链接 '$SYMLINK_NAME'"
        return
    fi
    
    print_info "创建软链接 '$SYMLINK_NAME'..."
    
    # 删除旧的软链接（如果存在）
    if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ]; then
        rm -f "$INSTALL_DIR/$SYMLINK_NAME"
    fi
    
    ln -sf "$INSTALL_DIR/$TARGET_FILE" "$INSTALL_DIR/$SYMLINK_NAME"
    print_success "软链接创建完成"
}

cleanup() {
    rm -f "/tmp/$TARGET_FILE"
}

show_completion() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "raspi-config 中文版安装完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "使用方法："
    echo "  sudo raspi-config-cn    # 启动中文版"
    if [ "$SKIP_SYMLINK" != "1" ]; then
        echo "  sudo smp                # 使用简短命令"
    fi
    echo "  sudo raspi-config       # 原版英文版（保留）"
    echo
    echo "卸载方法："
    echo "  curl -fsSL https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main/uninstall.sh | sudo bash"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  raspi-config 中文版安装程序 v1.0"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    check_root
    check_version
    check_conflicts
    download_file
    install_file
    create_symlink
    cleanup
    show_completion
}

main
