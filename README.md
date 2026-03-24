# Raktadan - Blood Donation App

A Flutter application for blood donation management and coordination.

## Features

- User authentication (login/register)
- Blood donor registration and management
- Blood request system with notifications
- Donation progress tracking
- Blood bank information
- Emergency contact numbers
- Event management for blood donation camps

## Recent Fixes Applied

### Code Quality Improvements
- Fixed typos ("comming" → "coming", "Setting" → "Settings")
- Improved linting rules in `analysis_options.yaml`
- Enhanced code formatting and consistency
- Replaced `print` statements with `debugPrint`

### UI/UX Enhancements
- Fixed PopupMenuItem implementation with proper value handling
- Improved notification badge positioning and styling
- Enhanced ElevatedButton property ordering
- Better app theme with comprehensive styling

### Architecture Improvements
- Created Firebase configuration file for better organization
- Implemented proper DonorService with CRUD operations
- Added error handling utilities
- Created validation utilities for forms
- Added helper functions for date formatting and text manipulation
- Centralized app constants

### Bug Fixes
- Fixed incomplete home_screen.dart file structure
- Resolved import issues
- Fixed chat route configuration
- Enhanced auth service with additional utility methods

## Project Structure

```
lib/
├── app/
│   ├── constants/
│   ├── routes/
│   └── theme/
├── core/
│   ├── config/
│   ├── constants/
│   ├── models/
│   ├── services/
│   └── utils/
├── features/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   ├── request/
│   └── sub_screens/
└── widgets/
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase for your project
4. Run `flutter run` to start the application

## Dependencies

- Firebase (Core, Auth, Firestore)
- URL Launcher
- QR Flutter
- Share Plus
- Intl
- Convex Bottom Bar

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
