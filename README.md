# raspi-config 中文版

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-20260303--cn--1.0-blue.svg)](https://github.com/xiaciyidingde/raspi-config-cn/releases)

树莓派配置工具（raspi-config）的汉化版本
> 原版地址：https://github.com/RPi-Distro/raspi-config
## 📖 简介

raspi-config 是树莓派官方的系统配置工具。本项目汉化了主脚本，帮助中文用户更轻松地配置树莓派系统。

- **汉化内容**：所有菜单、提示和错误消息
- **保留原版**：不会覆盖原 raspi-config

## ⚡ 快速安装

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

或手动卸载：
```bash
sudo rm -f /usr/local/bin/raspi-config-cn
sudo rm -f /usr/local/bin/smp
```

## 🔧 版本兼容性

| raspi-config 版本 | 中文版本 | 状态 |
|------------------|---------|------|
| 20260303         | 1.0     | ✅ 完全兼容 |

如果您的系统版本不同，安装程序会发出警告但允许继续安装。

## 📝 更新日志

### v20260303-cn-1.0 (2026-05-15)
- 完整汉化 raspi-config 20260303
- 支持 `raspi-config-cn` 和 `smp` 命令

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。原版 raspi-config 版权归树莓派基金会所有。

---

**给项目点个 Star ⭐**
