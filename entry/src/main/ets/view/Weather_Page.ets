import {get_wethear} from '../model/Weather'

// 定义 LiveInfo 接口
export  interface LiveInfo {
  province: string;
  city: string;
  adcode: string;
  weather: string;
  temperature: string;
  winddirection: string;
  windpower: string;
  humidity: string;
  reporttime: string;
  temperature_float: string;
  humidity_float: string;
}


@Preview
@Component
export  struct WeatherPage {

  @Builder
  buildTitle(title: string){
    Text(title)
      .fontSize(40)
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 10,top: 10})
      .width('100%')
      .textAlign(TextAlign.Center)
  }

  aboutToAppear(): void {
    this.liveInfo = get_wethear(this.liveInfo);
  }
  // 模拟的天气数据
  @State liveInfo: LiveInfo = {
    province: '广东省',
    city: '深圳市',
    adcode: '440300',
    weather: '晴',
    temperature: '28',
    winddirection: '南风',
    windpower: '2级',
    humidity: '60%',
    reporttime: '2025-04-24 12:00:00',
    temperature_float: '28.5',
    humidity_float: '60.5'
  };

  build() {
    NavDestination() {
      Scroll(){
        Column(){
          Progress({
            value: 100,
            total: 100,
            style: ProgressStyle.Linear
          })
            .color("#ff1f1e1e")
            .width('90%')
            .height(10)
            .margin({ top: 10, bottom: 20 })

          Column({}) {
            Text(`数据更新时间: ${this.liveInfo.reporttime}`)
              .fontSize(20)
              .opacity(0.7)
              .margin({ bottom: 20 })
          }
          .width('100%')


          Column(){
            Row({space:20}){
              Image($rawfile("Weather.png"))
                .height(64)
                .width(64)

              Text(`温度: ${this.liveInfo.temperature}°C`)
                .fontSize(32)
                .fontWeight(52)
            }
            .margin({left:20,bottom:8})
            .width("90%")

            Row({ space: 20 }){
              Text(`${this.liveInfo.province}${this.liveInfo.city}`)
                .fontSize(24)
                .fontColor(Color.Gray)
            }
            .margin({left:20})
            .width("90%")
          }.width("100%")

          Divider()
            .margin({top:8,bottom:8})
            .width("80%")
            .color('#ff989898')


          Column(){
            Row({space:10}){
              Image($rawfile("Wind.png"))
                .width(32)
                .height(32)
              Text(`风向: ${this.liveInfo.winddirection}${this.liveInfo.windpower+"级"}`)
                .fontSize(32)
            }.width("90%")
            .margin({left:20})

            Divider()
              .margin({top:8,bottom:8})
              .width("80%")
              .color('#ff989898')

            Row({space:10}){
              Image($rawfile("Wet.png"))
                .width(32)
                .height(32)
              Text(`湿度: ${this.liveInfo.humidity}`)
                .fontSize(32)
            }.width("90%")
            .margin({left:20})

            Divider()
              .margin({top:8,bottom:8})
              .width("80%")
              .color('#ff989898')


            Row({space:10}){
              Image($rawfile("Weather_2.png"))
                .width(32)
                .height(32)



              Text(`天气状况: ${this.liveInfo.weather}`)
                .fontSize(32)
            }.width("90%")
            .margin({left:20})

            Divider()
              .margin({top:8,bottom:8})
              .width("80%")
              .color('#ff989898')
          }
        }
      }


    }
    .title(this.buildTitle('当前天气'))
  }
}

