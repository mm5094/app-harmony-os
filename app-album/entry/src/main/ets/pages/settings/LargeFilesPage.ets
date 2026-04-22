import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { albumData, videoData, gifData, docData, recordData, MediaItem } from '../../models/AlbumData';

interface LargeFileItem {
  id: string;
  name: string;
  typeLabel: string;
  sizeLabel: string;
  managerIndex: number;
}

@Preview
@Entry
@Component
struct LargeFilesPage {
  @State largeFiles: LargeFileItem[] = [];

  aboutToAppear(): void {
    this.scanLargeFiles();
  }

  scanLargeFiles(): void {
    const managers = [albumData, videoData, gifData, docData, recordData];
    const typeLabels = ['照片', '视频', '动图', '资料', '录音'];
    const result: LargeFileItem[] = [];

    managers.forEach((mgr, idx) => {
      mgr.items.forEach((item: MediaItem) => {
        const hash = this.fakeSizeFromName(item.name);
        if (hash > 500) {
          result.push({
            id: item.id,
            name: item.name,
            typeLabel: typeLabels[idx],
            sizeLabel: `${(hash / 1024).toFixed(1)} MB`,
            managerIndex: idx
          });
        }
      });
    });

    result.sort((a, b) => {
      const sizeA = parseFloat(a.sizeLabel);
      const sizeB = parseFloat(b.sizeLabel);
      return sizeB - sizeA;
    });

    this.largeFiles = result;
  }

  private fakeSizeFromName(name: string): number {
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
      hash = ((hash << 5) - hash) + name.charCodeAt(i);
      hash = hash & hash;
    }
    return Math.abs(hash) % 5000 + 100;
  }

  private getManager(index: number) {
    const managers = [albumData, videoData, gifData, docData, recordData];
    return managers[index];
  }

  handleDelete(item: LargeFileItem): void {
    this.getManager(item.managerIndex).softDeleteItem(item.id);
    this.scanLargeFiles();
    promptAction.showToast({
      message: `已移至回收站: ${item.name}`,
      duration: 2000
    });
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })
        Text('大文件排序')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
        Blank()
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.largeFiles.length === 0) {
        Column() {
          Text('📊').fontSize(48)
          Text('暂无大文件记录').fontSize(16).fontColor('#6B7280').margin({ top: 12 })
          Text('按文件大小排序，快速找到占用空间的文件').fontSize(13).fontColor('#9CA3AF').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.largeFiles, (item: LargeFileItem) => {
            ListItem() {
              Row({ space: 12 }) {
                Column({ space: 2 }) {
                  Text(item.name).fontSize(14).fontColor('#111827')
                  Text(`${item.typeLabel} · ${item.sizeLabel}`)
                    .fontSize(12).fontColor('#9CA3AF')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('删除')
                  .fontSize(13).fontColor('#EF4444')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .onClick(() => { this.handleDelete(item); })
              }
              .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8)
            }
          }, (item: LargeFileItem) => item.id)
        }
        .width('100%').layoutWeight(1).padding({ left: 16, right: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
