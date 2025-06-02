export interface CommandAction {
  type: 'headlight' | 'seat_vent' | 'ambient' | 'seat_mode' | 'unknown';
  action: string;
  position: number;
  digit: string;
}

export class AICommandParser {
  private static instance: AICommandParser;

  static getInstance(): AICommandParser {
    if (!AICommandParser.instance) {
      AICommandParser.instance = new AICommandParser();
    }
    return AICommandParser.instance;
  }

  // 解析AI回复中的指令标识
  parseCommand(aiResponse: string): CommandAction | null {
    // 提取指令标识
    const commandMatches = aiResponse.match(/\[([A-Z_]+)\]/g);
    if (!commandMatches || commandMatches.length === 0) {
      return null;
    }

    // 处理第一个识别到的指令
    const firstCommand = commandMatches[0].replace(/[\[\]]/g, '');

    switch (firstCommand) {
      // 自动车前大灯控制（位置0）
      case 'HEADLIGHT_ON':
        return { type: 'headlight', action: 'on', position: 0, digit: '1' };
      case 'HEADLIGHT_OFF':
        return { type: 'headlight', action: 'off', position: 0, digit: '0' };

    // 座椅通风控制（位置1）手动强制打开风扇
      case 'SEAT_VENT_ON':

        return { type: 'seat_vent', action: 'on', position: 1, digit: '2' };
      case 'SEAT_VENT_OFF':
        return { type: 'seat_vent', action: 'off', position: 1, digit: '1' };

    // 氛围灯控制（位置2）
      case 'AMBIENT_OFF':
        AppStorage.setOrCreate('fenStatus',false)
        return { type: 'ambient', action: 'off', position: 2, digit: '0' };
      case 'AMBIENT_MIX':
        AppStorage.setOrCreate('fenStatus',true)
        return { type: 'ambient', action: 'mix', position: 2, digit: '4' };
      case 'AMBIENT_RED':
        return { type: 'ambient', action: 'red', position: 2, digit: '1' };
      case 'AMBIENT_GREEN':
        return { type: 'ambient', action: 'green', position: 2, digit: '3' };
      case 'AMBIENT_BLUE':
        return { type: 'ambient', action: 'blue', position: 2, digit: '2' };

    // 座椅模式控制（位置3）
      case 'SEAT_NORMAL':
        return { type: 'seat_mode', action: 'normal', position: 3, digit: '0' };
      case 'SEAT_REST':
        return { type: 'seat_mode', action: 'rest', position: 3, digit: '3' };
      case 'SEAT_FLAT':
        return { type: 'seat_mode', action: 'flat', position: 3, digit: '2' };

      default:
        return null;
    }
  }

  // 解析多个指令
  parseMultipleCommands(aiResponse: string): CommandAction[] {
    const commandMatches = aiResponse.match(/\[([A-Z_]+)\]/g);
    if (!commandMatches || commandMatches.length === 0) {
      return [];
    }

    const commands: CommandAction[] = [];
    for (const match of commandMatches) {
      const command = match.replace(/[\[\]]/g, '');
      const parsedCommand = this.parseCommand(`[${command}]`);
      if (parsedCommand) {
        commands.push(parsedCommand);
      }
    }
    return commands;
  }

  // 生成友好的确认消息
  generateConfirmMessage(command: CommandAction): string {
    switch (command.type) {
      case 'headlight':
        return command.action === 'on' ? '已开启车前大灯' : '已关闭车前大灯';
      case 'seat_vent':
        return command.action === 'on' ? '已开启座椅通风' : '已关闭座椅通风';
      case 'ambient':
        const ambientActions = {
          'off': '已关闭氛围灯',
          'mix': '已开启混合氛围灯',
          'red': '已设置红色氛围灯',
          'green': '已设置绿色氛围灯',
          'blue': '已设置蓝色氛围灯'
        };
        return ambientActions[command.action] || '氛围灯设置完成';
      case 'seat_mode':
        const seatActions = {
          'normal': '座椅已调整为正常模式',
          'rest': '座椅已调整为小憩模式',
          'flat': '座椅已调整为躺平模式'
        };
        return seatActions[command.action] || '座椅调整完成';
      default:
        return '指令执行完成';
    }
  }
}