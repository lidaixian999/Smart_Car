# FinalCar 智能车载系统

## 项目概述

FinalCar 是一个基于 HarmonyOS 开发的智能车载控制系统，集成了语音识别、AI 智能对话、车辆控制、天气查询等多种功能。该项目采用 ArkTS 语言开发，提供了完整的车载智能交互体验。
演示视频:https://pan.baidu.com/share/init?surl=qb8LKQoRpX77C627eS1XPw&pwd=jgsg
## 技术栈

- **开发语言**: ArkTS (TypeScript)
- **开发框架**: HarmonyOS SDK
- **UI框架**: ArkUI
- **语音识别**: HarmonyOS 语音识别服务
- **网络通信**: HTTP/TCP 协议
- **近场通信**: NearLink Kit
- **权限管理**: AbilityKit

## 项目架构

### 目录结构

```
finalCar/
├── entry/src/main/ets/
│   ├── entryability/           # 应用入口能力
│   │   └── EntryAbility.ets    # 主入口类
│   ├── pages/                  # 页面组件
│   │   ├── Index.ets          # 主页面
│   │   ├── Car_page.ets       # 车辆状态页面
│   │   ├── Aipage.ets         # AI对话页面
│   │   ├── Setting_page.ets   # 设置页面
│   │   └── map.ets           # 地图页面
│   ├── view/                   # 视图组件
│   │   ├── AutoSet.ets        # 自动设置组件
│   │   ├── NonePage.ets       # 空页面组件
│   │   ├── Weather_Page.ets   # 天气页面组件
│   │   ├── carInformation.ets # 车辆信息组件
│   │   ├── light_control.ets  # 灯光控制组件
│   │   └── seat.ets          # 座椅控制组件
│   ├── model/                  # 数据模型和业务逻辑
│   │   ├── AICommandParser.ts # AI指令解析器
│   │   ├── Ai_online.ets      # AI在线服务
│   │   ├── AsrConstants.ts    # 语音识别常量
│   │   ├── AudioCapturer.ts   # 音频采集器
│   │   ├── FileCapturer.ts    # 文件采集器
│   │   ├── ICapturerInterface.ts # 采集器接口
│   │   ├── SmartCommandExecutor.ets # 智能指令执行器
│   │   ├── SsapManager.ets    # SSAP管理器
│   │   ├── Tcp.ets           # TCP通信
│   │   ├── Tcp_data.ets      # TCP数据管理
│   │   ├── Util.ts           # 工具类
│   │   └── Weather.ets       # 天气服务
│   └── viewmodel/             # 视图模型
│       └── Auto_item.ets     # 自动化项目模型
└── AppScope/                   # 应用配置
    ├── app.json5             # 应用配置文件
    └── resources/            # 应用资源
```

### 核心架构设计

#### 1. 分层架构

- **表示层 (Presentation Layer)**: 页面组件和视图组件
- **业务逻辑层 (Business Logic Layer)**: 模型层的各种服务和管理器
- **数据访问层 (Data Access Layer)**: TCP通信、文件操作等

#### 2. 设计模式

- **单例模式**: `SsapManager`、`GlobalData`、`AICommandParser` 等核心服务
- **策略模式**: `ICapturerInterface` 接口的不同实现
- **观察者模式**: 语音识别状态变化通知
- **命令模式**: AI指令解析和执行

## 核心功能模块

### 1. 语音识别模块

**文件**: `AudioCapturer.ts`, `AsrConstants.ts`

**功能**:
- 实时音频采集 (16kHz, 单声道, 16位PCM)
- 语音识别状态管理
- 音频数据流处理

**关键特性**:
- 支持实时语音识别
- 音频质量优化
- 错误处理和重试机制

### 2. AI智能对话模块

**文件**: `Ai_online.ets`, `AICommandParser.ts`, `SmartCommandExecutor.ets`

**这里注意api_key为项目团队额度，自己部署时可能用完，需要自己部署，**

**本项目用的大模型为星火X1，可以申请免费额度**

**功能**:
- AI对话接口集成
- 智能指令解析
- 车辆控制指令执行

**支持的指令类型**:
- 车灯控制: `[HEADLIGHT_ON]`, `[HEADLIGHT_OFF]`
- 座椅通风: `[SEAT_VENT_ON]`, `[SEAT_VENT_OFF]`
- 氛围灯控制: `[AMBIENT_OFF]`, `[AMBIENT_MIX]`, `[AMBIENT_RED]` 等
- 座椅模式: `[SEAT_NORMAL]`, `[SEAT_COMFORT]`, `[SEAT_SPORT]`

### 3. 车辆控制模块

**文件**: `SsapManager.ets`, `Tcp_data.ets`

**功能**:
- 近场设备扫描和连接
- 车辆状态数据传输
- 实时控制指令发送

**技术实现**:
- 使用 NearLink Kit 进行设备通信
- TCP协议数据传输
- 4位数字指令编码系统

### 4. 天气服务模块

**文件**: `Weather.ets`, `Weather_Page.ets`

**功能**:
- 实时天气数据获取
- 天气信息展示
- 地理位置服务集成

### 5. 用户界面模块

**文件**: 各页面和视图组件

**功能**:
- 响应式UI设计
- 导航管理
- 状态同步显示

## 数据流架构

### 语音控制流程

```
用户语音输入 → AudioCapturer → 语音识别服务 → AI解析 → 指令执行 → 车辆控制
```

### 数据传输流程

```
UI操作 → GlobalData → SsapManager → NearLink通信 → 车载设备
```

## 权限配置

项目需要以下系统权限:

- `ohos.permission.MICROPHONE`: 麦克风访问权限
- `ohos.permission.ACCESS_NEARLINK`: 近场通信权限
- `ohos.permission.LOCATION`: 位置服务权限
- `ohos.permission.APPROXIMATELY_LOCATION`: 大概位置权限

## 开发环境配置

### 环境要求

- **DevEco Studio**: 最新版本
- **HarmonyOS SDK**: API 13 或更高版本
- **Node.js**: 16.x 或更高版本

### 构建配置

项目使用 Hvigor 构建系统，主要配置文件:

- `build-profile.json5`: 构建配置
- `oh-package.json5`: 依赖管理
- `hvigorfile.ts`: 构建脚本

**这里注意迁移使用时要修改对应配置**

## 部署说明

### 开发环境部署

1. 克隆项目到本地
2. 使用 DevEco Studio 打开项目
3. 配置签名证书（若使用星闪则需要手动签名）
4. 连接 HarmonyOS 设备或模拟器
5. 运行项目

### 生产环境部署

1. 配置生产环境签名
2. 构建 HAP 包
3. 通过应用市场或企业分发渠道部署

## 性能优化

### 内存管理

- 使用单例模式减少对象创建
- 及时释放音频资源
- 优化大数据对象的生命周期

### 网络优化

- 实现请求缓存机制
- 优化 AI 接口调用频率
- 使用连接池管理 TCP 连接

### UI 性能

- 使用懒加载优化页面渲染
- 实现虚拟滚动优化长列表
- 优化动画性能

## 安全考虑

### 数据安全

- 语音数据本地处理，不存储敏感信息
- API 密钥安全存储
- 网络传输数据加密

### 权限安全

- 最小权限原则
- 运行时权限检查
- 用户隐私保护

## 测试策略

### 单元测试

- 核心业务逻辑测试
- 数据模型验证
- 工具类函数测试

### 集成测试

- 语音识别流程测试
- AI 对话集成测试
- 设备通信测试

### 用户体验测试

- 语音识别准确率测试
- 响应时间测试
- 界面交互测试

## 维护和扩展

### 代码维护

- 遵循 TypeScript 编码规范
- 定期代码审查
- 文档同步更新

### 功能扩展

- 模块化设计支持功能扩展
- 插件化架构预留扩展点
- API 版本兼容性管理

## 故障排除

### 常见问题

1. **语音识别失败**
   - 检查麦克风权限
   - 验证网络连接
   - 确认语音识别服务状态

2. **设备连接失败**
   - 检查 NearLink 权限
   - 验证设备地址配置
   - 确认设备在通信范围内

3. **AI 响应异常**
   - 检查 API 密钥配置
   - 验证网络连接状态
   - 查看错误日志信息

## 版本历史

- **v1.0.0**: 初始版本，基础功能实现
- **v1.1.0**: 优化语音识别准确率
- **v1.2.0**: 增加天气服务功能
- **v1.3.0**: 完善车辆控制指令

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交代码变更
4. 创建 Pull Request
5. 代码审查和合并

## 许可证

本项目采用 MIT 许可证，详见 LICENSE 文件。

## 联系方式

- 项目维护者: 216团队——深圳技术大学
- 邮箱: mingjieli2004@163.com

---
