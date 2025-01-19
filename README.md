# PulseHub Platform App

<p align="center">
  <h3 align="center">PulseHub Platform - Industrial IoT Monitoring Solution</h3>

  <p align="center">
    A powerful Flutter-based industrial IoT monitoring platform with real-time sensor data visualization, analytics, and collaboration features.
    <br>
    Built with modern Flutter architecture, following clean code principles and industry best practices.
    <br>
    <br>
    <a href="https://github.com/ahmedtohamy1/PulseHub/issues/new">Report bug</a>
    ·
    <a href="https://github.com/ahmedtohamy1/PulseHub/issues/new">Request feature</a>
  </p>
</p>

## Features

- 🏭 **Industrial IoT Monitoring**

  - Real-time sensor data visualization
  - Historical data analysis
  - Custom dashboards creation
  - Sensor health monitoring
  - Alert configuration and management

- 🔐 **Advanced Security**

  - Biometric authentication
  - Role-based access control
  - Secure API communication
  - Session management
  - OTP verification

- 👥 **Team Collaboration**

  - User management
  - Group permissions
  - Project sharing
  - Real-time notifications
  - Activity logging

- 📊 **Analytics & Reporting**
  - AI-powered data analysis
  - Custom data visualization
  - Export capabilities
  - Trend analysis
  - Performance metrics

## Architecture & Technical Stack

### Core Technologies

- **Flutter 3.x** - UI Framework
- **Dart 3.x** - Programming Language
- **BLoC Pattern** - State Management
- **MVVM Architecture** - Design Pattern

### Key Packages

- `flutter_bloc` - State Management
- `injectable` - Dependency Injection
- `go_router` - Navigation
- `dio` - HTTP Client
- `fpdart` - Functional Programming
- `envied` - Environment Configuration
- `local_auth` - Biometric Authentication
- `flutter_secure_storage` - Secure Data Storage

### Project Structure

```
lib/
├── core/
│   ├── di/          # Dependency Injection
│   ├── env/         # Environment Configuration
│   ├── helpers/     # Helper Functions
│   ├── layout/      # Base Layouts
│   ├── networking/  # API Communication
│   ├── routing/     # Navigation
│   ├── theming/     # App Theme
│   └── utils/       # Utilities
│
├── features/
│   ├── auth/        # Authentication
│   ├── dashboard/   # Dashboard
│   ├── manage/      # Management
│   └── project/     # Project Management
│
└── main.dart        # Entry Point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository

```bash
git clone https://github.com/ahmedtohamy1/PulseHub.git
```

2. Install dependencies

```bash
flutter pub get
```

3. Set up environment variables

```bash
# Create .env file in root directory
cp .env.example .env
# Update the values in .env
```

4. Generate necessary files

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app

```bash
flutter run
```

### Environment Configuration

The app supports two environments:

- Development (`DEV_BASE_URL`)
- Production (`PROD_BASE_URL`)

Configure these in your `.env` file:

```env
DEV_BASE_URL=https://dev-api.example.com
PROD_BASE_URL=https://api.example.com
```

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow Flutter/Dart best practices
- Use meaningful variable and function names
- Write comments for complex logic
- Include tests for new features
- Keep commits atomic and well-described

## Creators

**Ahmed Tohamy**

- GitHub: [@ahmedtohamy1](https://github.com/ahmedtohamy1)

Support the development:
<a href='https://paypal.me/ahmedtohamy1' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi4.png?v=0' border='0' alt='Buy Me a Coffee' /></a>

## License

Copyright © 2024 Ahmed Tohamy. All rights reserved.

## Acknowledgments

Special thanks to:

- The Flutter team for the amazing framework
- All contributors who have helped shape this project
- The open-source community for their invaluable tools and packages
