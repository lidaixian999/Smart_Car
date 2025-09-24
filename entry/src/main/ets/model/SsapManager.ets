/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { scan, ssap, constant } from '@kit.NearLinkKit';
import { promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

/**
 * 扫描结果回调接口
 */
export interface ScanResultCallback {
  onDeviceFound: (results: Array<scan.ScanResults>) => void;
  onConnectionStateChanged: (state: ssap.ConnectionChangeState) => void;
  onPropertyChanged: (property: ssap.Property) => void;
}

/**
 * 工具函数：字符串转ArrayBuffer
 */
function stringToArrayBuffer(str: string): ArrayBuffer {
  const encoder: util.TextEncoder = new util.TextEncoder();
  const uint8Array: Uint8Array = encoder.encodeInto(str);
  return uint8Array.buffer;
}

let onPropertyChange:(data: ssap.Property) => void = (data: ssap.Property) => {
  console.info('data:'+ JSON.stringify(data));
}

/**
 * SSAP管理器单例类
 * 负责设备扫描、连接、属性读写等功能
 */
export class SsapManager {
  private static instance: SsapManager;
  private client: ssap.Client | undefined;
  private services: Array<ssap.Service> = [];
  private scanResults: Array<scan.ScanResults> = [];
  private callbacks: Set<ScanResultCallback> = new Set();
  private isScanning: boolean = false;
  private isConnected: boolean = false;

  // 设备配置
  private readonly serviceUuid: string = '37BEA880-FC70-11EA-B720-000000002222';
  private readonly propertyUuid: string = '37BEA880-FC70-11EA-B720-000000002323';
  private readonly deviceAddress: string = 'EE:E8:35:DF:1C:9C';

  private property: ssap.Property;

  // 日志配置
  private readonly logTag: string = 'SsapManager';
  private readonly domainId: number = 0x0000;

  /**
   * 私有构造函数，确保单例模式
   */
  private constructor() {
    this.property = {
      serviceUuid: this.serviceUuid,
      propertyUuid: this.propertyUuid,
      value: stringToArrayBuffer("hello")
    };
    this.connectDevice_second()

  }


  /**
   * 获取单例实例
   */
  public static getInstance(): SsapManager {
    if (!SsapManager.instance) {
      SsapManager.instance = new SsapManager();
    }
    return SsapManager.instance;
  }


  /**
   * 字符串转ArrayBuffer（实例方法）
   */
  private stringToArrayBuffer(str: string): ArrayBuffer {
    return stringToArrayBuffer(str);
  }

  /**
   * 注册扫描结果回调
   */
  public registerCallback(callback: ScanResultCallback): void {
    this.callbacks.add(callback);
    hilog.info(this.domainId, this.logTag, `Callback registered, total: ${this.callbacks.size}`);
  }

  /**
   * 取消注册扫描结果回调
   */
  public unregisterCallback(callback: ScanResultCallback): void {
    const deleted = this.callbacks.delete(callback);
    if (deleted) {
      hilog.info(this.domainId, this.logTag, `Callback unregistered, total: ${this.callbacks.size}`);
    }
  }

  /**
   * 获取扫描结果
   */
  public getScanResults(): Array<scan.ScanResults> {
    return [...this.scanResults]; // 返回副本，避免外部修改
  }

  /**
   * 开始扫描设备
   */
  public startScan(scanFilter?: scan.ScanFilters): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this.isScanning) {
        const message = 'Already scanning';
        hilog.warn(this.domainId, this.logTag, message);
        reject(new Error(message));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Starting scan...');
      try {
        this.scanResults = []; // 清空扫描结果
        this.registerDeviceFoundCallback();

        const defaultFilter: scan.ScanFilters = scanFilter || {};
        const scanOptions: scan.ScanOptions = {
          scanMode: 2
        };

        scan.startScan([defaultFilter], scanOptions)
          .then(() => {
            this.isScanning = true;
            hilog.info(this.domainId, this.logTag, 'Scan started successfully');
            resolve();
          })
          .catch((err: BusinessError) => {
            hilog.error(this.domainId, this.logTag, `Start scan failed: ${err.message}`);
            reject(err);
          });
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(this.domainId, this.logTag,
          `Start scan error - Code: ${error.code}, Message: ${error.message}`);
        reject(error);
      }
    });
  }

  /**
   * 停止扫描设备
   */
  public stopScan(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.isScanning) {
        const message = 'Not scanning';
        hilog.warn(this.domainId, this.logTag, message);
        reject(new Error(message));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Stopping scan...');
      try {
        scan.stopScan()
          .then(() => {
            this.isScanning = false;
            hilog.info(this.domainId, this.logTag, 'Scan stopped successfully');
            this.unregisterDeviceFoundCallback();
            resolve();
          })
          .catch((err: BusinessError) => {
            hilog.error(this.domainId, this.logTag, `Stop scan failed: ${err.message}`);
            reject(err);
          });
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(this.domainId, this.logTag,
          `Stop scan error - Code: ${error.code}, Message: ${error.message}`);
        reject(error);
      }
    });
  }

  /**
   * 注册设备发现回调
   */
  private registerDeviceFoundCallback(): void {
    try {
      scan.on('deviceFound', (data: Array<scan.ScanResults>) => {
        hilog.info(this.domainId, this.logTag, `Device found: ${data.length} devices`);

        data.forEach((device, index) => {
          console.log(`发现设备 ${index + 1}: 名称 = ${device.deviceName || '未知设备'}, 地址 = ${device.address}`);
          hilog.info(this.domainId, this.logTag, `发现设备 ${index + 1}: 名称 = ${device.deviceName || '未知设备'}, 地址 = ${device.address}`);
        });
        // 添加新发现的设备到结果列表
        this.scanResults.push(...data);
        console.log(data.toString())
        // 通知所有注册的回调
        this.callbacks.forEach(callback => {
          try {
            callback.onDeviceFound(data);
          } catch (callbackErr) {
            hilog.error(this.domainId, this.logTag, `Callback error: ${callbackErr}`);
          }
        });
      });
      hilog.info(this.domainId, this.logTag, 'Device found callback registered');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(this.domainId, this.logTag,
        `Register callback error - Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 注销设备发现回调
   */
  private unregisterDeviceFoundCallback(): void {
    try {
      scan.off('deviceFound');
      hilog.info(this.domainId, this.logTag, 'Device found callback unregistered');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(this.domainId, this.logTag,
        `Unregister callback error - Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 初始化扫描功能
   */
  private async initializeScanning(): Promise<void> {
    try {
      // 注册设备发现回调
      this.registerDeviceFoundCallback();

      // 开始扫描
      await this.startScan();

      hilog.info(this.domainId, this.logTag, 'SsapManager initialized and scanning started');
    } catch (error) {
      hilog.error(this.domainId, this.logTag, `Failed to initialize scanning: ${error}`);
    }
  }

  // 连接设备
  public connectDevice(address: string): void {

    hilog.debug(this.domainId, this.logTag, 'connectDevice()');
    try {
      this.client = ssap.createClient(address);
      this.services = [];
      this.registerConnectionStateChangeCallback();
      this.registerPropertyChangeCallback();
      this.client.on('propertyChange', onPropertyChange);
      this.client.connect().then(() => {
        this.isConnected = true;
        hilog.info(this.domainId, this.logTag, 'connect success');

      });
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `errCode: ${(err as BusinessError).code}, errMessage: ${(err as BusinessError).message}`);
    }
  }

  /**
   * 连接设备
   */
  public connectDevice_second(): Promise<void> {
    return new Promise((resolve, reject) => {
      hilog.info(this.domainId, this.logTag, `Connecting to device: ${this.deviceAddress}`);

      try {
        this.client = ssap.createClient(this.deviceAddress);
        this.services = [];

        this.registerConnectionStateChangeCallback();
        this.registerPropertyChangeCallback();

        this.client.connect().then(() => {

          this.isConnected = true;
          hilog.info(this.domainId, this.logTag, 'Device connected successfully');

          setTimeout(() => {
            this.setPropertyNotification();
            resolve();
          } , 500);


        }).catch((err: BusinessError) => {

          const errorMsg = `Connect failed - Code: ${err.code}, Message: ${err.message}`;
          hilog.error(this.domainId, this.logTag, errorMsg);
          reject(new Error(errorMsg));

        });

      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Connect error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }


  /**
   * 获取服务列表
   */
  public getServices(): Promise<Array<ssap.Service>> {
    return new Promise((resolve, reject) => {
      if (!this.client) {
        const errorMsg = 'Client not initialized';
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Getting services...');
      try {
        this.client.getServices().then((result: Array<ssap.Service>) => {
          this.services = result;
          hilog.info(this.domainId, this.logTag, `Services retrieved: ${result.length} services`);
          resolve(result);
        }).catch((err: BusinessError) => {
          const errorMsg = `Get services failed - Code: ${err.code}, Message: ${err.message}`;
          hilog.error(this.domainId, this.logTag, errorMsg);
          reject(new Error(errorMsg));
        });
      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Get services error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }

  /**
   * 设置属性通知
   */
  public setPropertyNotification(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.client) {
        const errorMsg = 'Client not initialized';
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Setting property notification...');
      try {
        this.client.setPropertyNotification(this.property, true).then(() => {
          hilog.info(this.domainId, this.logTag, 'Property notification set successfully');
          resolve();
        }).catch((err: BusinessError) => {
          const errorMsg = `Set notification failed - Code: ${err.code}, Message: ${err.message}`;
          hilog.error(this.domainId, this.logTag, errorMsg);
          reject(new Error(errorMsg));
        });
      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Set notification error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }

  /**
   * 注册属性变化回调
   */
  private registerPropertyChangeCallback(): void {
    if (!this.client) {
      hilog.error(this.domainId, this.logTag, 'Client not initialized');
      return;
    }

    hilog.info(this.domainId, this.logTag, 'Registering property change callback...');
    try {
      this.client.on('propertyChange', (data: ssap.Property) => {
        hilog.info(this.domainId, this.logTag, `Property changed: ${JSON.stringify(data)}`);

        // 通知所有注册的回调
        this.callbacks.forEach(callback => {
          try {
            callback.onPropertyChanged(data);
          } catch (callbackErr) {
            hilog.error(this.domainId, this.logTag, `Property callback error: ${callbackErr}`);
          }
        });
      });
      hilog.info(this.domainId, this.logTag, 'Property change callback registered');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(this.domainId, this.logTag,
        `Register property callback error - Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 注册连接状态变化回调
   */
  private registerConnectionStateChangeCallback(): void {
    if (!this.client) {
      hilog.error(this.domainId, this.logTag, 'Client not initialized');
      return;
    }

    hilog.info(this.domainId, this.logTag, 'Registering connection state change callback...');
    try {
      this.client.on('connectionStateChange', (data: ssap.ConnectionChangeState) => {
        hilog.info(this.domainId, this.logTag, `Connection state changed: ${JSON.stringify(data)}`);

        if (data.state === constant.ConnectionState.STATE_CONNECTED) {
          this.isConnected = true;
          if (this.services.length === 0) {
            this.getServices();
          }
        } else if (data.state === constant.ConnectionState.STATE_DISCONNECTED) {
          this.isConnected = false;
        }

        // 通知所有注册的回调
        this.callbacks.forEach(callback => {
          try {
            callback.onConnectionStateChanged(data);
          } catch (callbackErr) {
            hilog.error(this.domainId, this.logTag, `Connection callback error: ${callbackErr}`);
          }
        });
      });
      hilog.info(this.domainId, this.logTag, 'Connection state change callback registered');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(this.domainId, this.logTag,
        `Register connection callback error - Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 读取属性
   */
  public readProperty(): Promise<ssap.Property> {
    return new Promise((resolve, reject) => {
      if (!this.client) {
        const errorMsg = 'Client not initialized';
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Reading property...');
      try {
        this.client.readProperty(this.property).then((result: ssap.Property) => {
          hilog.info(this.domainId, this.logTag, `Property read successfully: ${JSON.stringify(result)}`);
          promptAction.showToast({
            message: `read property`,
            duration: 2000
          });
          resolve(result);
        }).catch((err: BusinessError) => {
          const errorMsg = `Read property failed - Code: ${err.code}, Message: ${err.message}`;
          hilog.error(this.domainId, this.logTag, errorMsg);
          reject(new Error(errorMsg));
        });
      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Read property error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }

  /**
   * 写入属性
   */
  public writeProperty(data: string): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.client) {
        const errorMsg = 'Client not initialized';
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Writing property...');
      try {
        this.property.value = stringToArrayBuffer(data);
        this.client.requestMtuSize(128).then(() => {
          console.info('requestMtuSize success');
        });
        this.client.writeProperty(this.property, ssap.PropertyWriteType.WRITE_NO_RESPONSE).then(() => {
          hilog.info(this.domainId, this.logTag, 'Property written successfully');
          promptAction.showToast({
            message: `操作成功`,
            duration: 2000
          });
          resolve();
        }).catch((err: BusinessError) => {
          const errorMsg = `Write property failed - Code: ${err.code}, Message: ${err.message}`;
          hilog.error(this.domainId, this.logTag, errorMsg);
          reject(new Error(errorMsg));
        });
      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Write property error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }

  /**
   * 关闭客户端连接
   */
  public closeClient(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.client) {
        const errorMsg = 'Client not initialized';
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
        return;
      }

      hilog.info(this.domainId, this.logTag, 'Closing client...');
      try {
        this.client.close()
      } catch (err) {
        const error = err as BusinessError;
        const errorMsg = `Close client error - Code: ${error.code}, Message: ${error.message}`;
        hilog.error(this.domainId, this.logTag, errorMsg);
        reject(new Error(errorMsg));
      }
    });
  }

  /**
   * 获取连接状态
   */
  public getConnectionStatus(): boolean {
    return this.isConnected;
  }

  /**
   * 获取扫描状态
   */
  public getScanStatus(): boolean {
    return this.isScanning;
  }

  /**
   * 获取服务列表
   */
  public getServicesList(): Array<ssap.Service> {
    return [...this.services]; // 返回副本，避免外部修改
  }

  /**
   * 检查客户端是否已初始化
   */
  public isClientInitialized(): boolean {
    return this.client !== undefined;
  }
}
