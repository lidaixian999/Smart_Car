@Component
export  struct car_page_item{
  build() {
    Navigation() {
      Scroll(){
        Flex({direction:FlexDirection.Row}){
          Flex({direction:FlexDirection.Column}){

            Image($rawfile('Car_colum_show.png'))
              .objectFit(ImageFit.Auto)
              .height('95%')
              .width("auto")


            TextClock()
              .format("yyyy年M月d日")
              .fontSize(30)
            TextClock()
              .fontSize(32)
              .format("aa hh:mm:ss")
              .dateTimeOptions({ hour: "2-digit" })
              .fontWeight(24)


          }
          .margin({left:24})
        }
      }

    } .width("30%")
    .height("95%")
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title("车辆状态")
  }
}