import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { getDataManager, MediaDataManager, MediaItem } from '../models/AlbumData';

interface PreviewRouterParams {
  itemId: string;
  folderId: string;
  contentType: string;
}

@Entry
@Component
struct ContentPreviewPage {
  @State itemId: string = '';
  @State folderId: string = '';
  @State contentType: string = 'photo';
  @State item: MediaItem | null = null;

  private dataManager: MediaDataManager = getDataManager('photo');

  aboutToAppear() {
    const params = router.getParams() as PreviewRouterParams;
    this.itemId = params?.itemId || '';
    this.folderId = params?.folderId || '';
    this.contentType = params?.contentType || 'photo';
    this.dataManager = getDataManager(this.contentType);
    this.loadItem();
  }

  private loadItem(): void {
    const found = this.dataManager.getItemsInFolder(this.folderId).find(i => i.id === this.itemId);
    if (found) {
      this.item = found;
    }
  }

  private getTypeLabel(): string {
    switch (this.contentType) {
      case 'video': return '视频';
      case 'gif': return '动图';
      case 'doc': return '文档';
      case 'record': return '录音';
      default: return '照片';
    }
  }

  private getTypeIcon(): string {
    switch (this.contentType) {
      case 'video': return '🎬';
      case 'gif': return '🎭';
      case 'doc': return '📄';
      case 'record': return '🎙️';
      default: return '🖼️';
    }
  }

  private formatSize(bytes: number | undefined): string {
    if (bytes === undefined || bytes === 0) return '未知大小';
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  private handleDelete(): void {
    if (!this.item) return;
    AlertDialog.show({
      title: '删除内容',
      message: `确定要将「${this.item.name}」移入回收站吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridCount: 4,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#EF4444',
        action: () => {
          this.dataManager.softDeleteItem(this.itemId);
          promptAction.showToast({
            message: '已移入回收站',
            duration: 2000
          });
          router.back();
        }
      }
    });
  }

  private canPreviewImage(): boolean {
    return (this.contentType === 'photo' || this.contentType === 'gif') && !!this.item?.uri;
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })
        Text('内容详情')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
          .layoutWeight(1)
        Button('删除')
          .fontSize(14).fontColor('#EF4444')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.handleDelete(); })
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.item) {
        Column({ space: 16 }) {
          // 预览区域
          Column() {
            if (this.canPreviewImage()) {
              Image(this.item!.uri)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
            } else {
              Text(this.getTypeIcon())
                .fontSize(64)
              Text(this.getTypeLabel())
                .fontSize(16).fontColor('#6B7280').margin({ top: 8 })
            }
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor('#F3F6FC')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .padding(16)

          // 信息区域
          Column({ space: 0 }) {
            Row() {
              Text('名称').fontSize(14).fontColor('#6B7280')
              Blank()
              Text(this.item!.name)
                .fontSize(14).fontColor('#111827')
                .textAlign(TextAlign.End)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
                .margin({ left: 24 })
            }
            .width('100%').padding(16)

            Divider().color('#E5E7EB')

            Row() {
              Text('类型').fontSize(14).fontColor('#6B7280')
              Blank()
              Text(this.getTypeLabel())
                .fontSize(14).fontColor('#111827')
            }
            .width('100%').padding(16)

            Divider().color('#E5E7EB')

            Row() {
              Text('大小').fontSize(14).fontColor('#6B7280')
              Blank()
              Text(this.formatSize(this.item!.size))
                .fontSize(14).fontColor('#111827')
            }
            .width('100%').padding(16)

            Divider().color('#E5E7EB')

            Row() {
              Text('创建时间').fontSize(14).fontColor('#6B7280')
              Blank()
              Text(this.formatTime(this.item!.createTime))
                .fontSize(14).fontColor('#111827')
            }
            .width('100%').padding(16)

            if (this.item!.uri) {
              Divider().color('#E5E7EB')

              Row() {
                Text('文件路径').fontSize(14).fontColor('#6B7280')
                Blank()
                Text(this.item!.uri!)
                  .fontSize(12).fontColor('#111827')
                  .textAlign(TextAlign.End)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                  .margin({ left: 24 })
              }
              .width('100%').padding(16)
            }
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ left: 16, right: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 8, bottom: 16 })
      } else {
        Column() {
          Text('内容不存在或已被删除')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FC')
  }
}
