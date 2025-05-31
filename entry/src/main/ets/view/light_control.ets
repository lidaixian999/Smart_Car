//灯光控制页面
import { SsapManager } from '../model/SsapManager';
import GlobalData from '../model/Tcp_data'
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
  export struct LightControl {
  private ssapManager = SsapManager.getInstance();
  private tcp_data = GlobalData.getInstance()
    progress: number = 100; // 进度值，范围 0 - 100
  @StorageLink('ambientLightOn') ambientLightOn: boolean = false;
  @StorageLink('selectedColor') selectedColor: string = 'white';
  @Consume('pageInfos') pageInfos: NavPathStack;

  aboutToAppear(): void {

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
  buildColorButton(label: string, color: string) {
    Button(label)
      .width('80%')
      .height(60)
      .backgroundColor(this.selectedColor === color ? '#eca94e' : '#F5F5F5')
      .fontColor(this.selectedColor === color ? '#000000' : '#999999')
      .onClick(() => {
        this.selectedColor = color;
        switch (this.selectedColor) {
          case'multi':
            this.tcp_data.modifyDigit(2, "4");
            break;
          case'red':
            this.tcp_data.modifyDigit(2, "1");
            break;
          case 'green':
            this.tcp_data.modifyDigit(2, "3");
            break;
          case 'blue':
            this.tcp_data.modifyDigit(2, "2");
            break;
          default:
            console.log('未知颜色选择');
        }

        this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
      })
  }

  @Builder
  buildLightControlCard(title: string, isOn: boolean, onChange: (isOn: boolean) => void) {
    Column() {
      // 标题
      Text(title)
        .fontSize(20)
        .margin({ bottom: 15 })
        .fontColor('#000000') // 确保黑色文字

      // 开关按钮组（优化版）
      Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
        Button('开')
          .width(80)
          .height(40)
          .backgroundColor(isOn ? '#eca94e' : '#F5F5F5')
          .fontColor(isOn ? '#000000' : '#999999')
          .stateEffect(isOn) // 启用按压效果
          .onClick(() => {
            onChange(true);
            animateTo({ duration: 200 }, () => {}) // 添加点击动画
          })

        Button('关')
          .width(80)
          .height(40)
          .backgroundColor(!isOn ? '#eca94e' : '#F5F5F5')
          .fontColor(!isOn ? '#000000' : '#999999')
          .stateEffect(!isOn)
          .onClick(() => {
            onChange(false);
            animateTo({ duration: 200 }, () => {})
          })
      }
    }
    .width('45%')
    .padding(15)
    .backgroundColor('#FAF1E5')
    .borderRadius(12)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部进度条
        Progress({
          value: this.progress,
          total: 100,
          style: ProgressStyle.Linear
        })
          .color("#ff1f1e1e")
          .width('90%')
          .height(10)
          .margin({ top: 10, bottom: 20 })
        Scroll() {
          // 氛围灯控制区
          Column() {
            Text('氛围灯')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
              .width('100%')
            Flex({ justifyContent: FlexAlign.SpaceAround }) {
              Button('是')
                .width(100)
                .height(40)
                .backgroundColor(this.ambientLightOn ? '#eca94e' : '#F5F5F5')
                .fontColor(this.ambientLightOn ? '#000000' : '#999999')
                .onClick(() => {
                  this.ambientLightOn = true;
                  this.selectedColor ='multi'
                  this.tcp_data.modifyDigit(2,"4")
                  AppStorage.setOrCreate('fenStatus',true)
                  this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
                  // this.send('ambient_on');
                })
              Button('否')
                .width(100)
                .height(40)
                .backgroundColor(!this.ambientLightOn ? '#eca94e' : '#F5F5F5')
                .fontColor(!this.ambientLightOn ? '#000000' : '#999999')
                .onClick(() => {
                  this.ambientLightOn = false;
                  this.tcp_data.modifyDigit(2,"0")
                  AppStorage.setOrCreate('fenStatus',false)
                  this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
                  // this.send('ambient_off');
                })
            }
            if(this.ambientLightOn){
              // 灯光模式控制区
              Blank()
              Text('灯光模式')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 15 ,top:15})
                .width('100%')
              Grid() {
                GridItem() {
                  this.buildColorButton('七彩灯', 'multi')
                }
                GridItem() {
                  this.buildColorButton('红', 'red')
                }
                GridItem() {
                  this.buildColorButton('绿', 'green')
                }
                GridItem() {
                  this.buildColorButton('蓝', 'blue')
                }
              }
              .columnsTemplate('1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .columnsGap(15)
              .rowsGap(15)
              .height(180)
            }
          }
          .width('90%')
          .padding(15)
          .backgroundColor('#FAFAFA')
          .borderRadius(12)
          .margin({ bottom: 20 })

        }
      }

      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .title(this.buildTitle('灯光控制'))
  }
}