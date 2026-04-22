import router from '@ohos.router';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';
import { albumData, videoData, gifData, docData, recordData, Folder, MediaItem } from '../../models/AlbumData';

interface BackupEntry {
  folders: Folder[];
  items: MediaItem[];
  deletedItems: MediaItem[];
}

interface BackupData {
  backupTime: number;
  photo: BackupEntry;
  video: BackupEntry;
  gif: BackupEntry;
  doc: BackupEntry;
  record: BackupEntry;
}

@Preview
@Entry
@Component
struct BackupDataPage {
  @State lastBackup: string = '从未备份';
  @State isBackingUp: boolean = false;

  aboutToAppear(): void {
    void this.checkLastBackup();
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private async checkLastBackup(): Promise<void> {
    try {
      const context = this.getAbilityContext();
      const filesDir = context.filesDir;
      const backupPath = filesDir + '/album_backup.json';
      const exists = await fs.access(backupPath);
      if (exists) {
        const stat = await fs.stat(backupPath);
        const date = new Date(stat.mtime * 1000);
        this.lastBackup = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
      }
    } catch (err) {
      console.error('Check backup failed:', JSON.stringify(err));
    }
  }

  private async handleBackup(): Promise<void> {
    this.isBackingUp = true;
    try {
      const context = this.getAbilityContext();
      const filesDir = context.filesDir;
      const backupPath = filesDir + '/album_backup.json';

      const backupData: BackupData = {
        backupTime: Date.now(),
        photo: { folders: albumData.folders, items: albumData.items, deletedItems: albumData.deletedItems },
        video: { folders: videoData.folders, items: videoData.items, deletedItems: videoData.deletedItems },
        gif: { folders: gifData.folders, items: gifData.items, deletedItems: gifData.deletedItems },
        doc: { folders: docData.folders, items: docData.items, deletedItems: docData.deletedItems },
        record: { folders: recordData.folders, items: recordData.items, deletedItems: recordData.deletedItems }
      };

      const file = fs.openSync(backupPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, JSON.stringify(backupData, null, 2));
      fs.closeSync(file);

      await this.checkLastBackup();
      promptAction.showToast({
        message: '备份成功',
        duration: 2000
      });
    } catch (err) {
      console.error('Backup failed:', JSON.stringify(err));
      promptAction.showToast({
        message: '备份失败',
        duration: 2000
      });
    } finally {
      this.isBackingUp = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })
        Text('备份数据')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
        Blank()
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Column() {
        Text('💾').fontSize(48)
        Text('上次备份: ' + this.lastBackup).fontSize(16).fontColor('#6B7280').margin({ top: 12 })
        Text('将加密相册数据备份到本地文件').fontSize(13).fontColor('#9CA3AF').margin({ top: 4 })
        Button(this.isBackingUp ? '备份中...' : '立即备份')
          .width('60%').height(44).fontSize(16).fontColor('#FFFFFF')
          .backgroundColor(this.isBackingUp ? '#9CA3AF' : '#6366F1')
          .borderRadius(8).margin({ top: 20 })
          .enabled(!this.isBackingUp)
          .onClick(() => { void this.handleBackup(); })
      }
      .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
