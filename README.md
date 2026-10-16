# raspi-config 中文版

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-multi--version-blue.svg)](https://github.com/xiaciyidingde/raspi-config-cn)

树莓派配置工具（raspi-config）的汉化版本
> 原版地址：https://github.com/RPi-Distro/raspi-config
## 📖 简介

raspi-config 是树莓派官方的系统配置工具。本项目为不同版本的 raspi-config 提供对应的汉化脚本，帮助中文用户更轻松地配置树莓派系统。

- **汉化内容**：所有菜单、提示和错误消息
- **保留原版**：不会覆盖原 raspi-config
- **自动匹配版本**：安装脚本会检测当前系统中的 raspi-config 版本，并安装对应的汉化文件
- **未匹配自动降级**：若当前版本暂未支持，将安装仓库中最新的汉化版本（终端交互运行时确认一次，管道安装直接进行）

## ⚡ 快速安装

安装脚本会自动：

- 检测已安装的 `raspi-config` 版本
- 查找仓库中是否有对应版本的汉化脚本
- 优先下载并安装完全匹配版本的 `raspi-config-cn`
- 若当前版本暂未支持，则安装最新的汉化版本（交互运行时询问确认，默认继续）

### 一键安装
```bash
curl -fsSL https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main/install.sh | sudo bash
```

或使用 wget：
```bash
wget -qO- https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main/install.sh | sudo bash
```

### 使用方法
```bash
sudo raspi-config-cn
```
或使用简短命令：
```bash
sudo smp
```

原版仍然可用：
```bash
sudo raspi-config
```

## 📦 手动安装

```bash
# 克隆仓库
git clone https://github.com/xiaciyidingde/raspi-config-cn.git
cd raspi-config-cn

# 运行安装脚本
sudo bash install.sh
```

## 🗑️ 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/xiaciyidingde/raspi-config-cn/main/uninstall.sh | sudo bash
```

非交互方式（如 `curl | bash`）运行时会跳过确认直接卸载，`.bak` 备份文件默认保留；在终端交互运行时则逐项询问。

或手动卸载：
```bash
sudo rm -f /usr/local/bin/raspi-config-cn
sudo rm -f /usr/local/bin/smp
```

## 🔧 版本兼容性

当前仓库使用 `versions/index.txt` 维护支持版本列表：

- **版本精确匹配**：安装对应版本的汉化脚本
- **版本不匹配**：安装仓库中最新的汉化版本。终端交互运行时询问一次（默认继续）；通过 `curl | bash` 等非交互方式运行时直接安装
- **注意**：汉化脚本基于其标注的上游版本（文件头 `BASE_VERSION`）翻译，若系统上的 raspi-config 版本更新，官方新增功能可能未汉化或不可用
- **幂等**：重复运行安装脚本不会重复下载或产生多余备份；已安装最新可用汉化版时会直接跳过

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。原版 raspi-config 版权归树莓派基金会所有。

---

**给项目点个 Star ⭐**
