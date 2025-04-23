//灯光控制页面
import TCPSocketServerSingleton from '../model/Tcp';
import GlobalData from '../model/Tcp_data'
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// class SocketInfo {
//   message: ArrayBuffer = new ArrayBuffer(1);
//   remoteInfo: socket.SocketRemoteInfo = {} as socket.SocketRemoteInfo;
// }
// // 创建一个TCPSocket连接，返回一个TCPSocket对象。
// let tcp: socket.TCPSocket = socket.constructTCPSocketInstance();
// let tcp_send_Options: socket.TCPSendOptions = {
//   data: 'Hello, server!'
// }
//
// tcp.on('message', (value: SocketInfo) => {
//   console.log("on message");
//   let buffer = value.message;
//   let dataView = new DataView(buffer);
//   let str = "";
//   for (let i = 0; i < dataView.byteLength; ++i) {
//     str += String.fromCharCode(dataView.getUint8(i));
//   }
//   console.log("on connect received:" + str);
// });
//
// tcp.on('connect', () => {
//   console.log("on connect");
// });
// tcp.on('close', () => {
//   console.log("on close");
// });
//
//   // 连接到指定的IP地址和端口。
// // let bindAddr: socket.NetAddress = {
// //     address:  "192.168.137.81", //"127.0.0.1" ,//"192.168.137.13",
// //     port:5678//4120
// //   }
// let bindAddr: socket.NetAddress = {
//   address:  "192.168.18.1", //"127.0.0.1" ,//"192.168.137.13",
//   port:4120
// }//测试地址
//
// let tcp_connect_options: socket.TCPConnectOptions = {
//   address: bindAddr,
//   timeout: 6000
// }
//
//   tcp.bind(bindAddr, (err: BusinessError) => {
//     if (err) {
//       console.log('bind fail');
//       return;
//     }
//     console.log('bind success');
//   });
//
//   tcp.connect(tcp_connect_options)
//   .then(() => {
//     console.log('connect success');
//   })
//   .catch((err: BusinessError) => {
//   console.log('connect fail');
// });


@Component
  export struct LightControl {
  private tcpSingleton = TCPSocketServerSingleton.getInstance();
  private tcp_data = GlobalData.getInstance()
    progress: number = 100; // 进度值，范围 0 - 100
    @State ambientLightOn: boolean = true; // 氛围灯状态
    @State autoHeadlightOn: boolean = true; // 自动大灯状态
    @State selectedColor: string = 'white'; // 新增颜色选择状态
    @Consume('pageInfos') pageInfos: NavPathStack;

  aboutToAppear(): void {

  }
  //  async  send(command: string){
  //    tcp_send_Options = { data: command };
  //    tcp.connect(tcp_connect_options)
  //      .then(() => {
  //        console.log('connect success');
  //      })
  //      .catch((err: BusinessError) => {
  //        console.log('connect fail');
  //      });
  //
  //     tcp.send(tcp_send_Options, (err: BusinessError) => {
  //       if (err) {
  //         console.log('send fail')
  //         return;
  //       }
  //       console.log('send success');
  //     })
  // }
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
        this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
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
                this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
                // this.send('ambient_off');
              })
          }
        }
        .width('90%')
        .padding(15)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
        .margin({ bottom: 20 })

        // 灯光模式控制区
        Column() {
          Text('灯光模式')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })
            .width('100%')

          Grid() {
            GridItem() {
              this.buildColorButton('三色灯', 'multi')
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
        .width('90%')
        .padding(15)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .title(this.buildTitle('灯光控制'))
  }
}