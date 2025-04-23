import router from '@system.router';
import {TemperatureItem} from '../view/temperature'
import {car_page_item} from '../pages/Car_page'
import {LightItem} from '../view/seat'
import {LightControl} from '../view/light_control'
import {Nonepage} from '../view/NonePage'
import {carInformationItem} from  '../view/carInformation'
import {AutoSet} from '../view/AutoSet'
import {HuaweiMapDemo} from '../view/map'


@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  private arr: number[] = [1, 2, 3];
@State Navi_list_items:string[] = ["车辆信息",]
  @Builder
  PageMap(name: string) {
    if (name === "NavDestinationTitle1") {
      //ElectricItem({progress:100})
      carInformationItem()
    } else if (name === "NavDestinationTitle2") {
      LightControl()
    } else if (name === "NavDestinationTitle3") {
      LightItem({progress:100})
    }else if (name === "NavDestinationTitle4") {
      AutoSet()
    }else if (name === "NoneTitle"){
      Nonepage()
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
        .height(24)
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
          car_page_item();

          Divider().width(10).height("100%").margin({top:20,bottom:20}).vertical(true)

          Column() {
            Navigation(this.pageInfos) {
              List({ space: 12 }) {

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
            .title("车辆管理")
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

      }
      .tabBar(this.tabBarBuilder("设置", 2, $rawfile('up_control.png'), $rawfile('un_control.png')))
    }
    .onChange((index: number) => {
      // currentIndex控制TabContent显示页签
      this.currentIndex = index
      if (index === 0) {
        // 切换到车辆页时保持NonePage显示
        this.pageInfos.clear();
        this.pageInfos.pushPath({ name: "NoneTitle" });
        this.selectedButton = 'None';
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
