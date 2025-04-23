//无状态时页面

@Component
export struct Nonepage {
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Image($r('app.media.None'))
          .width(200)
          .height(200)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center) // 垂直居中
      .alignItems(HorizontalAlign.Center) // 水平居中
    }
    .title('')
  }
}