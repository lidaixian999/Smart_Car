import router from '@system.router';
import {car_page_item} from '../pages/Car_page'
import {SeatItem} from '../view/seat'
import {LightControl} from '../view/light_control'
import {Nonepage} from '../view/NonePage'
import {carInformationItem} from  '../view/carInformation'
import {AutoSet} from '../view/AutoSet'
import {HuaweiMapDemo} from '../view/map'
import {Setting_Page} from '../pages/Setting_page'
import {WeatherPage} from '../view/Weather_Page'
import { SsapManager } from '../model/SsapManager';
import GlobalData from '../model/Tcp_data'
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

async function checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;


  // 获取应用程序的accessTokenID。
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
  }


  // 校验应用是否被授予权限。
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
  }


  return grantStatus;
}


async function checkPermissions(): Promise<void> {
  let grantStatus1: boolean = await checkPermissionGrant('ohos.permission.LOCATION') === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;// 获取精确定位权限状态。
  let grantStatus2: boolean = await checkPermissionGrant('ohos.permission.APPROXIMATELY_LOCATION') === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;// 获取模糊定位权限状态。
  // 精确定位权限只能跟模糊定位权限一起申请，或者已经有模糊定位权限才能申请精确定位权限。
  if (grantStatus2 && !grantStatus1) {
    // 申请精确定位权限。
  } else if (!grantStatus1 && !grantStatus2) {
    // 申请模糊定位权限与精确定位权限或单独申请模糊定位权限。
  } else {
    // 已经授权，可以继续访问目标操作。
  }
}


@Entry
@Component
struct Index {
  logTag: string = 'Index';
  domainId: number = 0x0000;

  //    atManager.requestPermissionsFromUser(context, ['ohos.permission.LOCATION']);
  //     atManager.requestPermissionsFromUser(context, ['ohos.permission.APPROXIMATELY_LOCATION']);

aboutToAppear(): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  try {
    let context = getContext(this);
    // ohos.permission.ACCESS_NEARLINK is needed in this example.
    // This HAP will ask user for permission when it's opened in the first time.
    atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_NEARLINK']);

  } catch (err) {
    hilog.error(this.domainId, this.logTag,
      `errCode: ${(err as BusinessError).code}, errMessage: ${(err as BusinessError).message}`);
  }
}


  private ssapManager = SsapManager.getInstance();
  private tcp_data = GlobalData.getInstance()
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
@State Navi_list_items:string[] = ["车辆信息",]
  @Builder
  PageMap(name: string) {
    if (name === "NavDestinationTitle1") {
      //ElectricItem({progress:100})
      carInformationItem()
    } else if (name === "NavDestinationTitle2") {
      LightControl()
    } else if (name === "NavDestinationTitle3") {
      SeatItem({progress:100})
    }else if (name === "NavDestinationTitle4") {
      AutoSet()
    }else if (name === "NavDestinationTitle5"){
      WeatherPage();
    }else if (name === "NoneTitle"){
      Nonepage();
    }
  }


  @State currentIndex: number = 0;
  //@State updata_time:string='已从车辆更新: 2025/4/10 下午5:07';
  @State progress:number = 100 ;
  // 新增选中状态记录
  @State selectedButton: string = '';
  //页签控制器
  //关联Tabs控制器与Tabs组件。开发者可以将定义的Tabs控制器作为Tabs组件的参数传入，这样就能通过该控制器来对Tabs进行控制。
  private tabsController: TabsController = new TabsController();

  @Builder
  //传入标题title,页签数据targetIndex,选中状态的图标selectIcon，未选中状态的图标unselectIcon
  tabBarBuilder(title: string, targetIndex: number, selectedIcon: Resource, unselectIcon: Resource) {
    Column() {
      //currentIndex为状态变量保证页签与图标实时刷新
      Image(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
        .width(24)
        .height(20)
      Text(title)//字体
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? '#0A59F7' : 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    //修改页签的方法
    .onClick(() => {
      //索引从0开始计算。这里是点击后控制器改变页签
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }


  build(){

    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Flex({direction:FlexDirection.Row}) {
          // Divider().width(10).height("100%").margin({top:20,bottom:20}).vertical(true)
          Column() {
            Navigation(this.pageInfos) {
              List({ space: 12 }) {
                car_page_item();
                  ListItem() {
                    Text("车辆信息")
                      .width("100%")
                      .height(72)
                      //.backgroundColor('#eca94e')
                      .backgroundColor(this.selectedButton === 'carInformation' ? '#eca94e' : '#FAF1E5')
                      .borderRadius(24)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.Center)
                  }.onClick(() => {
                    if(this.selectedButton === 'carInformation'){
                      this.selectedButton = 'None'
                      this.pageInfos.pop()
                      this.pageInfos.pushPath({name:"NoneTitle"})
                    }
                    else {
                      this.selectedButton = 'carInformation'
                      this.pageInfos.pop()
                      this.pageInfos.pushPath({ name: "NavDestinationTitle1" })
                    }
                  })
                ListItem() {
                  Text("灯光控制")
                    .width("100%")
                    .height(72)
                    .backgroundColor(this.selectedButton === 'light' ? '#eca94e' : '#FAF1E5')
                    .borderRadius(24)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }.onClick(() => {
                  if(this.selectedButton === 'light'){
                    this.selectedButton = 'None'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({name:"NoneTitle"})
                  }
                  else {
                    this.selectedButton = 'light'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({ name: "NavDestinationTitle2" })
                  }
                })

                ListItem() {
                  Text("座椅调节")
                    .width("100%")
                    .height(72)
                    .backgroundColor(this.selectedButton === 'chair' ? '#eca94e' : '#FAF1E5')
                    .borderRadius(24)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }.onClick(() => {
                  if(this.selectedButton === 'chair'){
                    this.selectedButton = 'None'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({name:"NoneTitle"})
                  }
                  else {
                    this.selectedButton = 'chair'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({ name: "NavDestinationTitle3" })
                  }
                })

                ListItem() {
                  Text("当前天气")
                    .width("100%")
                    .height(72)
                    .backgroundColor(this.selectedButton === 'weather' ? '#eca94e' : '#FAF1E5')
                    .borderRadius(24)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }.onClick(() => {
                  if(this.selectedButton === 'weather'){
                    this.selectedButton = 'None'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({name:"NoneTitle"})
                  }
                  else {
                    this.selectedButton = 'weather'
                    this.pageInfos.pop()
                    this.pageInfos.pushPath({ name: "NavDestinationTitle5" })
                  }
                })

                ListItem(){
                    Text("自动化设置")
                      .width("100%")
                      .height(72)
                      .backgroundColor(this.selectedButton === 'autoSet' ? '#eca94e' : '#FAF1E5')
                      .borderRadius(24)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.Center)

                  }.onClick(() => {
                    if(this.selectedButton === 'autoSet'){
                      this.selectedButton = 'None'
                      this.pageInfos.pop()
                      this.pageInfos.pushPath({name:"NoneTitle"})
                    }
                    else {
                      this.selectedButton = 'autoSet'
                      this.pageInfos.pop()
                      this.pageInfos.pushPath({ name: "NavDestinationTitle4" })
                    }
                  })


              }
              .width("90%")
              .margin({ top: 12 })
            }
            .title("管理")
            .mode(NavigationMode.Split)
            .navDestination(this.PageMap)
            .onAppear(() => {
              // 确保首次加载显示NonePage
              if (this.pageInfos.size() === 0) {
                  this.pageInfos.pushPath({ name: "NoneTitle" });
              }
            })
          }

        }

      }
      .onWillShow(()=>{
        console.log("try to onwillShow")
      })
      .tabBar(this.tabBarBuilder('车辆', 0, $rawfile('up_car.png'), $rawfile('un_car.png')))
      TabContent() {


        HuaweiMapDemo()

      }
      .tabBar(this.tabBarBuilder("地图", 1, $rawfile('up_map.png'), $rawfile('un_map.png')))

      TabContent() {

        Setting_Page()


      }
      .backgroundColor('#e2eeeeee')
      .tabBar(this.tabBarBuilder("设置", 2, $rawfile('up_control.png'), $rawfile('un_control.png')))
    }
    .onChange((index: number) => {
      // currentIndex控制TabContent显示页签
      this.currentIndex = index
      if (index === 0) {

      }
    })
    // 滑动改变页签，currentIndex改变触发图标刷新
    .scrollable(true)
    .vertical(false)
    .divider({
      strokeWidth: 0.5,
      color: '#0D182431'
    })


  }
}
