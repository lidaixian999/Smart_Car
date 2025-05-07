
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { JSON } from '@kit.ArkTS';
import {LiveInfo} from '../view/Weather_Page'

// 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
// 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。

export function get_wethear( liveInfo: LiveInfo) {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用
  let httpRequest = http.createHttp();

  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });

  httpRequest.request(
    //city为城市代码
    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
    "https://restapi.amap.com/v3/weather/weatherInfo?city=440300&key=b6a024a9b9a310dc076db4f80acf2d8a",
    (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析
        console.info('Result:' + JSON.stringify(data.result));
        console.log(data.result.toString())
        let jsonStr =(data.result).toString()
        let jsonObj = JSON.parse(jsonStr);
        console.info('lives[0]: ' + JSON.stringify((jsonObj as object)?.["lives"]?.[0]));
        const liveData = JSON.stringify((jsonObj as object)?.["lives"]?.[0]);
        console.log("liveData = " + liveData)
        let obj = JSON.parse(liveData);
        if (liveData) {
          liveInfo.province = (obj as object)?.["province"];
          // console.log(" liveInfo.province = " + (obj as object)?.["province"])
          liveInfo.city = (obj as object)?.["city"];
          liveInfo.adcode = (obj as object)?.["adcode"];
          liveInfo.weather = (obj as object)?.["weather"];
          liveInfo.temperature = (obj as object)?.["temperature"];
          liveInfo.winddirection = (obj as object)?.["winddirection"];
          liveInfo.windpower = (obj as object)?.["windpower"];
          liveInfo.humidity = (obj as object)?.["humidity"];
          liveInfo.reporttime = (obj as object)?.["reporttime"];
          liveInfo.temperature_float = (obj as object)?.["temperature_float"];
          liveInfo.humidity_float = (obj as object)?.["humidity_float"];
          //todo 照着上两行，一样的方法去给liveIfon赋值
        }

        // let obj = data.result;
        // console.info((obj as object)?.["lives"]);
        // console.info('lives:' + JSON.stringify(data.result));
        // console.info('code:' + JSON.stringify(data.responseCode));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      } else {
        console.error('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      }
    }
  );

  return liveInfo
}
