import router from '@ohos.router';

interface MenuItem {
  id: string;
  label: string;
  icon: ResourceStr;
  page: string;
}

@Entry
@Component
struct MainPage {
  private menuItems: MenuItem[] = [
    { id: 'photos', label: '照片', icon: $r('app.media.ic_album_photos'), page: 'pages/PhotosPage' },
    { id: 'videos', label: '视频', icon: $r('app.media.ic_album_videos'), page: 'pages/VideosPage' },
    { id: 'gifs', label: '动图', icon: $r('app.media.ic_album_gifs'), page: 'pages/GifsPage' },
    { id: 'docs', label: '资料', icon: $r('app.media.ic_album_docs'), page: 'pages/DocsPage' },
    { id: 'records', label: '录音&文件', icon: $r('app.media.ic_album_records'), page: 'pages/RecordsPage' },
    { id: 'settings', label: '设置', icon: $r('app.media.ic_album_settings'), page: 'pages/SettingsPage' }
  ];

  private navigateTo(page: string): void {
    router.pushUrl({ url: page });
  }

  build() {
    Column({ space: 0 }) {
      Grid() {
        ForEach(this.menuItems, (item: MenuItem) => {
          GridItem() {
            Column({ space: 18 }) {
              Image(item.icon)
                .width(88)
                .height(88)
                .objectFit(ImageFit.Contain)
              Text(item.label)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#111827')
                .textAlign(TextAlign.Center)
                .maxLines(2)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => { this.navigateTo(item.page); })
          }
        }, (item: MenuItem) => item.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .rowsGap(0)
      .columnsGap(0)
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 18, bottom: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
