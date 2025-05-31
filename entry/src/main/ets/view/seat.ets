import { SsapManager } from '../model/SsapManager';
import GlobalData from '../model/Tcp_data'
@Component
export struct SeatItem {

  private ssapManager = SsapManager.getInstance();
  private tcp_data = GlobalData.getInstance();
  progress: number = 100; // 进度值，范围 0 - 100
  @Consume('pageInfos') pageInfos: NavPathStack;
  @StorageLink ("ambientSeatOn") ambientSeatOn: boolean = false;
  @StorageLink ("Select_Seat") Select_seat:string = 'close'
  @StorageLink ("Select_Mod") selected_Mod: string = '1'; // 新增颜色选择状态



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
  buildColorButton(label: string, Mod: string) {
    Button(label)
      .width('80%')
      .height(60)
      .backgroundColor(this.selected_Mod === Mod ? '#eca94e' : '#F5F5F5')
      .fontColor(this.selected_Mod === Mod ? '#000000' : '#999999')
      .onClick(() => {
        switch (Mod) {
          case '1':
            this.tcp_data.modifyDigit(3, '0');
            break;
          case '2':
            this.tcp_data.modifyDigit(3, '3');
            break;
          case '3':
            this.tcp_data.modifyDigit(3, '2');
            break;
          default:
            console.log('未知模式选择');
        }
        this.selected_Mod = Mod;
        this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
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
      Scroll(){
        Column() {
          Text('座椅模式')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })
            .width('100%')

          Grid() {
            GridItem() {
              this.buildColorButton('正常模式', '1')
            }
            GridItem() {
              this.buildColorButton('小憩模式', '2')
            }
            GridItem() {
              this.buildColorButton('躺平模式', '3')
            }
          }
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .columnsGap(15)
          .rowsGap(15)
          .height(180)

          Text('手动打开座椅通风')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })
            .width('100%')

          Flex({ justifyContent: FlexAlign.SpaceAround }) {
            Button('是')
              .width(100)
              .height(40)
              .backgroundColor(this.ambientSeatOn ? '#eca94e' : '#F5F5F5')
              .fontColor(this.ambientSeatOn ? '#000000' : '#999999')
              .onClick(() => {
                this.ambientSeatOn = true;
                this.tcp_data.modifyDigit(1,"2")
                this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
                // AppStorage.setOrCreate('fanStatus',true)
                // this.send('ambient_on');
              })

            Button('否')
              .width(100)
              .height(40)
              .backgroundColor(!this.ambientSeatOn ? '#eca94e' : '#F5F5F5')
              .fontColor(!this.ambientSeatOn ? '#000000' : '#999999')
              .onClick(() => {
                this.ambientSeatOn = false;
                this.tcp_data.modifyDigit(1,"1")
                this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
                // AppStorage.setOrCreate('fanStatus',false)
                // this.send('ambient_off');
              })
          }
        }
        .width('90%')
        .padding(15)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
        .margin({ bottom: 20 })

      }

    }
    .title(this.buildTitle('座椅调节'))
  }
}