//车辆信息页面

@Component
@Preview
export struct carInformationItem {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State batteryLevel: number = 100; //电池电量
  @State mileage: number = 500;      //里程数
  @State fanStatus: boolean = true;   //风扇状态
  @State carinTemp: number = 24;      //车内温度
  @State humidity: string = '30';    //湿度
  @State editMode: boolean = false;
  @State currentEditItem: string = '';
  @State progress: number = 100;//进度条
  @State light_number: number = 3918;//亮度
  @Builder
  buildInfoRow(icon: Resource, text: string, value: string) {
    Flex({ alignItems: ItemAlign.Center }) {
      Image(icon)
        .width(40)
        .height(40)
        .margin({ right: 15 })

      Text(text)
        .fontSize(18)
        .layoutWeight(1) // 占据剩余空间

      if (value) {
        Text(value)
          .fontSize(16)
          .fontColor('#666')
      }
    }
    .width('100%')
    .height(60)
  }
  @Builder
  buildTitle(title: string){
    Text(title)
      .fontSize(40)
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 10,top: 10})
      .width('100%')
      .textAlign(TextAlign.Center)
  }
  @Builder
  buildEditableItem(icon: Resource, label: string, value: string) {
    Flex({ alignItems: ItemAlign.Center }) {
      Image(icon)
        .width(40)
        .height(40)
        .margin({ right: 15 })

      Text(`${label}: `)
        .fontSize(18)

      Text(value)
        .fontSize(18)
        .fontColor('#ff181c24')
        .border({ width: 1, color: '#ff181c24', radius: 4 })
        .padding(8)
    }
  }
  //电池电量与里程数转换
  updateMileage() {
    this.mileage = Math.floor(this.batteryLevel * 5); // 假设1%电量=5km
  }

  showTextInput(field: string) {
    this.currentEditItem = field;
  }
  build() {
    NavDestination() {
      Column() {
        // 进度条部分
        Row() {
          Progress({
            value: this.progress,
            total: 100,
            style: ProgressStyle.Linear
          })
            .color("#ff1f1e1e") // 进度条颜色
            .width('100%')
            .height(20)
            .borderRadius(10); // 添加圆角效果
        }
        .margin({ top: "10px", bottom: "10px" }) // 上下均增加边距
        .width("100%")
        .height("auto");

        // 剩余电量信息
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_battery.png'))
            .width('48vp') // 小一点的图标尺寸
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("剩余电量: " + this.progress + "%  ")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        Divider()

        // 剩余里程信息
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_car.png'))
            .width('48vp') // 图标尺寸与电量图标一致
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("剩余里程: " + (this.progress * 5) + "km")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        Divider()

        //亮度信息
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_light.png'))
            .width('48vp') // 小一点的图标尺寸
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("大灯亮度: " + this.light_number+"lx")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        Divider()

        //风扇状态
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_fan.png'))
            .width('48vp') // 小一点的图标尺寸
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("风扇状态:   " + `${this.fanStatus===true?'开':'关'}` + "      ")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        Divider()

        //灯光状态
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_fenwei.png'))
            .width('48vp') // 小一点的图标尺寸
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("氛围灯:   " + `${this.fanStatus===true?'开':'关'}` + "      ")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        Divider()

        //当前温度
        Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
          Image($rawfile('ic_temp.png'))
            .width('48vp') // 小一点的图标尺寸
            .height('48vp')
            .objectFit(ImageFit.Cover)
            .margin({ left: 12, right: 12 }) // 调整左右边距

          Text("当前温度:   " + `${this.carinTemp}` + "℃ ")
            .fontSize(24) // 较小的字体尺寸
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .margin({ right: 12 });
        }
        .margin({ top: "15px" }) // Flex部分的上边距
        .width("100%")
        .height("13%");

        // // 信息列表

        //   //4. 电池温度
        //   this.buildEditableItem(
        //         $r('app.media.ic_temp'),
        //         '电池温度',
        //         `${this.batteryTemp}°C`
        //       )
        //   //5.车内温度
        //   this.buildEditableItem(
        //         $r('app.media.ic_car_temp'),
        //         '车内温度',
        //         `${this.carinTemp}°C`
        //       )

      }
      .padding(20)
    }
    .title(this.buildTitle('车辆信息'))
  }

}