---
runAt: 2026-03-31.20-16-27
title: 同步处理其他内容
---
视频、动图、资料、录音和文件也都同时考虑，和相册一致的改动，都要支持目录级的管理流程。

## Changes

### 数据模型扩展
- `app-album/entry/src/main/ets/models/AlbumData.ets`
  - 重构 `AlbumDataManager` → `MediaDataManager`（通用媒体数据管理器）
  - 支持 5 种内容类型独立存储：photo / video / gif / doc / record
  - 每种类型有独立的 preferences 命名空间，互不干扰
  - 导出 5 个全局实例：`albumData`、`videoData`、`gifData`、`docData`、`recordData`
  - 导出 `getDataManager(type)` 函数，供详情页/导入页根据类型动态切换
  - 保留 `Photo` 接口和 `photos`/`getPhotosInFolder`/`addPhoto` 等向后兼容别名

### 页面重写（4个）
- `app-album/entry/src/main/ets/pages/VideosPage.ets` — 完全重写，目录列表 + 下拉菜单（新建目录/导入视频）
- `app-album/entry/src/main/ets/pages/GifsPage.ets` — 完全重写，目录列表 + 下拉菜单（新建目录/导入动图）
- `app-album/entry/src/main/ets/pages/DocsPage.ets` — 完全重写，目录列表 + 下拉菜单（新建目录/导入资料）
- `app-album/entry/src/main/ets/pages/RecordsPage.ets` — 完全重写，目录列表 + 下拉菜单（新建目录/导入文件）

### 通用页面扩展
- `app-album/entry/src/main/ets/pages/FolderDetailPage.ets`
  - 接收 `contentType` router 参数，通过 `getDataManager()` 动态切换数据源
  - 子目录列表 + 内容网格（根据类型显示不同颜色占位）
  - 下拉菜单标签根据类型动态变化（导入照片/视频/动图/资料/文件）
  - 支持无限层级递归嵌套
- `app-album/entry/src/main/ets/pages/ImportGuidePage.ets`
  - 接收 `contentType` router 参数
  - 根据类型显示不同的导入来源选项和说明文字
  - 视频：系统相册/本地文件/录像/应用分享
  - 动图：系统相册/本地文件/应用分享
  - 资料：本地文件/云盘导入/应用分享/链接下载
  - 录音&文件：录音/本地文件/应用分享

### 构建结果
- BUILD SUCCESSFUL（0 错误）
- 已安装到模拟器并启动成功