import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { cameraPicker } from '@kit.CameraKit';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { getDataManager, MediaDataManager } from '../models/AlbumData';

interface ImportSource {
  id: string;
  icon: string;
  title: string;
  description: string;
}

interface ImportRouterParams {
  folderId: string;
  folderName: string;
  contentType: string;
}

@Entry
@Component
struct ImportGuidePage {
  @State folderId: string = '';
  @State folderName: string = '主目录';
  @State contentType: string = 'photo';

  private dataManager: MediaDataManager = getDataManager('photo');

  private getImportSources(): ImportSource[] {
    switch (this.contentType) {
      case 'video':
        return [
          { id: 'system_album', icon: '🎬', title: '系统相册', description: '从手机自带相册中选择视频导入到当前目录' },
          { id: 'local_file', icon: '📁', title: '本地文件', description: '从手机本地存储中选择视频文件导入' },
          { id: 'camera', icon: '📷', title: '录像', description: '直接拍摄视频并保存到当前目录' },
          { id: 'app_share', icon: '📤', title: '应用分享', description: '通过系统分享功能从其他应用接收视频' }
        ];
      case 'gif':
        return [
          { id: 'system_album', icon: '🎭', title: '系统相册', description: '从手机自带相册中选择动图导入到当前目录' },
          { id: 'local_file', icon: '📁', title: '本地文件', description: '从手机本地存储中选择动图文件导入' },
          { id: 'app_share', icon: '📤', title: '应用分享', description: '通过系统分享功能从其他应用接收动图' }
        ];
      case 'doc':
        return [
          { id: 'local_file', icon: '📄', title: '本地文件', description: '从手机本地存储中选择文档文件导入' },
          { id: 'cloud_drive', icon: '☁️', title: '云盘导入', description: '从云存储服务下载文档到当前目录' },
          { id: 'app_share', icon: '📤', title: '应用分享', description: '通过系统分享功能从其他应用接收文档' },
          { id: 'download', icon: '⬇️', title: '链接下载', description: '通过链接下载文档到当前目录' }
        ];
      case 'record':
        return [
          { id: 'record_audio', icon: '🎙️', title: '录音', description: '直接录制音频并保存到当前目录' },
          { id: 'local_file', icon: '📁', title: '本地文件', description: '从手机本地存储中选择音频或文件导入' },
          { id: 'app_share', icon: '📤', title: '应用分享', description: '通过系统分享功能从其他应用接收文件' }
        ];
      default:
        return [
          { id: 'system_album', icon: '🖼️', title: '系统相册', description: '从手机自带相册中选择照片导入到当前目录' },
          { id: 'local_file', icon: '📁', title: '本地文件', description: '从手机本地存储中选择图片文件导入' },
          { id: 'camera', icon: '📷', title: '拍照', description: '直接拍摄照片并保存到当前目录' },
          { id: 'app_share', icon: '📤', title: '应用分享', description: '通过系统分享功能从其他应用接收照片' }
        ];
    }
  }

  getPageTitle(): string {
    switch (this.contentType) {
      case 'video': return '导入视频';
      case 'gif': return '导入动图';
      case 'doc': return '导入资料';
      case 'record': return '导入文件';
      default: return '导入照片';
    }
  }

  aboutToAppear() {
    const params = router.getParams() as ImportRouterParams;
    this.folderId = params?.folderId || '';
    this.folderName = params?.folderName || '主目录';
    this.contentType = params?.contentType || 'photo';
    this.dataManager = getDataManager(this.contentType);
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private extractNameFromUri(uri: string): string {
    const parts = uri.split('/');
    let name = parts[parts.length - 1] || '未命名';
    const queryIndex = name.indexOf('?');
    if (queryIndex > 0) {
      name = name.substring(0, queryIndex);
    }
    return decodeURIComponent(name);
  }

  private async getFileSize(uri: string): Promise<number> {
    try {
      const stat = await fs.stat(uri);
      return stat.size;
    } catch {
      return 0;
    }
  }

  private async importFromSystemAlbum(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
        maxSelectNumber: 9
      });
      if (result.photoUris && result.photoUris.length > 0) {
        for (const uri of result.photoUris) {
          const name = this.extractNameFromUri(uri);
          const size = await this.getFileSize(uri);
          this.dataManager.addItem(name, this.folderId, uri, size);
        }
        promptAction.showToast({
          message: `已导入 ${result.photoUris.length} 项`,
          duration: 2000
        });
      }
    } catch (err) {
      console.error('System album import failed:', JSON.stringify(err));
      promptAction.showToast({
        message: '导入失败，请检查权限',
        duration: 2000
      });
    }
  }

  private async importFromLocalFile(): Promise<void> {
    try {
      const documentPicker = new picker.DocumentViewPicker();
      const result = await documentPicker.select({
        maxSelectNumber: 9
      });
      const uris: string[] = (result as Object as Record<string, string[]>).result ?? [];
      if (uris.length > 0) {
        for (const uri of uris) {
          const name = this.extractNameFromUri(uri);
          const size = await this.getFileSize(uri);
          this.dataManager.addItem(name, this.folderId, uri, size);
        }
        promptAction.showToast({
          message: `已导入 ${uris.length} 项`,
          duration: 2000
        });
      }
    } catch (err) {
      console.error('Local file import failed:', JSON.stringify(err));
      promptAction.showToast({
        message: '导入失败，请检查权限',
        duration: 2000
      });
    }
  }

  private async importFromCamera(): Promise<void> {
    try {
      const mediaType = this.contentType === 'video'
        ? cameraPicker.PickerMediaType.VIDEO
        : cameraPicker.PickerMediaType.PHOTO;
      const result = await cameraPicker.pick(this.getAbilityContext(), [mediaType], { cameraPosition: 0 });
      const resultUri: string = (result as Object as Record<string, string>).resultUri ?? '';
      if (resultUri.length > 0) {
        const name = this.extractNameFromUri(resultUri);
        const size = await this.getFileSize(resultUri);
        this.dataManager.addItem(name, this.folderId, resultUri, size);
        promptAction.showToast({
          message: '拍摄完成，已保存到当前目录',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('Camera import failed:', JSON.stringify(err));
      promptAction.showToast({
        message: '拍摄失败或已取消',
        duration: 2000
      });
    }
  }

  private async recordAudio(): Promise<void> {
    try {
      const want: Want = {
        action: 'ohos.want.action.record',
        parameters: {
          callBundleName: this.getAbilityContext().applicationInfo.name
        }
      };
      await this.getAbilityContext().startAbility(want);
      promptAction.showToast({
        message: '已启动系统录音，请手动将录音文件导入',
        duration: 3000
      });
    } catch (err) {
      console.error('Record audio failed:', JSON.stringify(err));
      promptAction.showToast({
        message: '无法启动录音应用',
        duration: 2000
      });
    }
  }

  handleImport(source: ImportSource) {
    switch (source.id) {
      case 'system_album':
        void this.importFromSystemAlbum();
        break;
      case 'local_file':
        void this.importFromLocalFile();
        break;
      case 'camera':
        void this.importFromCamera();
        break;
      case 'record_audio':
        void this.recordAudio();
        break;
      case 'app_share':
        promptAction.showToast({
          message: '请从其他应用通过「分享」选择本应用接收',
          duration: 3000
        });
        break;
      case 'cloud_drive':
        promptAction.showToast({
          message: '请先从云盘下载到本地，再通过「本地文件」导入',
          duration: 3000
        });
        break;
      case 'download':
        promptAction.showToast({
          message: '请使用浏览器下载后，通过「本地文件」导入',
          duration: 3000
        });
        break;
      default:
        promptAction.showToast({
          message: `开发中：${source.title}导入功能即将上线`,
          duration: 2000
        });
    }
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })

        Text(this.getPageTitle())
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
          .layoutWeight(1)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Row() {
        Text(`导入到：${this.folderName}`)
          .fontSize(14).fontColor('#6366F1').fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 12 })

      List({ space: 12 }) {
        ForEach(this.getImportSources(), (source: ImportSource) => {
          ListItem() {
            Row({ space: 16 }) {
              Text(source.icon)
                .fontSize(36)

              Column({ space: 6 }) {
                Text(source.title)
                  .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#111827')
                Text(source.description)
                  .fontSize(13).fontColor('#6B7280')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('›')
                .fontSize(24).fontColor('#D1D5DB')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .onClick(() => { this.handleImport(source); })
        }, (source: ImportSource) => source.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)

      Text('导入的内容将保存在当前选中的目录中')
        .fontSize(12).fontColor('#9CA3AF')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 24 })
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
