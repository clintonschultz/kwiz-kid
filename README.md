# KwizKid 🧠✨

**KwizKid** is an educational quiz app designed specifically for children, combining learning with fun through AI-generated questions in a safe, child-friendly environment.

## Features 🎯

- **AI-Powered Questions**: Dynamically generated quiz questions tailored to each child's age and learning level
- **Child-Safe Content**: Advanced content filtering ensures all questions are appropriate for children
- **Multiple Categories**: Math, Science, Reading, History, Geography, and Art
- **Unidirectional State Flow**: Clean, maintainable architecture using SwiftUI
- **AWS Integration**: Secure authentication and backend services
- **RevenueCat Integration**: Subscription management for premium features
- **Parental Controls**: Time limits, progress tracking, and content filtering
- **Beautiful UI**: Fun, engaging design that appeals to children while maintaining educational value

## Architecture 🏗️

### State Management
KwizKid uses a unidirectional state flow pattern where:
- **State** can only be mutated in one place (the reducer)
- **Actions** are dispatched to trigger state changes
- **Middleware** handles side effects like API calls and analytics

### Core Components
- `AppStore`: Central state management
- `AppReducer`: Pure functions that handle state transitions
- `AppActions`: All possible actions in the app
- `Middleware`: Handles side effects and external services

### Services
- `AWSService`: Authentication and backend integration
- `RevenueCatService`: Subscription management
- `ChildSafetyService`: Content filtering and safety features
- `QuizContentService`: AI-generated question creation

## Setup Instructions 🚀

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- AWS Account
- RevenueCat Account

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/kwiz-kid.git
cd kwiz-kid
```

### 2. Install Dependencies
```bash
swift package resolve
```

### 3. Configure AWS
1. Create an AWS account and set up Cognito
2. Update `AWSService.swift` with your AWS configuration
3. Set up AWS Bedrock for AI question generation

### 4. Configure RevenueCat
1. Create a RevenueCat account
2. Update `RevenueCatService.swift` with your API key
3. Set up your subscription products

### 5. Configure Firebase (Optional)
1. Create a Firebase project
2. Add your `GoogleService-Info.plist` to the project
3. Enable Analytics and Crashlytics

### 6. Build and Run
1. Open `KwizKid.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project

## Project Structure 📁

```
KwizKid/
├── Core/
│   ├── AppState.swift          # App state definitions
│   ├── AppActions.swift        # Action definitions
│   └── AppStore.swift          # State management
├── Views/
│   ├── WelcomeView.swift       # Welcome screen
│   ├── CategorySelectionView.swift
│   ├── QuizView.swift          # Quiz interface
│   └── ResultsView.swift       # Results screen
├── Services/
│   ├── AWSService.swift        # AWS integration
│   ├── RevenueCatService.swift # Subscription management
│   └── ChildSafetyService.swift # Safety features
├── Theme/
│   └── KwizKidTheme.swift      # Design system
└── Resources/
    ├── Assets.xcassets         # App assets
    └── Info.plist             # App configuration
```

## Key Features Explained 🔍

### Child Safety
- Content filtering ensures all questions are age-appropriate
- Parental controls allow customization of learning experience
- Time limits prevent overuse
- Progress tracking helps parents monitor learning

### AI Integration
- Questions are generated using AWS Bedrock
- Content is filtered for child safety
- Difficulty is adjusted based on age and performance
- Questions are personalized to each child's interests

### Subscription Model
- Free tier with limited features
- Premium subscription unlocks all categories
- Family sharing support
- Offline mode for premium users

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Support 💬

For support, email support@kwizkid.app or join our Discord community.

## Roadmap 🗺️

- [ ] Voice-based learning activities
- [ ] Multiplayer quiz modes
- [ ] Parent dashboard
- [ ] Offline mode
- [ ] Accessibility improvements
- [ ] More languages support
- [ ] Advanced analytics
- [ ] Custom quiz creation

---

Made with ❤️ for children's education
