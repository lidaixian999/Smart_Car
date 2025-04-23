//已停用
@Component
export struct LightItem {
  progress: number = 100; // 进度值，范围 0 - 100
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State selectedColor: string = 'white'; // 新增颜色选择状态
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
  buildColorButton(label: string, color: string) {
    Button(label)
      .width('80%')
      .height(60)
      .backgroundColor(this.selectedColor === color ? '#eca94e' : '#F5F5F5')
      .fontColor(this.selectedColor === color ? '#000000' : '#999999')
      .onClick(() => {
        this.selectedColor = color;
        // this.send(`color_${color}`);
      })
  }


  build() {
    NavDestination() {
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

      // 座椅模式控制区
      Column() {
        Text('座椅模式')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })
          .width('100%')

        Grid() {
          GridItem() {
            this.buildColorButton('正常模式', 'multi')
          }
          GridItem() {
            this.buildColorButton('小憩模式', 'red')
          }
          GridItem() {
            this.buildColorButton('躺平模式', 'green')
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(15)
        .rowsGap(15)
        .height(180)
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#FAFAFA')
      .borderRadius(12)

      //座椅通风及温度设置


    }
    .title(this.buildTitle('座椅调节'))
  }
}