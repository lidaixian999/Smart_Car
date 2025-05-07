import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

class SocketInfo {
  message: ArrayBuffer = new ArrayBuffer(1);
  remoteInfo: socket.SocketRemoteInfo = {} as socket.SocketRemoteInfo;
}

class TCPSocketServerSingleton {

    //
    //  bindAddr: socket.NetAddress = {
    //   address:  "192.168.18.1",
    //   port: 4120
    // };// 测试地址


  bindAddr: socket.NetAddress = {
      address:  "192.168.137.22",
      port: 5678
    };


      tcp_connect_options: socket.TCPConnectOptions = {
      address: this.bindAddr,
      timeout: 2000
    };
  private static instance: TCPSocketServerSingleton;
  private tcp: socket.TCPSocket;
  private tcp_send_Options: socket.TCPSendOptions = {
    data: 'Hello, server!'
  };

  private constructor() {
    this.tcp = socket.constructTCPSocketInstance();
    this.setupEventListeners();
    this.connect();
  }

  public static getInstance(): TCPSocketServerSingleton {
    if (!TCPSocketServerSingleton.instance) {
      TCPSocketServerSingleton.instance = new TCPSocketServerSingleton();
    }
    return TCPSocketServerSingleton.instance;
  }

  private setupEventListeners() {
    this.tcp.on('message', (value: SocketInfo) => {
      console.log("on message");
      let buffer = value.message;
      let dataView = new DataView(buffer);
      let str = "";
      for (let i = 0; i < dataView.byteLength; ++i) {
        str += String.fromCharCode(dataView.getUint8(i));
      }
      console.log("on connect received:" + str);
    });

    this.tcp.on('connect', () => {
      console.log("on connect");
    });

    this.tcp.on('close', () => {
      console.log("on close");
    });
  }

  private connect() {
    this.tcp.connect(this.tcp_connect_options).catch((error:BusinessError) => {
      console.error('Connection error:', error);
    });
  }

  Send_data(message: string) {
    this.tcp_send_Options.data = message;
    this.tcp.connect(this.tcp_connect_options)
    console.log("Send "+ message)
    this.tcp.send(this.tcp_send_Options).catch((error:BusinessError) => {
      console.error('Error sending data:', error);
    });
  }
}

export default TCPSocketServerSingleton;
