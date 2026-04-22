import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

@Preview
@Entry
@Component
struct PhoneTransferPage {
  @State transferCode: string = '';
  @State isSearching: boolean = false;
  @State discoveredDevices: string[] = [];

  private generateCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  aboutToAppear(): void {
    this.transferCode = this.generateCode();
  }

  handleSearch(): void {
    this.isSearching = true;
    this.discoveredDevices = [];
    setTimeout(() => {
      this.discoveredDevices = ['iPhone 15 Pro', 'Mate 60 Pro', 'Pixel 8'];
      this.isSearching = false;
      promptAction.showToast({
        message: `发现 ${this.discoveredDevices.length} 台设备`,
        duration: 2000
      });
    }, 2000);
  }

  handleConnect(device: string): void {
    promptAction.showToast({
      message: `正在连接 ${device}...`,
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
        Text('手机互传')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
        Blank()
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('本机传输码').fontSize(14).fontColor('#6B7280')
          Text(this.transferCode)
            .fontSize(36).fontWeight(FontWeight.Bold).fontColor('#6366F1')
            .letterSpacing(4)
          Text('在另一台设备上输入此代码以建立连接')
            .fontSize(13).fontColor('#9CA3AF')
        }

        Button(this.isSearching ? '搜索中...' : '搜索附近设备')
          .width('60%').height(44).fontSize(16).fontColor('#FFFFFF')
          .backgroundColor(this.isSearching ? '#9CA3AF' : '#6366F1')
          .borderRadius(8)
          .enabled(!this.isSearching)
          .onClick(() => { this.handleSearch(); })

        if (this.discoveredDevices.length > 0) {
          Column({ space: 8 }) {
            Text('发现的设备').fontSize(14).fontColor('#6B7280').width('100%')
            ForEach(this.discoveredDevices, (device: string) => {
              Row({ space: 12 }) {
                Text('📱').fontSize(24)
                Text(device).fontSize(16).fontColor('#111827').layoutWeight(1)
                Text('连接')
                  .fontSize(13).fontColor('#6366F1')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .onClick(() => { this.handleConnect(device); })
              }
              .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8)
            }, (device: string) => device)
          }
          .width('100%').padding({ left: 16, right: 16 })
        }
      }
      .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
