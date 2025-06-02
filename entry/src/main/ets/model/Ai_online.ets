import http from '@ohos.net.http';
  import { BusinessError } from '@ohos.base';
  import { JSON } from '@kit.ArkTS';
  import json from '@ohos.util.json';

  /**
   * Token使用情况统计接口
   */
  export interface TokenUsage {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  }

  /**
   * AI聊天响应数据接口
   */
  export interface ChatResponse {
    content: string;
    role: string;
    finish_reason?: string;
    usage?: TokenUsage;
  }

  /**
   * 聊天消息接口
   */
  export interface ChatMessage {
    role: string;
    content: string;
  }

  /**
   * AI请求数据接口
   */
  export interface AIRequestData {
    max_tokens: number;
    top_k: number;
    temperature: number;
    messages: ChatMessage[];
    model: string;
    stream: boolean;
  }

  /**
   * AI响应消息接口
   */
  export interface AIResponseMessage {
    role: string;
    content: string;
  }

  /**
   * AI响应选择接口
   */
  export interface AIResponseChoice {
    message: AIResponseMessage;
    index: number;
  }

  /**
   * AI完整响应接口
   */
  export interface AIResponse {
    code: number;
    message: string;
    sid: string;
    choices: AIResponseChoice[];
    usage: TokenUsage;
  }

  /**
   * SSE格式的增量消息接口
   */
  export interface SSEDelta {
    content?: string;
    role?: string;
  }

  /**
   * SSE格式的选择接口
   */
  export interface SSEChoice {
    delta: SSEDelta;
    index: number;
    finish_reason?: string;
  }

  /**
   * SSE格式的响应接口
   */
  export interface SSEResponse {
    choices: SSEChoice[];
    created?: number;
    id?: string;
    model?: string;
    object?: string;
  }

  /**
   * HTTP请求模块
   * 用于向AI服务器发送请求并处理响应
   */
  export function sendAIRequest(content: string, callback?: (response: ChatResponse) => void): void {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();

    // 用于订阅HTTP响应头，此接口会比request请求先返回
    httpRequest.on('headersReceive', (header) => {
      console.info('AI请求响应头: ' + JSON.stringify(header));
    });

    // 构建请求数据
    const requestData: AIRequestData = {
      max_tokens: 500,
      top_k: 2,
      temperature: 0.4,
      messages: [
        {
          role: "user",
          content: content
        } as ChatMessage
      ],
      model: "x1",
      stream: true
    };

    // 请求配置选项
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: {
        'Authorization': 'Bearer qzzrsAyfwqeWGoKaZzYL:oEciIgjmIFtMTqzpYGTz',
        'Content-Type': 'application/json'
      },
      extraData: JSON.stringify(requestData),
      expectDataType: http.HttpDataType.STRING,
      usingCache: false,
      connectTimeout: 60000,
      readTimeout: 60000
    };

    console.info('开始发送AI请求，内容: ' + content);

    httpRequest.request(
      "https://spark-api-open.xf-yun.com/v2/chat/completions",
      options,
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          // data.result为HTTP响应内容，进行解析
          console.info('AI响应结果:' + JSON.stringify(data.result));
          console.log('响应状态码: ' + data.responseCode);
          console.log('响应数据: ' + data.result.toString());

          // 处理响应数据
          let responseStr = (data.result).toString();
          console.log("AI响应字符串 = " + responseStr);

          // 处理流式响应数据
          processStreamResponse(responseStr, callback);

          // 打印响应头和其他信息
          console.info('响应头:' + JSON.stringify(data.header));
          console.info('cookies:' + JSON.stringify(data.cookies));

          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        } else {
          console.error('AI请求出错:' + JSON.stringify(err));
          // 取消订阅HTTP响应头事件
          httpRequest.off('headersReceive');
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        }
      }
    );
  }

  /**
   * 处理流式响应数据
   * @param responseStr - 响应字符串
   * @param callback - 回调函数
   */
  function processStreamResponse(responseStr: string, callback?: (response: ChatResponse) => void): void {
    try {
      // 按行分割数据
      const lines = responseStr.split('\n');
      let fullContent = '';

      lines.forEach((line, index) => {
        if (line.trim()) {
          console.info('响应行 ' + index + ': ' + line.trim());

          // 处理直接的JSON响应数据（非SSE格式）
          if (line.trim().startsWith('{')) {
            try {
              let jsonObj: AIResponse = JSON.parse(line.trim()) as AIResponse;
              console.info('解析的JSON数据: ' + JSON.stringify(jsonObj));

              // 按照参考代码的方式提取数据
              const aiResponse: AIResponse = jsonObj;
              console.info('响应代码: ' + aiResponse.code);
              console.info('响应消息: ' + aiResponse.message);
              console.info('会话ID: ' + aiResponse.sid);

              // 提取choices数组中的内容
              const choices: AIResponseChoice[] = aiResponse.choices;
              if (choices && Array.isArray(choices) && choices.length > 0) {
                const firstChoice: AIResponseChoice = choices[0];
                console.info('第一个选择: ' + JSON.stringify(firstChoice));

                const message: AIResponseMessage = firstChoice.message;
                if (message) {
                  const content: string = message.content;
                  if (content) {
                    fullContent = content;
                    console.log("提取到的内容: " + content);
                    console.log("内容角色: " + message.role);
                  }
                }
              }

              // 提取usage信息
              const usage: TokenUsage = aiResponse.usage;
              if (usage) {
                console.info('Token使用情况: ' + JSON.stringify(usage));
                console.log("prompt_tokens = " + usage.prompt_tokens);
                console.log("completion_tokens = " + usage.completion_tokens);
                console.log("total_tokens = " + usage.total_tokens);
              }

            } catch (parseError) {
              console.error('JSON解析失败: ' + line.trim());
              console.error('解析错误: ' + JSON.stringify(parseError));
            }
          }
          // 处理SSE格式的数据
          else if (line.startsWith('data: ')) {
            const jsonData = line.substring(6).trim();
            if (jsonData && jsonData !== '[DONE]') {
              try {
                let jsonObj = JSON.parse(jsonData);
                console.info('SSE解析的JSON数据: ' + JSON.stringify(jsonObj));

                // 提取SSE格式中的内容
                const choices:object = (jsonObj as object)?.["choices"];
                if (choices && Array.isArray(choices) && choices.length > 0) {
                  const choice:object = choices[0];
                  const delta:object = (choice as object)?.["delta"];
                  if (delta) {
                    const content:object = (delta as object)?.["content"];
                    if (content) {
                      fullContent += content;
                      console.log("收到内容片段: " + content);
                    }
                  }
                }
              } catch (parseError) {
                console.error('SSE JSON解析失败: ' + jsonData);
                console.error('解析错误: ' + JSON.stringify(parseError));
              }
            }
          }
        }
      });

      // 如果有回调函数，调用它
      if (callback && fullContent) {
        const response: ChatResponse = {
          content: fullContent,
          role: 'assistant'
        };
        callback(response);
      }

      console.log("最终提取的完整内容: " + fullContent);
    } catch (error) {
      console.error('处理流数据时出错: ' + JSON.stringify(error));
    }
  }



  /**
   * 使用示例类
   */
  export class AIRequestExample {
    /**
     * 示例1：发送自定义内容请求
     */
    public static sendCustomRequest(send_data:string): void {
      const customContent = "你好，请介绍一下人工智能的发展历程";
      sendAIRequest(customContent, (response: ChatResponse) => {
        console.log("收到AI回复: " + response.content);
      });
    }

    // /**
    //  * 示例2：不使用回调的简单请求
    //  */
    // public static simpleRequest(): void {
    //   sendAIRequest("请简单介绍一下TypeScript编程语言");
    // }
  }