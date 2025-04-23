

@Component
export  struct Setting_Page{
  build() {
    Column(){
       Row(){
         Text("设置中心")
           .fontSize(32)
           .fontWeight(32)
           .margin({left:32,top:18,bottom:18})

       }
       .height('10%')
       .width("100%")
       .height(72)
       .backgroundColor("#ffffffff")
      .justifyContent(FlexAlign.Start)

      Grid(){
          GridItem(){
            this.Setting_Card($rawfile('Car_show.png'),"汽车状态","ALL GOOD，状态良好")
          }
          GridItem(){
             this.Setting_Card($rawfile('Car_relax.png'),"小憩一下","启动零重力座椅，座椅通风")
           }
          GridItem(){
            this.Setting_Card($rawfile('Car_light.png'),"气氛模式","打开氛围灯，调为呼吸模式")
          }
          GridItem(){
            this.Setting_Card($rawfile('Person_Phone.png'),"设置紧急联系人","车辆故障时呼叫紧急联系人")
          }
          GridItem(){
            this.Setting_Card($rawfile('recharge.png'),"打开充电口","  ")
          }
          GridItem(){
            this.Setting_Card($rawfile('gas_add.png'),"打开加油口","  ")
          }

      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(5)
      .rowsGap(15)
      .height("85%")
      .width("95%")
      .margin({left:10})




   }
   .width('100%')
    .height('100%')



  }



  @Builder
  Setting_Card(imageUrl:Resource, title: string, description: string) {
    Column({ space: 10 }) {
      Image(imageUrl)
        .width('100%')
        .height(150)
        .objectFit(ImageFit.Cover)
        .borderRadius(10)

      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Text(description)
        .fontSize(14)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(10)

  }

}

