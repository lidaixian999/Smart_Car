@Component
export  struct car_page_item{
  build() {
    Navigation() {
      Flex({direction:FlexDirection.Row}){
        Flex({direction:FlexDirection.Column}){
          Image($rawfile('Car_colum_show.png'))
            .objectFit(ImageFit.Auto)
            .height('95%')
            .width("auto")

          Text("当前时间")
            .fontSize(24)
          TextClock()
            .fontSize(32)
            .format("aa hh:mm:ss")
            .dateTimeOptions({ hour: "2-digit" })
            .fontWeight(24)
        }
        .margin({left:24})
      }
    } .width("30%")
    .height("95%")
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title("车辆状态")
  }
}