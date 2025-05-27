import TCPSocketServerSingleton from '../model/Tcp';
import GlobalData from '../model/Tcp_data'
import {Auto_item1} from '../viewmodel/Auto_item'
import {EmergencyContact} from '../viewmodel/Auto_item'
import { promptAction } from '@kit.ArkUI';

@CustomDialog
struct EmergencyContactDialog {

  controller: CustomDialogController = new CustomDialogController({
    builder: EmergencyContactDialog({}),
  })

  confirm: (name: string, phone: string) => void = () => {
    if (this.validateInput()) {
      // 保存逻辑应该通过回调传递给父组件
      this.controller.close()
    }
  }
  currentContact:EmergencyContact=new EmergencyContact()
  @State tempName: string=''
  @State tempPhone: string=''
  constructor(controller: CustomDialogController,

    confirm: (name: string, phone: string) => void,
    currentContact: EmergencyContact) {
    super();
    this.controller = controller
    this.confirm = confirm
    this.currentContact = currentContact
    this.tempName = currentContact.name
    this.tempPhone = currentContact.phone
  }

  build() {
    Column({ space: 20 }) {
      Text('设置紧急联系人')
        .fontSize(24)
        .margin({ top: 20 })
      // 显示当前联系人信息（如果有）
      if (this.currentContact.name) {
        Text(`当前联系人: ${this.currentContact.name} (${this.currentContact.phone})`)
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 10 })
      }
      // 姓名输入
      TextInput({ placeholder: '姓名' })
        .width('90%')
        .height(50)
        .onChange((value: string) => {
          this.tempName = value
        })

      // 电话输入
      TextInput({ placeholder: '手机号' })
        .width('90%')
        .height(50)
        .type(InputType.Number)
        .maxLength(11)
        .onChange((value: string) => {
          this.tempPhone = value
        })

      Row({ space: 30 }) {
        Button('取消')
          .backgroundColor('#eca94e')
          .onClick(() => {
            this.controller.close()
          })

        Button('保存')
          .backgroundColor('#eca94e')
          .onClick(() => {
            if (this.validateInput()) {
              this.confirm(this.tempName, this.tempPhone)
              promptAction.showToast({
                message: '紧急联系人设置成功',
                duration: 2000
              })
              this.controller.close()
            }
          })
      }
      .margin({ bottom: 20 })
    }
    .width('100%')
  }

  private validateInput(): boolean {
    if (!this.tempName.trim()) {
      promptAction.showToast({ message: '请输入姓名' })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.tempPhone)) {
      promptAction.showToast({ message: '请输入有效手机号' })
      return false
    }
    return true
  }

}

@Component
export struct Setting_Page{

  @State emergencyContact: EmergencyContact = { name: '', phone: '' }
  // 添加对话框回调函数
  private openEmergencyDialog() {
    this.dialogController = new CustomDialogController({
      builder: EmergencyContactDialog({
        controller: this.dialogController!,
        confirm: this.onConfirm.bind(this),
        currentContact: this.emergencyContact // 传递当前联系人
      })
    })
    this.dialogController.open()
  }

  private onConfirm(name: string, phone: string) {
    this.emergencyContact = { name, phone }
    // 这里可以添加TCP发送逻辑
    console.log(`保存紧急联系人: ${name} - ${phone}`)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: EmergencyContactDialog(),
  })

  private tcpSingleton = TCPSocketServerSingleton.getInstance();
  private tcp_data = GlobalData.getInstance()
  @State Auto : Auto_item1 = {name:'',status:false}
  @State BOnSt:promptAction.ShowToastOptions = {'message': this.Auto.name+'已开启.'}
  @State BOffSt:promptAction.ShowToastOptions = {'message':  this.Auto.name+'关闭.'}

  build() {
    Scroll(){
      Column() {
        Row() {
          Text("设置中心")
            .fontSize(32)
            .fontWeight(32)
            .margin({ left: 32, top: 18, bottom: 14 })

        }
        .height('10%')
        .width("100%")
        .height(72)
        .backgroundColor("#ffffffff")
        .justifyContent(FlexAlign.Start)

        Grid() {
          GridItem() {
            this.Setting_Card($rawfile('Car_show.png'), "汽车状态", "ALL GOOD，状态良好")
          }
          .onClick(()=>{
            promptAction.showToast({
              message: '汽车状态良好.',
              duration: 2000
            })
          })

          GridItem() {
            this.Setting_Card($rawfile('Car_relax.png'), "小憩一下", "启动零重力座椅，座椅通风")
          }
          .onClick(() => {
            this.tcp_data.modifyDigit(3, '3');
            this.tcp_data.modifyDigit(1, '0');
            this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
            // 更新全局状态
            AppStorage.setOrCreate('ambientSeatOn', true); // 打开座椅通风
            AppStorage.setOrCreate('Select_Mod', '2'); // 设置为小憩模式
            AppStorage.setOrCreate('fanStatus',true)//车辆信息界面的状态更新
            // AppStorage.setOrCreate("Auto_items",true)//自动化设置页面的状态更新
            promptAction.showToast({
              message: '小憩模式已开启.',
              duration: 2000
            })
          })

          GridItem() {
            this.Setting_Card($rawfile('Car_light.png'), "气氛模式", "打开氛围灯，调为七彩呼吸模式")
          }
          .onClick(() => {
            this.tcp_data.modifyDigit(2, '4');
            this.tcpSingleton.Send_data(this.tcp_data.fourDigitString)
            // 更新全局状态（关键修改）
            AppStorage.setOrCreate('ambientLightOn', true);
            AppStorage.setOrCreate('selectedColor', 'multi');
            AppStorage.setOrCreate('fenStatus',true)
            promptAction.showToast({
              message: '氛围灯已开启.',
              duration: 2000
            })
          })

          GridItem() {
            this.Setting_Card($rawfile('Person_Phone.png'), "设置紧急联系人", "车辆故障时呼叫紧急联系人")
          }
          .onClick(() => {
            this.openEmergencyDialog()
          })

          GridItem() {
            this.Setting_Card($rawfile('recharge.png'), "打开充电口", "  ")
          }
          .onClick(()=>{
            promptAction.showToast({
              message: '充电口已开启.',
              duration: 2000
            })
          })

          GridItem() {
            this.Setting_Card($rawfile('gas_add.png'), "打开加油口", "  ")
          }
          .onClick(()=>{
            promptAction.showToast({
              message: '加油口已开启.',
              duration: 2000
            })
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(5)
        .rowsGap(15)
        .height("85%")
        .width("95%")
        .margin({ left: 10 })

      }
      .width('100%')
      .height('100%')
    }

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



