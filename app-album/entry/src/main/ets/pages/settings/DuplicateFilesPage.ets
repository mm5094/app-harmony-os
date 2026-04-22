import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { albumData, videoData, gifData, docData, recordData, MediaItem } from '../../models/AlbumData';

interface DuplicateGroup {
  name: string;
  typeLabel: string;
  count: number;
  items: MediaItem[];
  managerIndex: number;
}

@Preview
@Entry
@Component
struct DuplicateFilesPage {
  @State duplicates: DuplicateGroup[] = [];
  @State isScanning: boolean = false;

  handleScan(): void {
    this.isScanning = true;
    const managers = [albumData, videoData, gifData, docData, recordData];
    const typeLabels = ['照片', '视频', '动图', '资料', '录音'];
    const groups: DuplicateGroup[] = [];

    managers.forEach((mgr, idx) => {
      const items = mgr.items;
      const nameMap: Map<string, MediaItem[]> = new Map();
      items.forEach((item: MediaItem) => {
        const existing = nameMap.get(item.name);
        if (existing) {
          existing.push(item);
        } else {
          nameMap.set(item.name, [item]);
        }
      });
      nameMap.forEach((dupItems, name) => {
        if (dupItems.length > 1) {
          groups.push({
            name,
            typeLabel: typeLabels[idx],
            count: dupItems.length,
            items: dupItems,
            managerIndex: idx
          });
        }
      });
    });

    this.duplicates = groups;
    this.isScanning = false;
    promptAction.showToast({
      message: groups.length > 0 ? `发现 ${groups.length} 组重复文件` : '未发现重复文件',
      duration: 2000
    });
  }

  private getManager(index: number) {
    const managers = [albumData, videoData, gifData, docData, recordData];
    return managers[index];
  }

  handleDeleteGroup(group: DuplicateGroup): void {
    group.items.forEach((item: MediaItem) => {
      this.getManager(group.managerIndex).softDeleteItem(item.id);
    });
    this.duplicates = this.duplicates.filter(g => g !== group);
    promptAction.showToast({
      message: `已清理 ${group.name} 的 ${group.count} 个重复项`,
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
        Text('查看重复文件')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
        Blank()
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.duplicates.length === 0) {
        Column() {
          Text('📄').fontSize(48)
          Text(this.isScanning ? '正在扫描...' : '暂未检测到重复文件')
            .fontSize(16).fontColor('#6B7280').margin({ top: 12 })
          Text('扫描加密相册中的重复内容以节省空间')
            .fontSize(13).fontColor('#9CA3AF').margin({ top: 4 })
          Button('开始扫描')
            .width('60%').height(44).fontSize(16).fontColor('#FFFFFF')
            .backgroundColor('#6366F1').borderRadius(8).margin({ top: 20 })
            .onClick(() => { this.handleScan(); })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.duplicates, (group: DuplicateGroup) => {
            ListItem() {
              Row({ space: 12 }) {
                Column({ space: 2 }) {
                  Text(group.name).fontSize(14).fontColor('#111827')
                  Text(`${group.typeLabel} · ${group.count} 个重复`)
                    .fontSize(12).fontColor('#9CA3AF')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('清理')
                  .fontSize(13).fontColor('#EF4444')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .onClick(() => { this.handleDeleteGroup(group); })
              }
              .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8)
            }
          }, (group: DuplicateGroup) => group.name + group.managerIndex)
        }
        .width('100%').layoutWeight(1).padding({ left: 16, right: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
