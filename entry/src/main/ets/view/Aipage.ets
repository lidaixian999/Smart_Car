import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ICapturerInterface } from '../model/ICapturerInterface';
import FileCapturer from '../model/FileCapturer';
import AudioCapturer from '../model/AudioCapturer';
import { promptAction } from '@kit.ArkUI';
import { sendAIRequest } from '../model/Ai_online'
import {AIRequestExample } from '../model/Ai_online'
import {ChatResponse} from '../model/Ai_online'
import { SmartCommandExecutor,ExecutionResult } from '../model/SmartCommandExecutor';
import GlobalData from '../model/Tcp_data';
import { SsapManager } from '../model/SsapManager';
import { AICommandParser, CommandAction } from '../model/AICommandParser';
const TAG: string = 'ChatPage';
let asrEngine: speechRecognizer.SpeechRecognitionEngine;

// 消息数据模型
interface ChatMessage {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: number;
}

// 语音识别状态枚举
enum VoiceRecognitionState {
  IDLE = 'idle',
  RECORDING = 'recording',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  ERROR = 'error'
}

@Component
export struct Ai_page {
  @State private messages: ChatMessage[] = [];
  @State private inputText: string = '';
  @State private isRecording: boolean = false;
  @State private isAiTyping: boolean = false;
  @State private showVoiceDialog: boolean = false;
  @State private voiceRecognitionState: VoiceRecognitionState = VoiceRecognitionState.IDLE;
  @State private recognizedText: string = '';
  @State private recordingDuration: number = 0;
  @State private waveAnimationScale: number[] = [1, 1, 1, 1, 1];
  @State private createCount: number = 0; // 创建引擎计数
  @State private sessionId: string = "123456"; // 语音识别 sessionId


  private tcp_data = GlobalData.getInstance()
  private ssapManager: SsapManager = SsapManager.getInstance();

  private listScroller: Scroller = new Scroller();
  private recordingTimer: number = -1;
  private waveAnimationTimer: number = -1;
  private mAudioCapturer: ICapturerInterface = new AudioCapturer();
  private smartCommandExecutor: SmartCommandExecutor = new SmartCommandExecutor(this.tcp_data, this.ssapManager);

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        this.buildHeader()

        // 对话消息区域
        this.buildMessageArea()

        // 底部输入区域
        this.buildInputArea()
      }
      // 设置键盘避让模式为上抬，同时处理系统安全区域
      .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 语音识别弹窗
      if (this.showVoiceDialog) {
        this.buildVoiceRecognitionDialog()

      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('AI助手')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1F000000', offsetY: 1 })
  }

  @Builder
  buildMessageArea() {
    List({ scroller: this.listScroller }) {
      ForEach(this.messages, (message: ChatMessage) => {
        ListItem() {
          this.buildMessageItem(message)
        }
        .width('100%')
        .margin({ top: 8, bottom: 8 })
      }, (message: ChatMessage) => message.id)

      // AI正在输入的提示
      if (this.isAiTyping) {
        ListItem() {
          this.buildTypingIndicator()
        }
        .width('100%')
        .margin({ top: 8, bottom: 8 })
      }
    }
    .height('100%')
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 70 })
    .scrollBar(BarState.Off)
  }

  @Builder
  buildMessageItem(message: ChatMessage) {
    Row() {
      if (message.isUser) {
        // 用户消息右对齐
        Blank()
        Column() {
          Text(message.content)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Start)
            .padding(12)
            .backgroundColor('#007AFF')
            .borderRadius(12)
            .maxLines(999)
            .wordBreak(WordBreak.BREAK_ALL)
        }
        .alignItems(HorizontalAlign.End)
        .constraintSize({ maxWidth: '70%' })
      } else {
        // AI消息左对齐
        Column() {
          Text(message.content)
            .fontSize(16)
            .fontColor('#333333')
            .textAlign(TextAlign.Start)
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .maxLines(999)
            .wordBreak(WordBreak.BREAK_ALL)
            .shadow({ radius: 1, color: '#1A000000', offsetY: 1 })
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ maxWidth: '70%' })

        Blank()
      }
    }
    .width('100%')
    .justifyContent(message.isUser ? FlexAlign.End : FlexAlign.Start)
  }

  @Builder
  buildTypingIndicator() {
    Row() {
      Column() {
        Row() {
          ForEach([1, 2, 3], (index: number) => {
            Circle({ width: 8, height: 8 })
              .fill('#CCCCCC')
              .margin({ left: index > 1 ? 4 : 0 })
              .animation({
                duration: 600,
                iterations: -1,
                delay: index * 200,
                curve: Curve.EaseInOut
              })
          })
        }
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 1, color: '#1A000000', offsetY: 1 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }

    .width('80%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildInputArea() {
    Column() {
      Divider()
        .color('#E5E5E5')
        .strokeWidth(0.5)

      Row() {
        // 文本输入框
        TextInput({ placeholder: '输入消息...', text: this.inputText })
          .layoutWeight(1)
          .height(40)
          .fontSize(16)
          .borderRadius(20)
          .backgroundColor('#F0F0F0')
          .padding({ left: 16, right: 16 })
          .border({ width: 0 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.sendTextMessage();
          })
            // 添加键盘避让相关配置
          .onFocus(() => {
            // 当输入框获得焦点时，自动滚动到底部
            setTimeout(() => {
              this.scrollToBottom();
            }, 300);
          })

        // 语音输入按钮
        Button() {
          Image($rawfile("media.ic_microphone.png"))
            .width(24)
            .height(24)
            .fillColor(this.isRecording ? '#FF3B30' : '#007AFF')
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(this.isRecording ? '#FFE5E5' : '#E3F2FF')
        .margin({ left: 8 })
        .onClick(async () => {
          if (!this.isRecording) {
            await this.startVoiceRecording();
          } else {
            await this.stopVoiceRecording();
          }
        })

        // 发送按钮
        Button() {
          Image($rawfile('send.png'))
            .width(24)
            .height(24)
            .fillColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(this.inputText.trim() ? '#ff97adcd' : '#CCCCCC')
        .margin({ left: 8 })
        .enabled(this.inputText.trim().length > 0)
        .onClick(() => {
          this.sendTextMessage();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    // 确保输入区域在键盘弹出时保持在可见区域
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: '-100%' })
  }

  @Builder
  buildVoiceRecognitionDialog() {
    Stack() {
      // 背景遮罩
      // Column()
      //   .width('100%')
      //   .height('100%')
      //   .backgroundColor('#80000000')
      //   .onClick(() => {
      //     // 点击背景关闭弹窗
      //     if (this.voiceRecognitionState !== VoiceRecognitionState.RECORDING) {
      //       this.closeVoiceDialog();
      //     }
      //   })

      // 主要弹窗内容 - 使用绝对定位
      Column() {
        // 顶部标题和状态
        this.buildDialogHeader()

        // 中间波形动画区域
        this.buildWaveAnimation()

        // 底部识别文本和操作按钮
        this.buildDialogFooter()
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#33000000', offsetY: 4 })
      .position({
        x: '5%',  // 居中定位 (100% - 90%) / 2 = 5%
        y: '5%'  // 距离顶部15%的位置，避免键盘区域
      })
      .animation({
        duration: 300,
        curve: Curve.EaseOut
      })
    }
    .margin({bottom:50})
    .width('80%')
    .height('80%')
  }
  @Builder
  buildDialogHeader() {
    Row() {
      Text(this.getVoiceStateTitle())
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')

      Blank()

      // 录音时长显示
      if (this.voiceRecognitionState === VoiceRecognitionState.RECORDING) {
        Text(this.formatDuration(this.recordingDuration))
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 16 })
  }

  @Builder
  buildWaveAnimation() {
    Column() {
      // 波形动画
      Row() {
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          Column()
            .width(4)
            .height(this.voiceRecognitionState === VoiceRecognitionState.RECORDING ?
              // 限制波动范围，使用正弦函数或限制最大值
              (20 + Math.min(Math.abs(this.waveAnimationScale[index]), 1) * 15) : 20)
            .backgroundColor(this.getWaveColor())
            .borderRadius(2)
            .margin({ left: index > 0 ? 6 : 0 })
            .animation({
              duration: 800,  // 固定持续时间，避免随机变化
              iterations: this.voiceRecognitionState === VoiceRecognitionState.RECORDING ? -1 : 1,
              curve: Curve.EaseInOut,
              playMode: PlayMode.Alternate  // 添加往返播放模式
            })
        }, (index: number) => index.toString())
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Bottom)
      .height(60)
      .margin({ bottom: 20 })
    }
  }

  // 建议添加一个控制波形数据的方法
  private updateWaveAnimation() {
    // 限制更新频率，比如每100ms更新一次
    if (this.voiceRecognitionState === VoiceRecognitionState.RECORDING) {
      // 使用正弦波或限制范围的随机值
      this.waveAnimationScale = this.waveAnimationScale.map((_, index) => {
        // 方案1：使用正弦波生成平滑的波形
        return Math.sin(Date.now() / 200 + index * 0.5) * 0.8;

        // 方案2：限制随机值范围
        // return (Math.random() - 0.5) * 2 * 0.8;
      });
    }
  }

  // 或者使用更稳定的静态波形
  private getStaticWaveHeight(index: number): number {
    if (this.voiceRecognitionState !== VoiceRecognitionState.RECORDING) {
      return 20;
    }

    // 预定义的波形高度，避免动态计算
    const staticHeights = [25, 35, 30, 40, 28];
    return staticHeights[index] || 20;
  }
  @Builder
  buildDialogFooter() {
    Column() {
      // 识别结果文本
      if (this.recognizedText) {
        Text(this.recognizedText)
          .fontSize(16)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .margin({ left: 20, right: 20, bottom: 16 })
      }

      // 状态提示文本
      Text(this.getVoiceStateHint())
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      // 操作按钮
      Row() {
        if (this.voiceRecognitionState === VoiceRecognitionState.RECORDING) {
          // 录音中显示取消和完成按钮
          Button('取消')
            .fontSize(16)
            .fontColor('#FF3B30')
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#FF3B30' })
            .borderRadius(24)
            .width(80)
            .height(48)
            .onClick(async () => {
              await this.cancelVoiceRecording();
            })

          Blank()

          Button('完成')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#007AFF')
            .borderRadius(24)
            .width(80)
            .height(48)
            .onClick(async () => {
              await this.stopVoiceRecording();
            })
        } else if (this.voiceRecognitionState === VoiceRecognitionState.COMPLETED && this.recognizedText) {
          // 识别完成显示发送和重录按钮
          Button('重录')
            .fontSize(16)
            .fontColor('#007AFF')
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#007AFF' })
            .borderRadius(24)
            .width(80)
            .height(48)
            .onClick(async () => {
              await this.restartVoiceRecording();
            })
          Blank()

          // 新增转文字按钮
          Button() {
            Row() {
              Image($rawfile("media.text.png")) // 请替换为您的转文字图标资源
                .width(20)
                .height(20)
                .fillColor('#007AFF')
              Text('转文字')
                .fontSize(14)
                .fontColor('#007AFF')
                .margin({ left: 4 })
            }
          }
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#007AFF' })
          .borderRadius(24)
          .padding({ left: 12, right: 12 })
          .height(48)
          .onClick(() => {
            // 将识别的文字设置到输入框
            this.inputText = this.recognizedText;
            // 关闭语音识别弹窗
            this.closeVoiceDialog();
          })

          Blank()

          Button('发送')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#007AFF')
            .borderRadius(24)
            .width(80)
            .height(48)
            .onClick(() => {
              this.sendRecognizedText();
            })
        } else {
          // 其他状态显示关闭按钮
          Button('关闭')
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .borderRadius(24)
            .width(80)
            .height(48)
            .onClick(() => {
              this.closeVoiceDialog();
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
  }

  // ==================== 语音识别相关方法 ====================

  // Create an engine, which is returned in callback mode.
  private createAsrEngine(): Promise<void> {
    return new Promise((resolve, reject) => {
      // 设置引擎参数
      let extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" };
      let initParamsInfo: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1, // 离线模式
        extraParams: extraParam
      };

      try {
        speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
          if (!err) {
            console.info(TAG, 'createEngine is success');
            asrEngine = speechRecognitionEngine;
            resolve(); // 成功后 resolve
          } else {
            console.error("errCode: " + err.code + " errMessage: " + JSON.stringify(err.message));
            reject(err); // 失败时 reject
          }
        });
      } catch (error) {
        let businessError = error as BusinessError;
        console.error(`createEngine failed, error code: ${businessError.code}, message: ${businessError.message}.`);
        reject(businessError); // 异常时 reject
      }
    });
  }

  // Setting callbacks
  private setAsrListener() {
    // Creating a Callback Object
    let setListener: speechRecognizer.RecognitionListener = {
      // Callback for successful recognition start
      onStart: (sessionId: string, eventMessage: string) => {
        console.info(TAG, "ASR onStart sessionId: " + sessionId + " eventMessage: " + eventMessage);
        this.voiceRecognitionState = VoiceRecognitionState.RECORDING;
        this.recognizedText = '';
      },
      // Event callback
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(TAG, "ASR onEvent sessionId: " + sessionId + " eventCode: " + eventCode + " eventMessage: " + eventMessage);
      },
      // Identification result callback, including intermediate results and final results.
      onResult: (sessionId: string, res: speechRecognizer.SpeechRecognitionResult) => {
        let isFinal: boolean = res.isFinal;
        let isLast: boolean = res.isLast;
        let result: string = res.result;

        console.info('ASR onResult: sessionId:' + sessionId + ' isFinal:' + isFinal + ' isLast:' + isLast + ' result:' + result);

        // 更新识别结果
        this.recognizedText = result;

        // 如果是最终结果，更新状态
        if (isFinal || isLast) {
          this.voiceRecognitionState = VoiceRecognitionState.COMPLETED;
          this.stopWaveAnimation();
        }
      },
      // Recognition completion callback
      onComplete: (sessionId: string, eventMessage: string) => {
        console.info(TAG, "ASR onComplete sessionId: " + sessionId + " eventMessage: " + eventMessage);
        this.voiceRecognitionState = VoiceRecognitionState.COMPLETED;
      },
      // Error callback. The error code is returned by this method.
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        console.error(TAG, "ASR onError sessionId: " + sessionId + " errorCode: " + errorCode + " errorMessage: " + errorMessage);
        this.voiceRecognitionState = VoiceRecognitionState.ERROR;
        this.stopWaveAnimation();

        promptAction.showToast({
          message: '语音识别失败，请重试',
          duration: 2000
        });
      }
    }
    // Invoke the callback method.
    asrEngine.setListener(setListener);
  }

  // 开始语音录制
  private async startVoiceRecording() {
    try {
      // 先确保引擎已创建
      if (!asrEngine) {
        this.createCount++;
        console.info(`CreateAsrEngine：createCount:${this.createCount}`);
        await this.createAsrEngine();
      }

      this.isRecording = true;
      this.showVoiceDialog = true;
      this.voiceRecognitionState = VoiceRecognitionState.RECORDING;
      this.recordingDuration = 0;
      this.recognizedText = '';

      console.info(TAG, '开始语音录制');

      // 设置监听器
      this.setAsrListener();

      // 设置识别参数
      let audioParam: speechRecognizer.AudioInfo = {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      };
      let extraParam: Record<string, Object> = {
        "recognitionMode": 0,
        "vadBegin": 2000,
        "vadEnd": 3000,
        "maxAudioDuration": 20000,
      };

      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: this.sessionId,
        audioInfo: audioParam,
        extraParams: extraParam
      };

      // 开始识别
      asrEngine.startListening(recognizerParams);

      // 开始录音计时
      this.recordingTimer = setInterval(() => {
        this.recordingDuration++;
      }, 1000);

      // 开始波形动画
      this.startWaveAnimation();

      // 初始化并开始音频采集
      this.mAudioCapturer.init((dataBuffer: ArrayBuffer) => {
        console.info(TAG, 'start write audio data');
        let uint8Array: Uint8Array = new Uint8Array(dataBuffer);
        // 写入音频流到语音识别引擎
        asrEngine.writeAudio(this.sessionId, uint8Array);
      });

      promptAction.showToast({
        message: '开始录音',
        duration: 1000
      });

    } catch (error) {
      console.error(TAG, '开始录音失败:', error);
      this.voiceRecognitionState = VoiceRecognitionState.ERROR;
      this.isRecording = false;

      promptAction.showToast({
        message: '录音启动失败',
        duration: 2000
      });
    }
  }

  // 停止语音录制
  private async stopVoiceRecording() {
    try {
      console.info(TAG, '停止语音录制');

      this.isRecording = false;
      this.voiceRecognitionState = VoiceRecognitionState.PROCESSING;

      // 停止录音计时
      if (this.recordingTimer !== -1) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = -1;
      }

      // 停止波形动画
      this.stopWaveAnimation();

      // 停止音频采集
      this.mAudioCapturer.stop();

      // 停止语音识别
      if (asrEngine) {
        asrEngine.finish(this.sessionId);
      }

      promptAction.showToast({
        message: '录音结束，正在识别...',
        duration: 1000
      });

    } catch (error) {
      console.error(TAG, '停止录音失败:', error);
      this.voiceRecognitionState = VoiceRecognitionState.ERROR;

      promptAction.showToast({
        message: '停止录音失败',
        duration: 2000
      });
    }
  }

  // 取消语音录制
  private async cancelVoiceRecording() {
    try {
      console.info(TAG, '取消语音录制');

      this.isRecording = false;
      this.voiceRecognitionState = VoiceRecognitionState.IDLE;
      this.recognizedText = '';

      // 停止录音计时
      if (this.recordingTimer !== -1) {
        clearInterval(this.recordingTimer);
        this.recordingTimer = -1;
      }

      // 停止波形动画
      this.stopWaveAnimation();

      // 停止音频采集
      this.mAudioCapturer.stop();

      // 取消语音识别
      if (asrEngine) {
        asrEngine.cancel(this.sessionId);
      }

      // 关闭弹窗
      this.closeVoiceDialog();

      promptAction.showToast({
        message: '已取消录音',
        duration: 1000
      });

    } catch (error) {
      console.error(TAG, '取消录音失败:', error);
    }
  }

  // 重新开始语音录制
  private async restartVoiceRecording() {
    this.recognizedText = '';
    this.voiceRecognitionState = VoiceRecognitionState.IDLE;
    await this.startVoiceRecording();
  }

  // 发送识别的文本
  private sendRecognizedText() {
    if (this.recognizedText.trim()) {
      this.addMessage(this.recognizedText.trim(), true);
      this.sendAIMessage(this.recognizedText.trim());
      this.closeVoiceDialog();
    }
  }

  // 关闭语音识别弹窗
  private closeVoiceDialog() {
    this.showVoiceDialog = false;
    this.voiceRecognitionState = VoiceRecognitionState.IDLE;
    this.recognizedText = '';
    this.recordingDuration = 0;
  }

  // 开始波形动画
  private startWaveAnimation() {
    this.waveAnimationTimer = setInterval(() => {
      this.updateWaveAnimation();
    }, 100);
  }

  // 停止波形动画
  private stopWaveAnimation() {
    if (this.waveAnimationTimer !== -1) {
      clearInterval(this.waveAnimationTimer);
      this.waveAnimationTimer = -1;
    }
    this.waveAnimationScale = [1, 1, 1, 1, 1];
  }

  // 获取语音状态标题
  private getVoiceStateTitle(): string {
    switch (this.voiceRecognitionState) {
      case VoiceRecognitionState.RECORDING:
        return '正在录音...';
      case VoiceRecognitionState.PROCESSING:
        return '正在识别...';
      case VoiceRecognitionState.COMPLETED:
        return '识别完成';
      case VoiceRecognitionState.ERROR:
        return '识别失败';
      default:
        return '语音输入';
    }
  }

  // 获取语音状态提示
  private getVoiceStateHint(): string {
    switch (this.voiceRecognitionState) {
      case VoiceRecognitionState.RECORDING:
        return '请说话，点击完成结束录音';
      case VoiceRecognitionState.PROCESSING:
        return '正在处理语音，请稍候...';
      case VoiceRecognitionState.COMPLETED:
        return '识别完成，请选择操作';
      case VoiceRecognitionState.ERROR:
        return '识别失败，请重试';
      default:
        return '点击开始录音';
    }
  }

  // 获取波形颜色
  private getWaveColor(): string {
    switch (this.voiceRecognitionState) {
      case VoiceRecognitionState.RECORDING:
        return '#007AFF';
      case VoiceRecognitionState.PROCESSING:
        return '#FF9500';
      case VoiceRecognitionState.ERROR:
        return '#FF3B30';
      default:
        return '#CCCCCC';
    }
  }

  // 格式化录音时长
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // ==================== 消息处理相关方法 ====================

  // 发送文本消息
  private sendTextMessage() {
    if (this.inputText.trim()) {
      const message = this.inputText.trim();
      this.addMessage(message, true);
      this.sendAIMessage(message);
      this.inputText = '';
    }
  }

  // 添加消息到列表
  private addMessage(content: string, isUser: boolean) {
    const message: ChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
      content: content,
      isUser: isUser,
      timestamp: Date.now()
    };
    this.messages.push(message);
    this.scrollToBottom();
  }

  // 发送AI请求
  private async sendAIMessage(content: string) {
    this.isAiTyping = true;
    this.scrollToBottom();

    try {
      const response = await new Promise<ChatResponse>((resolve, reject) => {
        sendAIRequest(content, (response: ChatResponse) => {
          resolve(response);
        });
      });

      this.isAiTyping = false;
      this.addMessage(response.content, false);

      // 解析并执行AI回复中的指令
      const executionResult: ExecutionResult = await this.smartCommandExecutor.executeFromAIResponse(response.content);

      if (executionResult.executed && executionResult.confirmMessage) {
        // 如果执行了指令，添加确认消息
        setTimeout(() => {
          this.addMessage(executionResult.confirmMessage!, false);
        }, 500);
      }

    } catch (error) {
      this.isAiTyping = false;
      console.error('AI请求失败:', error);
      this.addMessage('抱歉，AI服务暂时不可用，请稍后重试。', false);
    }
  }

  // 滚动到底部
  private scrollToBottom() {
    setTimeout(() => {
      this.listScroller.scrollToIndex(this.messages.length);
    }, 100);
  }
}