import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';
import { settingsStore } from '../../utils/SettingsStore';

@Preview
@Entry
@Component
struct AppSettingsPage {
  @State autoLock: boolean = true;
  @State lockDelay: number = 1;
  @State autoBackup: boolean = false;

  private delayOptions: number[] = [1, 3, 5, 10, 30];
  private delayLabels: string[] = ['1分钟', '3分钟', '5分钟', '10分钟', '30分钟'];

  aboutToAppear(): void {
    void this.loadSettings();
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private async loadSettings(): Promise<void> {
    await settingsStore.init(this.getAbilityContext());
    this.autoLock = await settingsStore.getAutoLock();
    this.lockDelay = await settingsStore.getLockDelay();
    this.autoBackup = await settingsStore.getAutoBackup();
  }

  private async saveAutoLock(value: boolean): Promise<void> {
    await settingsStore.setAutoLock(value);
    this.autoLock = value;
  }

  private async saveAutoBackup(value: boolean): Promise<void> {
    await settingsStore.setAutoBackup(value);
    this.autoBackup = value;
  }

  private async saveLockDelay(value: number): Promise<void> {
    await settingsStore.setLockDelay(value);
    this.lockDelay = value;
  }

  private cycleLockDelay(): void {
    const currentIndex = this.delayOptions.indexOf(this.lockDelay);
    const nextIndex = (currentIndex + 1) % this.delayOptions.length;
    void this.saveLockDelay(this.delayOptions[nextIndex]);
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button('←')
          .width(36).height(36).fontSize(18).fontColor('#111827')
          .backgroundColor('#FFFFFF').borderRadius(18)
          .onClick(() => { router.back(); })
        Text('App设置')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827')
        Blank()
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Column({ space: 0 }) {
        Row() {
          Text('自动锁定').fontSize(16).fontColor('#111827')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.autoLock })
            .onChange((isOn: boolean) => { void this.saveAutoLock(isOn); })
        }.width('100%').padding(16)

        Divider().color('#E5E7EB')

        Row() {
          Text('锁定延迟').fontSize(16).fontColor('#111827')
          Blank()
          Text(this.delayLabels[this.delayOptions.indexOf(this.lockDelay)] || `${this.lockDelay}分钟`)
            .fontSize(16).fontColor('#6366F1')
        }
        .width('100%').padding(16)
        .onClick(() => { this.cycleLockDelay(); })

        Divider().color('#E5E7EB')

        Row() {
          Text('自动备份').fontSize(16).fontColor('#111827')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.autoBackup })
            .onChange((isOn: boolean) => { void this.saveAutoBackup(isOn); })
        }.width('100%').padding(16)
      }
      .backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16 })

      Blank()
    }
    .width('100%').height('100%').backgroundColor('#F3F6FC')
  }
}
