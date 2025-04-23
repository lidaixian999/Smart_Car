//温度控制页面
@Component
export struct TemperatureItem {
  progress: number = 100; // 进度值，范围 0 - 100
  @Consume('pageInfos') pageInfos: NavPathStack;
  temperature_number: number = 24;
  temperature_car: number = 26;

  build() {
    NavDestination() {
      Row() {
        Progress({
          value: this.progress,
          total: 100,
          style: ProgressStyle.Linear
        })
          .color("#ff1f1e1e")// 进度条颜色
          .width('100%')
          .height(20)
          .borderRadius(10); // 添加圆角效果
      }
      .margin({ top: "10px", bottom: "10px" }) // 上下均增加边距
      .width("100%")
      .height("auto");

      Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
        Image($rawfile('icloud.png'))
          .width('48vp') // 小一点的图标尺寸
          .height('48vp')
          .objectFit(ImageFit.Cover)
          .margin({ left: 12, right: 12 }) // 调整左右边距
          .borderRadius(24); // 添加圆角效果

        Text("车外气温: " + this.temperature_number + " ℃")
          .fontSize(24) // 较小的字体尺寸
          .fontWeight('bold')
          .margin({ right: 12 });
      }
      .margin({ top: "10px" }) // Flex部分的上边距
      .width("100%")
      .height("auto");

      Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Row }) {
        Image($rawfile('ic_temp_car.png'))
          .width('48vp') // 小一点的图标尺寸
          .height('48vp')
          .objectFit(ImageFit.Cover)
          .margin({ left: 12, right: 12 }) // 调整左右边距
          .borderRadius(24); // 添加圆角效果

        Text("车内温度: " + this.temperature_car + " ℃")
          .fontSize(24) // 较小的字体尺寸
          .fontWeight('bold')
          .margin({ right: 12 });
      }
      .margin({ top: "10px" }) // Flex部分的上边距
      .width("100%")
      .height("auto");

    }
    .title("温度")
  }
}