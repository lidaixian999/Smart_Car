import { AICommandParser, CommandAction } from './AICommandParser';
import GlobalData from './Tcp_data'
import { SsapManager } from './SsapManager';

export interface ExecutionResult {
  executed: boolean;
  confirmMessage?: string;
}

/**
 * 智能指令执行器
 * 负责执行AI解析出的指令
 */
export class SmartCommandExecutor {
  private tcpData: GlobalData;
  private ssapManager: SsapManager;
  private aiCommandParser: AICommandParser;

  constructor(tcpData: GlobalData, ssapManager: SsapManager) {
    this.tcpData = tcpData;
    this.ssapManager = ssapManager;
    this.aiCommandParser = AICommandParser.getInstance();
  }

  /**
   * 从AI回复中执行指令
   */
  async executeFromAIResponse(aiResponse: string): Promise<ExecutionResult> {
    try {
      // 解析AI回复中的指令
      const commands = this.aiCommandParser.parseMultipleCommands(aiResponse);

      if (commands.length === 0) {
        return { executed: false }; // 没有指令需要执行
      }

      // 执行所有指令
      const executionResults: string[] = [];
      for (const command of commands) {
        const success = await this.executeCommand(command);
        if (success) {
          const confirmMsg = this.aiCommandParser.generateConfirmMessage(command);
          executionResults.push(confirmMsg);
        }
      }

      // 生成综合确认消息
      const confirmMessage = executionResults.length > 0 
        ? executionResults.join('，') 
        : '部分指令执行失败';

      console.log(`SmartCommandExecutor: 执行了${executionResults.length}/${commands.length}个指令: ${confirmMessage}`);

      return {
        executed: executionResults.length > 0,
        confirmMessage: confirmMessage
      };
    } catch (error) {
      console.error('SmartCommandExecutor: 执行指令时出错:', error);
      return {
        executed: false,
        confirmMessage: '指令执行失败，请稍后重试'
      };
    }
  }

  /**
   * 执行AI回复中的指令（保留原方法，保持向后兼容）
   */
  async executeAICommands(aiResponse: string): Promise<string> {
    try {
      const result = await this.executeFromAIResponse(aiResponse);
      return result.confirmMessage || '';
    } catch (error) {
      console.error('SmartCommandExecutor: 执行指令时出错:', error);
      return '指令执行失败，请稍后重试';
    }
  }

  /**
   * 执行单个指令
   * @param command 要执行的指令
   * @returns 执行是否成功
   */
  private async executeCommand(command: CommandAction): Promise<boolean> {
    try {
      // 验证指令参数
      if (command.position === undefined || command.digit === undefined) {
        console.error(`SmartCommandExecutor: 指令参数无效 ${command.type}-${command.action}`);
        return false;
      }

      // 验证位置范围
      if (command.position < 0 || command.position >= 4) {
        console.error(`SmartCommandExecutor: 指令位置超出范围 ${command.position}`);
        return false;
      }

      // 修改tcp_data中的对应位置
      this.tcpData.modifyDigit(command.position, command.digit.toString());

      // 通过ssapManager发送指令
      await this.ssapManager.writeProperty(this.tcpData.fourDigitString);

      console.log(`SmartCommandExecutor: 执行指令成功 ${command.type}-${command.action}, 位置${command.position}, 值${command.digit}`);
      console.log(`SmartCommandExecutor: 发送数据: ${this.tcpData.fourDigitString}`);
      
      return true;
    } catch (error) {
      console.error(`SmartCommandExecutor: 执行指令失败 ${command.type}-${command.action}:`, error);
      return false;
    }
  }

  /**
   * 获取当前系统状态
   */
  getCurrentStatus(): string {
    return `当前系统状态: ${this.tcpData.fourDigitString}`;
  }

  /**
   * 重置所有控制状态
   */
  async resetAllControls(): Promise<boolean> {
    try {
      // 重置为默认状态 "0000"
      this.tcpData.fourDigitString = "0000";
      await this.ssapManager.writeProperty(this.tcpData.fourDigitString);
      console.log('SmartCommandExecutor: 已重置所有控制状态');
      return true;
    } catch (error) {
      console.error('SmartCommandExecutor: 重置控制状态失败:', error);
      return false;
    }
  }

  /**
   * 批量执行指令
   * @param commands 指令数组
   * @returns 执行结果
   */
  async executeBatchCommands(commands: CommandAction[]): Promise<ExecutionResult> {
    try {
      if (commands.length === 0) {
        return { executed: false };
      }

      const executionResults: string[] = [];
      for (const command of commands) {
        const success = await this.executeCommand(command);
        if (success) {
          const confirmMsg = this.aiCommandParser.generateConfirmMessage(command);
          executionResults.push(confirmMsg);
        }
      }

      const confirmMessage = executionResults.length > 0 
        ? executionResults.join('，') 
        : '批量指令执行失败';

      return {
        executed: executionResults.length > 0,
        confirmMessage: confirmMessage
      };
    } catch (error) {
      console.error('SmartCommandExecutor: 批量执行指令时出错:', error);
      return {
        executed: false,
        confirmMessage: '批量指令执行失败，请稍后重试'
      };
    }
  }

  /**
   * 检查系统连接状态
   */
  isSystemReady(): boolean {
    return this.ssapManager !== undefined && this.tcpData !== undefined;
  }
}