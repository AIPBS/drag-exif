# 图像 EXIF 编辑器

**[English](../README.md) | 中文**

基于 ExifTool 的独立 EXIF 元数据查看器，使用 Flutter 构建。

## 关于

图像 EXIF 编辑器（DragExif）是一款跨平台桌面应用程序，用于查看和编辑图像文件的 EXIF 元数据。它基于 Dương Diệu Pháp 的 [ExifGlass](https://github.com/d2phap/ExifGlass)（原使用 C# 和 Avalonia UI 编写）。本项目是 Flutter/Dart 重写版，为 Linux，Windows 和 macOS 提供相同的功能。

## 下载与安装

[![从 Microsoft 获取](https://get.microsoft.com/images/zh-cn%20dark.svg)](https://apps.microsoft.com/detail/9pntjm05st7q?launch=true&cid=github_readme&mode=full)

### Windows

你可以从 [Microsoft Store](https://apps.microsoft.com/detail/9pntjm05st7q?launch=true&cid=github_readme&mode=full) 免费安装，也可以从 [Release 页面](https://github.com/AIPBS/drag-exif/releases/) 下载安装包。

### Linux

你可以从 [Release 页面](https://github.com/AIPBS/drag-exif/releases/) 下载安装包。

> TODO：支持包管理器

### macOS

> TODO

## 功能

- 查看 EXIF，IPTC，XMP 和 GPS 元数据
- 拖放文件以加载
- 文件列表多选（Ctrl / Shift 点击）
- 标签值内联编辑
- 从可搜索目录添加新标签
- 撤销 / 重做支持（Ctrl+Z）
- 保存更改到文件（Ctrl+S）
- 导出元数据为文本、CSV 或 JSON）
- 图像预览面板

## 注意事项

应用界面支持中文，但 XMP/EXIF 元数据本身的标签名称是英文，目前尚未汉化。

## 语言

本应用程序支持**英文**和**中文**。在**设置 → 语言**中切换语言，或让它跟随系统默认设置。

## 原始项目

- **名称：** ExifGlass
- **作者：** Dương Diệu Pháp
- **URL：** https://github.com/d2phap/ExifGlass
- **许可证：** GNU General Public License v3.0 (GPLv3)
- **版权：** Copyright © 2023-2025, Dương Diệu Pháp

DragExif 与原始项目使用相同的 GPLv3 许可证，符合许可证条款。

## 许可证

本项目根据 GNU 通用公共许可证 v3.0（GPLv3）获得许可。详情请参见 [LICENSE](LICENSE) 文件。
