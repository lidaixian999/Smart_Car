import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit'
// 需要引入@kit.LocationKit模块
import { geoLocationManager } from '@kit.LocationKit';

// 定义位置坐标接口
interface LocationCoordinate {
  latitude: number;
  longitude: number;
}

@Component
export struct HuaweiMapDemo {
  private TAG = "HuaweiMapDemo";
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.9,
          longitude: 116.4
        },

        zoom: 10
      },
      myLocationControlsEnabled: true
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info(this.TAG, `on-mapLoad`);
          // 地图加载完成后获取当前位置并设置为地图中心
          this.getCurrentLocation();
        }
        this.mapEventManager.on("mapLoad", callback);

        // 启用我的位置功能
        this.mapController.setMyLocationEnabled(true);
        this.mapController.setMyLocationControlsEnabled(true);
      }
    };
  }

  // 获取当前位置并设置为地图中心
  getCurrentLocation(): void {
    try {
      // 创建位置请求参数 - 使用正确的SingleLocationRequest类型
      let request: geoLocationManager.SingleLocationRequest = {
        locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_ACCURACY, // 高精度定位
        locatingTimeoutMs: 10000 // 超时时间10秒
      };

      // 获取当前位置
      geoLocationManager.getCurrentLocation(request)
        .then((location: geoLocationManager.Location) => {
          console.info(this.TAG, `获取位置成功: ${JSON.stringify(location)}`);

          // 如果地图控制器存在，则将地图中心设置为当前位置
          if (this.mapController) {
            let currentLocation: LocationCoordinate = {
              latitude: location.latitude,
              longitude: location.longitude
            };

            // 设置地图中心为当前位置
            this.mapController.moveCamera({
              target: currentLocation,
              zoom: 15 // 设置更高的缩放级别以便更清晰地查看当前位置
            });
          }
        })
    } catch (error) {
      console.error(this.TAG, `获取位置异常: ${error}`);
    }
  }

  // 页面每次显示时触发一次，包括路由过程、应用进入前台等场景，仅@Entry装饰的自定义组件生效
  onPageShow(): void {
    // 将地图切换到前台
    if (this.mapController) {
      this.mapController.show();
    }
  }

  // 页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景，仅@Entry装饰的自定义组件生效
  onPageHide(): void {
    // 将地图切换到后台
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    Stack() {
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback }).width('100%').height('100%');
    }.height('100%')
  }
};