#!/bin/bash
# raspi-config-cn 卸载脚本
# 版本: version-20260303--cn--1.0
# 作者: xiaciyidingde

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="/usr/local/bin"
TARGET_FILE="raspi-config-cn"
SYMLINK_NAME="smp"

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
        echo "使用方法: sudo bash uninstall.sh"
        exit 1
    fi
}

check_installed() {
    if [ ! -f "$INSTALL_DIR/$TARGET_FILE" ]; then
        print_warning "未检测到已安装的 raspi-config-cn"
        exit 0
    fi
}

confirm_uninstall() {
    echo
    print_warning "即将卸载 raspi-config 中文版"
    echo
    echo "将删除以下文件："
    echo "  - $INSTALL_DIR/$TARGET_FILE"
    if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ]; then
        echo "  - $INSTALL_DIR/$SYMLINK_NAME (软链接)"
    fi
    echo
    read -p "确认卸载? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "卸载已取消"
        exit 0
    fi
}

remove_files() {
    print_info "正在删除文件..."
    
    # 删除主文件
    if [ -f "$INSTALL_DIR/$TARGET_FILE" ]; then
        rm -f "$INSTALL_DIR/$TARGET_FILE"
        print_success "已删除 $TARGET_FILE"
    fi
    
    # 删除软链接
    if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ]; then
        # 检查软链接是否指向我们的文件
        if [ "$(readlink -f "$INSTALL_DIR/$SYMLINK_NAME")" = "$INSTALL_DIR/$TARGET_FILE" ]; then
            rm -f "$INSTALL_DIR/$SYMLINK_NAME"
            print_success "已删除软链接 $SYMLINK_NAME"
        else
            print_warning "软链接 $SYMLINK_NAME 不是由本项目创建，已跳过"
        fi
    fi
    
    if ls "$INSTALL_DIR/$TARGET_FILE.bak."* 1> /dev/null 2>&1; then
        print_info "发现备份文件，是否一并删除?"
        read -p "删除备份文件? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$INSTALL_DIR/$TARGET_FILE.bak."*
            print_success "已删除备份文件"
        fi
    fi
}

show_completion() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "raspi-config 中文版已成功卸载"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "原版 raspi-config 仍然可用："
    echo "  sudo raspi-config"
    echo
    echo "如需重新安装中文版："
    echo "  curl -fsSL https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main/install.sh | sudo bash"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  raspi-config 中文版卸载程序 v1.0"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_root
    check_installed
    confirm_uninstall
    remove_files
    show_completion
}

main
