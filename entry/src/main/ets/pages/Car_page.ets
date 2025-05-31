@Component
export  struct car_page_item{
  build() {
    Navigation() {

        Flex({direction:FlexDirection.Row}){
          Flex({direction:FlexDirection.Column}){
            Image($rawfile('car_status.png'))
              .objectFit(ImageFit.Auto)
              .height('60%')
              .width("auto")
            TextClock()
              .format("yyyy年M月d日")
              .fontSize(25)
              .fontWeight(FontWeight.Medium)
            TextClock()
              .fontSize(25)
              .format("aa hh:mm:ss")
              .dateTimeOptions({ hour: "2-digit" })
              .fontWeight(FontWeight.Bold)
          }
          .margin({left:24})
        }

    }
    .width("100%")
    .height("95%")
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title("车辆状态良好")
  }
}