import { SsapManager, ScanResultCallback } from '../model/SsapManager';
import GlobalData from '../model/Tcp_data'
import {Auto_item1} from '../viewmodel/Auto_item'
import {EmergencyContact} from '../viewmodel/Auto_item'
import { promptAction } from '@kit.ArkUI';
import { scan } from '@kit.NearLinkKit';

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
    Scroll(){
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

@CustomDialog
struct StarLinkDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: StarLinkDialog({}),
  })

  @State searchText: string = ''
  @State isScanning: boolean = false
  @State scanResults: Array<scan.ScanResults> = []
  @State filteredResults: Array<scan.ScanResults> = []
  @State selectedDevice: scan.ScanResults | null = null
  @State isConnecting: boolean = false

  private ssapManager = SsapManager.getInstance()
  private scanCallback: ScanResultCallback = {
    onDeviceFound: (results: Array<scan.ScanResults>) => {
      this.scanResults = [...results]
      this.filterDevices()
    },
    onConnectionStateChanged: (state) => {
      console.log('Connection state changed:', state)
    },
    onPropertyChanged: (property) => {
      console.log('Property changed:', property)
    }
  }

  constructor(controller: CustomDialogController) {
    super()
    this.controller = controller
  }

  build() {
    Column({ space: 20 }) {
      // 标题
      Text('星闪设备连接')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      // 搜索框
      Row({ space: 10 }) {
        TextInput({ placeholder: '输入设备名称（可选）' })
          .width('60%')
          .height(40)
          .onChange((value: string) => {
            this.searchText = value
            this.filterDevices()
          })

        Button('清除')
          .width('15%')
          .height(40)
          .backgroundColor('#f0f0f0')
          .fontColor(Color.Black)
          .onClick(() => {
            this.searchText = ''
            this.filterDevices()
          })

        Button(this.isScanning ? '停止扫描' : '开始扫描')
          .width('20%')
          .height(40)
          .backgroundColor(this.isScanning ? '#ff6b6b' : '#eca94e')
          .onClick(() => {
            if (this.isScanning) {
              this.stopScan()
            } else {
              this.startScan()
            }
          })
      }
      .width('90%')

      // 设备列表
      if (this.filteredResults.length > 0) {
        Text(`发现的设备 (${this.filteredResults.length}个):`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ left: 20 })

        List() {
          ForEach(this.filteredResults, (device: scan.ScanResults, index: number) => {
            ListItem() {
              Row({ space: 15 }) {
                Column({ space: 5 }) {
                  Text(device.deviceName || '未知设备')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .alignSelf(ItemAlign.Start)
                  
                  Text(`地址: ${device.address}`)
                    .fontSize(12)
                    .fontColor(Color.Gray)
                    .alignSelf(ItemAlign.Start)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('连接')
                  .width(60)
                  .height(30)
                  .fontSize(12)
                  .backgroundColor(this.selectedDevice?.address === device.address ? '#4CAF50' : '#eca94e')
                  .onClick(() => {
                    this.selectedDevice = device
                    this.connectToDevice(device)
                  })
              }
              .width('100%')
              .padding(10)
              .backgroundColor(this.selectedDevice?.address === device.address ? '#e8f5e8' : Color.White)
              .borderRadius(8)
              .margin({ bottom: 5 })
            }
          })
        }
        .width('90%')
        .height(200)
        .borderRadius(8)
        .backgroundColor('#f5f5f5')
      } else if (this.isScanning) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#eca94e')
          Text('正在扫描设备...')
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ left: 10 })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(100)
      } else if (this.scanResults.length > 0 && this.filteredResults.length === 0) {
        Text(`未找到包含"${this.searchText}"的设备`)
          .fontSize(14)
          .fontColor(Color.Gray)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(100)
      } else {
        Text('点击"开始扫描"搜索附近的星闪设备')
          .fontSize(14)
          .fontColor(Color.Gray)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(100)
      }

      // 连接状态显示
      if (this.isConnecting) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#eca94e')
          Text('正在连接设备...')
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ left: 10 })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }

      // 底部按钮
      Row({ space: 30 }) {
        Button('取消')
          .backgroundColor('#eca94e')
          .onClick(() => {
            this.stopScan()
            this.controller.close()
          })

        Button('关闭')
          .backgroundColor('#eca94e')
          .onClick(() => {
            this.stopScan()
            this.controller.close()
          })
      }
      .margin({ bottom: 20 })
    }
    .width('100%')
    .padding(20)
  }

  private filterDevices() {
    if (!this.searchText.trim()) {
      this.filteredResults = [...this.scanResults]
    } else {
      this.filteredResults = this.scanResults.filter(device => 
        (device.deviceName || '').toLowerCase().includes(this.searchText.toLowerCase())
      )
    }
  }

  private async startScan() {
    try {
      this.isScanning = true
      this.scanResults = []
      this.filteredResults = []
      this.ssapManager.registerCallback(this.scanCallback)
      await this.ssapManager.startScan()
      promptAction.showToast({
        message: '开始扫描设备',
        duration: 2000
      })
    } catch (error) {
      this.isScanning = false
      promptAction.showToast({
        message: '扫描失败: ' + error.message,
        duration: 2000
      })
    }
  }

  private async stopScan() {
    try {
      if (this.isScanning) {
        await this.ssapManager.stopScan()
        this.ssapManager.unregisterCallback(this.scanCallback)
        this.isScanning = false
        promptAction.showToast({
          message: '停止扫描',
          duration: 2000
        })
      }
    } catch (error) {
      promptAction.showToast({
        message: '停止扫描失败: ' + error.message,
        duration: 2000
      })
    }
  }

  private async connectToDevice(device: scan.ScanResults) {
    try {
      this.isConnecting = true
      
      // 先停止扫描
      await this.stopScan()
      
      // 尝试连接设备
      this.ssapManager.connectDevice(device.address)
      
      // 监听连接状态变化
      const connectionCallback: ScanResultCallback = {
        onDeviceFound: () => {},
        onConnectionStateChanged: (state) => {
          if (state.state === 0 || 1) { // STATE_CONNECTED
            this.isConnecting = false
            promptAction.showToast({
              message: `已连接到设备: ${device.deviceName || '未知设备'}`,
              duration: 2000
            })
            this.ssapManager.unregisterCallback(connectionCallback)
            this.controller.close()
          } else if (state.state === 2 || 4) { // STATE_DISCONNECTED
            this.isConnecting = false
            promptAction.showToast({
              message: '连接失败，设备已断开',
              duration: 2000
            })
            this.ssapManager.unregisterCallback(connectionCallback)
          }
        },
        onPropertyChanged: () => {}
      }
      
      this.ssapManager.registerCallback(connectionCallback)
      
      // 设置连接超时
      setTimeout(() => {
        if (this.isConnecting) {
          this.isConnecting = false
          promptAction.showToast({
            message: '连接超时，请重试',
            duration: 2000
          })
          this.ssapManager.unregisterCallback(connectionCallback)
        }
      }, 10000) // 10秒超时
      
    } catch (error) {
      this.isConnecting = false
      promptAction.showToast({
        message: '连接失败: ' + error.message,
        duration: 2000
      })
    }
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

  // 打开星闪链接弹窗
  private openStarLinkDialog() {
    this.starLinkDialogController = new CustomDialogController({
      builder: StarLinkDialog({
        controller: this.starLinkDialogController!
      })
    })
    this.starLinkDialogController.open()
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: EmergencyContactDialog(),
  })

  starLinkDialogController: CustomDialogController = new CustomDialogController({
    builder: StarLinkDialog(),
  })

  private ssapManager = SsapManager.getInstance();
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
            .fontWeight(FontWeight.Bold)
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
            this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
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
            this.Setting_Card($rawfile('Car_light.png'), "气氛模式", "打开氛围灯，调为呼吸模式")
          }
          .onClick(() => {
            this.tcp_data.modifyDigit(2, '4');
            this.ssapManager.writeProperty(this.tcp_data.fourDigitString)
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
            this.Setting_Card($rawfile('Near_Link.png'), "星闪链接", "搜索并连接星闪设备")
          }
          .onClick(()=>{
            this.openStarLinkDialog()
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(5)
        .rowsGap(15)
        .height("95%")
        .width("95%")
        .margin({ left: 10,top:10,bottom:10})
      }
      .margin({bottom:"10%"})
      .width('100%')
      .height('100%')
    }

  }




  @Builder
  Setting_Card(imageUrl:Resource, title: string, description: string) {
    Column({ space: "1%" }) {
      Image(imageUrl)
        .width('80%')
        .height("80%")
        .objectFit(ImageFit.Cover)
        .borderRadius(10)

      Text(title)
        .fontSize("7%")
        .fontWeight(FontWeight.Bold)

      Text(description)
        .fontSize("2%")
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

}



