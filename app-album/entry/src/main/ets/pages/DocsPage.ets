import router from '@ohos.router';
import { docData, Folder } from '../models/AlbumData';

@Preview
@Entry
@Component
struct DocsPage {
  @State rootFolders: Folder[] = [];
  @State newFolderName: string = '';
  private dialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    docData.init(getContext(this));
    this.loadRootFolders();
  }

  loadRootFolders(): void {
    this.rootFolders = docData.getRootFolders();
  }

  showNewFolderDialog(): void {
    this.dialogController = new CustomDialogController({
      builder: NewFolderDialog({
        folderName: this.newFolderName,
        onConfirm: (name: string) => {
          if (name.trim()) {
            docData.addFolder(name.trim(), '');
            this.loadRootFolders();
          }
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    this.dialogController.open();
  }

  getFolderItemCount(folderId: string): number {
    const subFolders = docData.getSubFolders(folderId);
    const items = docData.getItemsInFolder(folderId);
    return subFolders.length + items.length;
  }

  navigateToFolder(folder: Folder): void {
    router.pushUrl({
      url: 'pages/FolderDetailPage',
      params: {
        folderId: folder.id,
        folderName: folder.name,
        contentType: 'doc'
      }
    });
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })

        Text('资料')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
          .layoutWeight(1)

        Button({ type: ButtonType.Normal }) {
          Text('⋮')
            .fontSize(24).fontColor('#10B981')
        }
        .width(36).height(36)
        .backgroundColor('#FFFFFF').borderRadius(18)
        .bindMenu([
          {
            value: '新建目录',
            action: () => { this.showNewFolderDialog(); }
          },
          {
            value: '导入资料',
            action: () => {
              router.pushUrl({
                url: 'pages/ImportGuidePage',
                params: { folderId: '', folderName: '主目录', contentType: 'doc' }
              });
            }
          }
        ])
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.rootFolders.length === 0) {
        Column({ space: 12 }) {
          Text('📄').fontSize(64)
          Text('暂无目录')
            .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#6B7280')
          Text('点击右上角菜单创建目录')
            .fontSize(14).fontColor('#9CA3AF')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.rootFolders, (folder: Folder) => {
            ListItem() {
              Row({ space: 12 }) {
                Text('🗂️').fontSize(28)

                Column({ space: 4 }) {
                  Text(folder.name)
                    .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#111827')
                  Text(`${this.getFolderItemCount(folder.id)} 项`)
                    .fontSize(13).fontColor('#9CA3AF')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('›')
                  .fontSize(24).fontColor('#D1D5DB')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
            }
            .onClick(() => { this.navigateToFolder(folder); })
          }, (folder: Folder) => folder.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}

@CustomDialog
struct NewFolderDialog {
  @State folderName: string = '';
  onConfirm?: (name: string) => void;
  controller?: CustomDialogController;

  build() {
    Column({ space: 16 }) {
      Text('新建目录')
        .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')

      TextInput({ placeholder: '请输入目录名称', text: this.folderName })
        .width('100%')
        .onChange((value: string) => { this.folderName = value; })

      Row({ space: 12 }) {
        Button('取消')
          .fontSize(15).fontColor('#6B7280')
          .backgroundColor('#F3F4F6')
          .layoutWeight(1)
          .onClick(() => { this.controller?.close(); })

        Button('确认')
          .fontSize(15).fontColor('#FFFFFF')
          .backgroundColor('#10B981')
          .layoutWeight(1)
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm(this.folderName);
            }
            this.controller?.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
