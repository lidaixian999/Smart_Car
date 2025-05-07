//自动化设置页面

import TCPSocketServerSingleton from '../model/Tcp';
import GlobalData from '../model/Tcp_data'
import { promptAction } from '@kit.ArkUI';
import { it } from '@ohos/hypium';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {Auto_item1} from '../viewmodel/Auto_item'

@Preview
@Component
export struct AutoSet {
  private tcpSingleton = TCPSocketServerSingleton.getInstance();
  private tcp_data = GlobalData.getInstance()

  progress: number = 100; // 进度值，范围 0 - 100
  @Consume('pageInfos') pageInfos: NavPathStack;

  @StorageLink ("Auto_items")  autoItems: Auto_item1[] = [
  { name: "自动车前大灯", status: true },
  { name: "自动座椅通风", status: true },
  { name: "自动雨刷控制", status: true }
];
  @Builder
  buildTitle(title: string){
    Text(title)
      .fontSize(40)
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 10,top: 10})
      .width('100%')
      .textAlign(TextAlign.Center)
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

      Flex({justifyContent:FlexAlign.Start,direction:FlexDirection.Column}){
        List({space:20}){
        ForEach(this.autoItems,(item:Auto_item1)=>{
          Auto_list_items({ Auto:item })
        })
        }
      }
      .height("100%")
      .width("100%")
      .margin({top:5})
  } .title('自动化设置')
  }
}

@Component
struct Auto_list_items{
  private tcpSingleton = TCPSocketServerSingleton.getInstance();
  private tcp_data = GlobalData.getInstance()
  @State Auto : Auto_item1 = {name:'',status:false}
  @State BOnSt:promptAction.ShowToastOptions = {'message': this.Auto.name+'开启.'}
  @State BOffSt:promptAction.ShowToastOptions = {'message':  this.Auto.name+'关闭.'}
  aboutToAppear(): void {
    this.BOnSt ={'message':  this.Auto.name+'开启.'}
    this.BOffSt = {'message':  this.Auto.name+'关闭.'}
  }
  build(){
     Row(){
       Text( this.Auto.name)
         .height(50)
         .padding({left: 10})
         .fontWeight(FontWeight.Bold)
         .fontSize(25)
         .textAlign(TextAlign.Start)
         .fontColor($r('app.color.brouwn'))
       Blank()
       Toggle({ type: ToggleType.Switch,isOn: this.Auto.status })
         .height(32)
         .width(72)
         .selectedColor($r('app.color.brouwn'))
         .margin({left: 10, right: 10})
         .onChange((isOn: boolean) => {
           this.Auto.status = isOn;
           if(isOn) {
             promptAction.showToast(this.BOnSt)
             if(this.Auto.name == "自动车前大灯"){
               this.tcp_data.modifyDigit(0,"0")
             }else if(this.Auto.name == "自动座椅通风"){
               this.tcp_data.modifyDigit(1,"0")
               AppStorage.setOrCreate('ambientSeatOn', true);
               AppStorage.setOrCreate('fanStatus',true)
             }

             this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
           } else {
             promptAction.showToast(this.BOffSt)
             if(this.Auto.name == "自动车前大灯"){

               this.tcp_data.modifyDigit(0,"1")
             }else if(this.Auto.name == "自动座椅通风"){

               this.tcp_data.modifyDigit(1,"1")
               AppStorage.setOrCreate('ambientSeatOn', false);
               AppStorage.setOrCreate('fanStatus',false)
             }
             this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
           }
         })
     }
     .margin({left:"5%"})
     .backgroundColor($r('app.color.light_white'))
     .height(82)
     .width("90%")
     .borderRadius(5)

  }
}