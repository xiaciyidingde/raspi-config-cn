#!/bin/bash
# raspi-config-cn 安装脚本
# 作者: xiaciyidingde
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
REPO_URL="https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main"
INSTALL_DIR="/usr/local/bin"
TARGET_FILE="raspi-config-cn"
SYMLINK_NAME="smp"

print_info()    { echo -e "${BLUE}[信息]${NC} $1"; }
print_success() { echo -e "${GREEN}[成功]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
print_error()   { echo -e "${RED}[错误]${NC} $1"; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 权限运行此脚本"
        echo "使用方法: sudo bash install.sh"
        exit 1
    fi
}

detect_version() {
    if command -v dpkg &> /dev/null; then
        INSTALLED=$(dpkg -s raspi-config 2>/dev/null | grep "^Version:" | awk '{print $2}' | cut -d'-' -f1)
        echo "$INSTALLED"
    fi
}

get_installed_cn_version() {
    if [ ! -f "$INSTALL_DIR/$TARGET_FILE" ]; then
        return 0
    fi
    sed -n 's/^# BASE_VERSION=//p' "$INSTALL_DIR/$TARGET_FILE" | head -n 1
}

fetch_supported_versions() {
    INDEX_TMP=$(mktemp)
    trap 'rm -f "$INDEX_TMP"' EXIT
    download_file "$REPO_URL/versions/index.txt" "$INDEX_TMP"

    SUPPORTED_VERSIONS=()
    while IFS= read -r line; do
        case "$line" in
            ''|'#'*) continue ;;
            *) SUPPORTED_VERSIONS+=("$line") ;;
        esac
    done < "$INDEX_TMP"

    if [ ${#SUPPORTED_VERSIONS[@]} -eq 0 ]; then
        print_error "版本索引为空或读取失败"
        exit 1
    fi
}

is_supported_version() {
    local target="$1"
    local ver
    for ver in "${SUPPORTED_VERSIONS[@]}"; do
        if [ "$ver" = "$target" ]; then
            return 0
        fi
    done
    return 1
}

get_latest_supported_version() {
    printf '%s\n' "${SUPPORTED_VERSIONS[@]}" | sort | tail -n 1
}

check_conflicts() {
    if command -v $SYMLINK_NAME &> /dev/null; then
        EXISTING_CMD=$(which $SYMLINK_NAME)
        if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ] && [ "$(readlink -f "$INSTALL_DIR/$SYMLINK_NAME")" = "$INSTALL_DIR/$TARGET_FILE" ]; then
            return 0
        fi
        print_warning "检测到已存在的 '$SYMLINK_NAME' 命令: $EXISTING_CMD"
        print_info "将跳过创建 '$SYMLINK_NAME' 软链接"
        SKIP_SYMLINK=1
    fi
}

download_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if command -v curl &> /dev/null; then
        set +e
        curl -fsSL "$src" -o "$dst"
        CURL_EXIT=$?
        set -e
        if [ $CURL_EXIT -ne 0 ]; then
            print_error "下载失败 (curl 退出码 $CURL_EXIT): $src"
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        set +e
        wget -qO "$dst" "$src"
        WGET_EXIT=$?
        set -e
        if [ $WGET_EXIT -ne 0 ]; then
            print_error "下载失败 (wget 退出码 $WGET_EXIT): $src"
            exit 1
        fi
    else
        print_error "未找到 curl 或 wget"
        exit 1
    fi
    if [ ! -f "$dst" ]; then
        print_error "下载失败: 文件未创建 - $src"
        exit 1
    fi
}

install_file() {
    local ver="$1"
    print_info "正在下载 raspi-config-cn (版本 $ver)..."

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    download_file "$REPO_URL/versions/$ver/raspi-config-cn" "$TMPDIR/raspi-config-cn"
    chmod +x "$TMPDIR/raspi-config-cn"

    if [ -f "$INSTALL_DIR/$TARGET_FILE" ]; then
        cp "$INSTALL_DIR/$TARGET_FILE" "$INSTALL_DIR/$TARGET_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    fi

    cp "$TMPDIR/raspi-config-cn" "$INSTALL_DIR/$TARGET_FILE"
    chmod +x "$INSTALL_DIR/$TARGET_FILE"
    print_success "安装完成 (版本 $ver)"
}

prompt_install_latest() {
    local latest_ver="$1"
    print_warning "当前不支持 raspi-config 版本: $INSTALLED_VER"
    print_info "最新可用的汉化版本是: $latest_ver"
    read -p "是否安装最新汉化版本? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_file "$latest_ver"
        create_symlink
        show_completion
        exit 0
    fi
    print_info "安装已取消"
    exit 0
}

create_symlink() {
    [ "$SKIP_SYMLINK" = "1" ] && { print_info "跳过创建 '$SYMLINK_NAME'"; return; }
    [ -L "$INSTALL_DIR/$SYMLINK_NAME" ] && rm -f "$INSTALL_DIR/$SYMLINK_NAME"
    ln -sf "$INSTALL_DIR/$TARGET_FILE" "$INSTALL_DIR/$SYMLINK_NAME"
    print_success "已创建 '$SYMLINK_NAME' 软链接"
}

show_completion() {
    echo; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "raspi-config 中文版安装完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo; echo "使用方法："
    echo "  sudo raspi-config-cn    # 启动中文版"
    [ "$SKIP_SYMLINK" != "1" ] && echo "  sudo smp                # 使用简短命令"
    echo "  sudo raspi-config       # 原版英文版（保留）"
    echo
}

main() {
    echo; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  raspi-config 中文版安装程序"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo

    check_root
    check_conflicts
    fetch_supported_versions

    INSTALLED_VER=$(detect_version)
    if [ -z "$INSTALLED_VER" ]; then
        print_error "无法检测 raspi-config 版本"
        echo "请确认已安装 raspi-config: sudo apt install raspi-config"
        exit 1
    fi

    print_info "检测到 raspi-config 版本: $INSTALLED_VER"

    CURRENT_CN_VER=$(get_installed_cn_version)
    if [ -z "$CURRENT_CN_VER" ]; then
        print_info "未检测到已安装的中文版，进入安装流程"
    elif [ "$CURRENT_CN_VER" = "$INSTALLED_VER" ]; then
        print_success "当前已安装匹配的汉化版本 ($CURRENT_CN_VER)"
        exit 0
    else
        print_info "已安装的汉化版本为: $CURRENT_CN_VER"
        print_info "与当前 raspi-config 版本不一致，进入安装流程"
    fi

    if ! is_supported_version "$INSTALLED_VER"; then
        LATEST_VER=$(get_latest_supported_version)
        prompt_install_latest "$LATEST_VER"
    fi

    install_file "$INSTALLED_VER"
    create_symlink
    show_completion
}

main
