---
runAt: 2026-03-31.20-16-25
title: 加密相册基本修改
---
加密相册：照片
所有操作全部放到右上角下拉，而下边直接是分目录或不同方式的照片呈现，顶层必须创建目录，而目录中可创建子目录，顶层不可处理照片，暂时不考虑照片分类，只要是导入的都可以放到对应目录中。导入路径源头要多样，不分地方要提供文字说明引导用户使用。

## Changes

### 新增文件
- `app-album/entry/src/main/ets/models/AlbumData.ets` — 相册数据模型
  - Folder / Photo 接口定义
  - AlbumDataManager 类（@ObservedV2 + preferences 持久化）
  - 支持根目录/子目录层级、增删改查
- `app-album/entry/src/main/ets/pages/FolderDetailPage.ets` — 目录详情页
  - 显示子目录列表 + 照片网格（3列）
  - 右上角下拉菜单：新建子目录、导入照片、重命名、删除
  - 支持无限层级目录嵌套
- `app-album/entry/src/main/ets/pages/ImportGuidePage.ets` — 导入照片引导页
  - 4 种导入来源：系统相册、本地文件、拍照、应用分享
  - 每个来源有大图标 + 标题 + 详细文字说明引导
  - 底部显示目标目录名称

### 修改文件
- `app-album/entry/src/main/ets/pages/PhotosPage.ets` — 完全重写
  - 右上角 ⋮ 下拉菜单（新建目录、导入照片）
  - 主体改为根目录列表（顶层不显示照片）
  - 点击目录进入 FolderDetailPage
  - 空状态引导文字
- `app-album/entry/src/main/resources/base/profile/main_pages.json`
  - 注册 FolderDetailPage、ImportGuidePage

### 构建结果
- BUILD SUCCESSFUL（0 错误）