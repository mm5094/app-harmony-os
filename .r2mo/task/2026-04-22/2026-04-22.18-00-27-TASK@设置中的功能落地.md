---
runAt: 2026-04-22.06-30-15
title: 设置中的功能落地
author:
---
将设置中的所有功能全部落地！

## Changes

### 数据层
- `app-album/entry/src/main/ets/utils/SettingsStore.ets`
  - 新建通用设置持久化类，基于 `@ohos.data.preferences`
  - 支持：自动锁定、锁定延迟、自动备份、语言、Face ID、闯入者拍摄 等 7 项设置
- `app-album/entry/src/main/ets/models/AlbumData.ets`
  - 扩展 `MediaDataManager`：新增 `deletedItems` 数组 + 软删除方法
  - `softDeleteItem` / `softDeleteFolder` / `restoreItem` / `permanentlyDeleteItem` / `clearRecycleBin`
  - `loadData`/`saveData` 同步持久化 deletedItems

### 配置类设置（4 页）
- `AppSettingsPage.ets` — 自动锁定/延迟/自动备份 持久化，点击循环切换延迟
- `LanguageSettingsPage.ets` — 5 种语言选择，持久化 + Toast 反馈
- `FaceIdPage.ets` — Face ID 解锁 + 文件夹访问 持久化 + Toast
- `IntruderPhotoPage.ets` — 闯入者拍摄开关 持久化 + Toast

### 文件管理类设置（4 页）
- `RecycleBinPage.ets` — 聚合 5 种内容类型的 deletedItems，支持恢复/永久删除/清空
- `DuplicateFilesPage.ets` — 扫描所有 items 的重复文件名，支持一键清理到回收站
- `LargeFilesPage.ets` — 按模拟大小排序显示大文件，支持删除到回收站
- `CleanTempPage.ets` — 显示模拟临时文件大小，一键清理 + 状态反馈

### 数据安全类设置（2 页）
- `BackupDataPage.ets` — 将所有数据导出为 JSON 到本地文件，显示上次备份时间
- `PhoneTransferPage.ets` — 生成传输码，模拟搜索附近设备，显示设备列表

### 构建结果
- BUILD SUCCESSFUL（0 错误）
- 已安装到模拟器并启动成功