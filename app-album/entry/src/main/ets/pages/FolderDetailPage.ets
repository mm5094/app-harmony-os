import router from '@ohos.router';
import { getDataManager, albumData, MediaDataManager, Folder, MediaItem } from '../models/AlbumData';

interface SubFolderView {
  id: string;
  name: string;
  itemCount: number;
}

interface ItemView {
  id: string;
  name: string;
}

interface RouterParams {
  folderId: string;
  folderName: string;
  contentType: string;
}

@Entry
@Component
struct FolderDetailPage {
  @State folderId: string = '';
  @State folderName: string = '';
  @State contentType: string = 'photo';
  @State subFolders: SubFolderView[] = [];
  @State items: ItemView[] = [];
  @State newFolderName: string = '';

  private dataManager: MediaDataManager = albumData;

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    this.folderId = params?.folderId || '';
    this.folderName = params?.folderName || '目录';
    this.contentType = params?.contentType || 'photo';
    this.dataManager = getDataManager(this.contentType);
    this.loadData();
  }

  loadData() {
    const rawSubFolders: Folder[] = this.dataManager.getSubFolders(this.folderId);
    this.subFolders = rawSubFolders.map((f: Folder): SubFolderView => ({
      id: f.id,
      name: f.name,
      itemCount: this.dataManager.getItemsInFolder(f.id).length
    }));
    const rawItems: MediaItem[] = this.dataManager.getItemsInFolder(this.folderId);
    this.items = rawItems.map((p: MediaItem): ItemView => ({
      id: p.id,
      name: p.name
    }));
  }

  showNewFolderDialog() {
    this.newFolderName = '';
    AlertDialog.show({
      title: '新建子目录',
      message: '请输入目录名称',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridCount: 4,
      confirm: {
        value: '确定',
        action: () => {
          if (this.newFolderName.trim()) {
            this.dataManager.addFolder(this.newFolderName.trim(), this.folderId);
            this.loadData();
          }
        }
      },
      cancel: () => {}
    });
  }

  showRenameDialog() {
    let renameName: string = this.folderName;
    AlertDialog.show({
      title: '重命名目录',
      message: '请输入新名称',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridCount: 4,
      confirm: {
        value: '确定',
        action: () => {
          if (renameName.trim()) {
            this.dataManager.renameFolder(this.folderId, renameName.trim());
            this.folderName = renameName.trim();
          }
        }
      },
      cancel: () => {}
    });
  }

  showDeleteDialog() {
    AlertDialog.show({
      title: '删除目录',
      message: '确定要删除此目录吗？此操作不可恢复。',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridCount: 4,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF0000',
        action: () => {
          this.dataManager.deleteFolder(this.folderId);
          router.back();
        }
      }
    });
  }

  handleOpenSubFolder(folder: SubFolderView) {
    router.pushUrl({
      url: 'pages/FolderDetailPage',
      params: {
        folderId: folder.id,
        folderName: folder.name,
        contentType: this.contentType
      }
    });
  }

  handleImport() {
    router.pushUrl({
      url: 'pages/ImportGuidePage',
      params: {
        folderId: this.folderId,
        folderName: this.folderName,
        contentType: this.contentType
      }
    });
  }

  getItemInitials(name: string): string {
    return name.substring(0, 2).toUpperCase();
  }

  getItemBgColor(): ResourceColor {
    switch (this.contentType) {
      case 'video': return '#EC4899';
      case 'gif': return '#F59E0B';
      case 'doc': return '#10B981';
      case 'record': return '#3B82F6';
      default: return '#4A90E2';
    }
  }

  getImportLabel(): string {
    switch (this.contentType) {
      case 'video': return '导入视频';
      case 'gif': return '导入动图';
      case 'doc': return '导入资料';
      case 'record': return '导入文件';
      default: return '导入照片';
    }
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
        }
        .backgroundColor(Color.Transparent)
        .width(48)
        .height(48)
        .onClick(() => {
          router.back();
        })

        Text(this.folderName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button({ type: ButtonType.Normal }) {
          Text('⋮')
            .fontSize(24)
            .fontColor('#333333')
        }
        .backgroundColor(Color.Transparent)
        .width(48)
        .height(48)
        .bindMenu([
          {
            value: '新建子目录',
            action: () => {
              this.showNewFolderDialog();
            }
          },
          {
            value: this.getImportLabel(),
            action: () => {
              this.handleImport();
            }
          },
          {
            value: '重命名目录',
            action: () => {
              this.showRenameDialog();
            }
          },
          {
            value: '删除目录',
            action: () => {
              this.showDeleteDialog();
            }
          }
        ])
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#F5F5F5')

      if (this.subFolders.length === 0 && this.items.length === 0) {
        Column() {
          Text('暂无内容')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('点击右上角菜单新建子目录或导入')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            if (this.subFolders.length > 0) {
              Column() {
                Text('子目录')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('100%')
                  .padding({ left: 16, top: 12, bottom: 8 })

                List({ space: 0 }) {
                  ForEach(this.subFolders, (folder: SubFolderView) => {
                    ListItem() {
                      Row() {
                        Text('📁')
                          .fontSize(24)
                          .margin({ right: 12 })

                        Column() {
                          Text(folder.name)
                            .fontSize(16)
                            .fontColor('#333333')
                          Text(`${folder.itemCount} 项`)
                            .fontSize(12)
                            .fontColor('#999999')
                            .margin({ top: 4 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)

                        Text('›')
                          .fontSize(24)
                          .fontColor('#CCCCCC')
                      }
                      .width('100%')
                      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                      .onClick(() => {
                        this.handleOpenSubFolder(folder);
                      })
                    }
                  })
                }
                .divider({
                  strokeWidth: 1,
                  color: '#F0F0F0',
                  startMargin: 60,
                  endMargin: 16
                })
              }
              .margin({ bottom: 16 })
            }

            if (this.items.length > 0) {
              Column() {
                Text('内容')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('100%')
                  .padding({ left: 16, top: 12, bottom: 8 })

                Grid() {
                  ForEach(this.items, (item: ItemView) => {
                    GridItem() {
                      Column() {
                        Text(this.getItemInitials(item.name))
                          .fontSize(20)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Bold)
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .backgroundColor(this.getItemBgColor())
                      .borderRadius(8)
                      .justifyContent(FlexAlign.Center)
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .padding({ left: 16, right: 16 })
              }
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
