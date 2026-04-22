import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

interface ImportSource {
  id: string;
  icon: string;
  title: string;
  description: string;
}

interface ImportRouterParams {
  folderId: string;
  folderName: string;
}

@Entry
@Component
struct ImportGuidePage {
  @State folderId: string = '';
  @State folderName: string = '主目录';

  private importSources: ImportSource[] = [
    {
      id: 'system_album',
      icon: '🖼️',
      title: '系统相册',
      description: '从手机自带相册中选择照片导入到当前目录'
    },
    {
      id: 'local_file',
      icon: '📁',
      title: '本地文件',
      description: '从手机本地存储中选择图片文件导入'
    },
    {
      id: 'camera',
      icon: '📷',
      title: '拍照',
      description: '直接拍摄照片并保存到当前目录'
    },
    {
      id: 'app_share',
      icon: '📤',
      title: '应用分享',
      description: '通过系统分享功能从其他应用接收照片'
    }
  ];

  aboutToAppear() {
    const params = router.getParams() as ImportRouterParams;
    this.folderId = params?.folderId || '';
    this.folderName = params?.folderName || '主目录';
  }

  handleImport(source: ImportSource) {
    promptAction.showToast({
      message: `开发中：${source.title}导入功能即将上线`,
      duration: 2000
    });
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })

        Text('导入照片')
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
        ForEach(this.importSources, (source: ImportSource) => {
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

      Text('导入的照片将保存在当前选中的目录中')
        .fontSize(12).fontColor('#9CA3AF')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 24 })
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
