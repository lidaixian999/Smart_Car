# Smart Vehicle System

## Project Overview

FinalCar is an intelligent vehicle control system developed based on HarmonyOS, integrating various functions such as voice recognition, AI intelligent dialogue, vehicle control, and weather queries. The project is developed using ArkTS language and provides a complete in-vehicle intelligent interaction experience.

**Demo Video:** https://pan.baidu.com/share/init?surl=qb8LKQoRpX77C627eS1XPw&pwd=jgsg

## Tech Stack

- **Development Language:** ArkTS (TypeScript)
- **Development Framework:** HarmonyOS SDK
- **UI Framework:** ArkUI
- **Voice Recognition:** HarmonyOS Voice Recognition Service
- **Network Communication:** HTTP/TCP Protocol
- **Near Field Communication:** NearLink Kit
- **Permission Management:** AbilityKit

## Project Architecture

### Directory Structure

text

```
finalCar/
├── entry/src/main/ets/
│   ├── entryability/           # Application Entry Capability
│   │   └── EntryAbility.ets    # Main Entry Class
│   ├── pages/                  # Page Components
│   │   ├── Index.ets          # Main Page
│   │   ├── Car_page.ets       # Vehicle Status Page
│   │   ├── Aipage.ets         # AI Dialogue Page
│   │   ├── Setting_page.ets   # Settings Page
│   │   └── map.ets           # Map Page
│   ├── view/                   # View Components
│   │   ├── AutoSet.ets        # Auto Settings Component
│   │   ├── NonePage.ets       # Empty Page Component
│   │   ├── Weather_Page.ets   # Weather Page Component
│   │   ├── carInformation.ets # Vehicle Information Component
│   │   ├── light_control.ets  # Light Control Component
│   │   └── seat.ets          # Seat Control Component
│   ├── model/                  # Data Models & Business Logic
│   │   ├── AICommandParser.ts # AI Command Parser
│   │   ├── Ai_online.ets      # AI Online Service
│   │   ├── AsrConstants.ts    # Voice Recognition Constants
│   │   ├── AudioCapturer.ts   # Audio Capturer
│   │   ├── FileCapturer.ts    # File Capturer
│   │   ├── ICapturerInterface.ts # Capturer Interface
│   │   ├── SmartCommandExecutor.ets # Smart Command Executor
│   │   ├── SsapManager.ets    # SSAP Manager
│   │   ├── Tcp.ets           # TCP Communication
│   │   ├── Tcp_data.ets      # TCP Data Management
│   │   ├── Util.ts           # Utility Class
│   │   └── Weather.ets       # Weather Service
│   └── viewmodel/             # View Models
│       └── Auto_item.ets     # Automation Item Model
└── AppScope/                   # Application Configuration
    ├── app.json5             # Application Configuration File
    └── resources/            # Application Resources
```

### Core Architecture Design

#### 1. Layered Architecture

- **Presentation Layer:** Page components and view components
- **Business Logic Layer:** Various services and managers in the model layer
- **Data Access Layer:** TCP communication, file operations, etc.

#### 2. Design Patterns

- **Singleton Pattern:** Core services like SsapManager, GlobalData, AICommandParser
- **Strategy Pattern:** Different implementations of ICapturerInterface
- **Observer Pattern:** Voice recognition state change notifications
- **Command Pattern:** AI command parsing and execution

## Core Functional Modules

### 1. Voice Recognition Module

**Files:** AudioCapturer.ts, AsrConstants.ts

**Features:**

- Real-time audio capture (16kHz, mono, 16-bit PCM)
- Voice recognition state management
- Audio data stream processing

**Key Characteristics:**

- Supports real-time voice recognition
- Audio quality optimization
- Error handling and retry mechanisms

### 2. AI Intelligent Dialogue Module

**Files:** Ai_online.ets, AICommandParser.ts, SmartCommandExecutor.ets

**Note:** The API key has limited quota for the project team. You may need to deploy your own instance when the quota is exhausted. This project uses the Spark X1 large language model, which offers free quota for application.

**Features:**

- AI dialogue interface integration
- Intelligent command parsing
- Vehicle control command execution

**Supported Command Types:**

- Headlight control: [HEADLIGHT_ON], [HEADLIGHT_OFF]
- Seat ventilation: [SEAT_VENT_ON], [SEAT_VENT_OFF]
- Ambient light control: [AMBIENT_OFF], [AMBIENT_MIX], [AMBIENT_RED], etc.
- Seat modes: [SEAT_NORMAL], [SEAT_COMFORT], [SEAT_SPORT]

### 3. Vehicle Control Module

**Files:** SsapManager.ets, Tcp_data.ets

**Features:**

- Near-field device scanning and connection
- Vehicle status data transmission
- Real-time control command sending

**Technical Implementation:**

- Uses NearLink Kit for device communication
- TCP protocol data transmission
- 4-digit command encoding system

### 4. Weather Service Module

**Files:** Weather.ets, Weather_Page.ets

**Features:**

- Real-time weather data acquisition
- Weather information display
- Geographic location service integration

### 5. User Interface Module

**Files:** Various page and view components

**Features:**

- Responsive UI design
- Navigation management
- Status synchronization display

## Data Flow Architecture

### Voice Control Flow

User Voice Input → AudioCapturer → Voice Recognition Service → AI Parsing → Command Execution → Vehicle Control

### Data Transmission Flow

UI Operation → GlobalData → SsapManager → NearLink Communication → Vehicle Device

## Permission Configuration

The project requires the following system permissions:

- `ohos.permission.MICROPHONE`: Microphone access permission
- `ohos.permission.ACCESS_NEARLINK`: Near-field communication permission
- `ohos.permission.LOCATION`: Location service permission
- `ohos.permission.APPROXIMATELY_LOCATION`: Approximate location permission

## Development Environment Configuration

### Environment Requirements

- **DevEco Studio:** Latest version
- **HarmonyOS SDK:** API 13 or higher
- **Node.js:** 16.x or higher

### Build Configuration

The project uses Hvigor build system, main configuration files:

- `build-profile.json5`: Build configuration
- `oh-package.json5`: Dependency management
- `hvigorfile.ts`: Build scripts

**Note:** Remember to modify corresponding configurations when migrating for your own use.

## Deployment Instructions

### Development Environment Deployment

1. Clone the project locally
2. Open the project with DevEco Studio
3. Configure signature certificate (manual signature required if using Spark)
4. Connect HarmonyOS device or emulator
5. Run the project

### Production Environment Deployment

1. Configure production environment signature
2. Build HAP package
3. Deploy through app market or enterprise distribution channels

## Performance Optimization

### Memory Management

- Use singleton pattern to reduce object creation
- Release audio resources promptly
- Optimize lifecycle of large data objects

### Network Optimization

- Implement request caching mechanism
- Optimize AI interface call frequency
- Use connection pool for TCP connection management

### UI Performance

- Use lazy loading to optimize page rendering
- Implement virtual scrolling for long lists
- Optimize animation performance

## Security Considerations

### Data Security

- Local processing of voice data, no sensitive information storage
- Secure storage of API keys
- Encrypted network data transmission

### Permission Security

- Principle of least privilege
- Runtime permission checking
- User privacy protection

## Testing Strategy

### Unit Testing

- Core business logic testing
- Data model validation
- Utility function testing

### Integration Testing

- Voice recognition process testing
- AI dialogue integration testing
- Device communication testing

### User Experience Testing

- Voice recognition accuracy testing
- Response time testing
- Interface interaction testing

## Maintenance and Extension

### Code Maintenance

- Follow TypeScript coding standards
- Regular code reviews
- Synchronized documentation updates

### Feature Extension

- Modular design supports feature extension
- Plugin architecture with extension points reserved
- API version compatibility management

## Troubleshooting

### Common Issues

**Voice Recognition Failure**

- Check microphone permissions
- Verify network connection
- Confirm voice recognition service status

**Device Connection Failure**

- Check NearLink permissions
- Verify device address configuration
- Confirm device is within communication range

**AI Response Abnormalities**

- Check API key configuration
- Verify network connection status
- Check error log information

## Version History

- **v1.0.0:** Initial version, basic functionality implementation
- **v1.1.0:** Optimized voice recognition accuracy
- **v1.2.0:** Added weather service functionality
- **v1.3.0:** Improved vehicle control commands

## Contributing Guide

1. Fork the project
2. Create a feature branch
3. Submit code changes
4. Create a Pull Request
5. Code review and merge

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

- **Project Maintainer:** Team 216 - Shenzhen Technology University
- **Email:** [mingjieli2004@163.com](https://mailto:mingjieli2004@163.com/)