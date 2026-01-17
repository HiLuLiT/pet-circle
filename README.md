# Pet Circle 🐾

A multi-caregiver canine respiratory monitoring app built with Flutter. Pet Circle enables pet owners, caregivers, and veterinarians to collaboratively track Sleeping Respiratory Rate (SRR) for early detection of heart disease progression.

## Features

### Dual User Flows

**For Veterinarians:**
- View all clinic patients in a unified dashboard
- Access detailed pet profiles with measurement history
- Add clinical notes and observations
- Monitor respiratory trends across multiple patients

**For Pet Owners:**
- Manage your pets' health profiles
- Take manual or AI-assisted SRR measurements
- Invite caregivers and veterinarians to your care circle
- Track measurement history and receive alerts

### Core Functionality

- **Manual SRR Measurement**: Tap-to-count interface with configurable timer durations
- **VisionRR Mode**: AI-assisted measurement using device camera (coming soon)
- **Care Circle**: Invite family members, pet sitters, and vets to collaborate
- **Clinical Notes**: Veterinarians can add observations visible to the care team
- **Status Tracking**: Real-time status badges (Normal, Elevated, Critical)

## Screenshots

| Welcome | Vet Dashboard | Owner Dashboard | Pet Detail |
|---------|---------------|-----------------|------------|
| Dual entry for vets and owners | Multi-pet clinic view | Single/multi pet management | Full history with notes |

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Chrome (for web development)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd pet-circle

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### Running on Different Platforms

```bash
# Web
flutter run -d chrome

# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# macOS Desktop
flutter run -d macos
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app_routes.dart           # Route definitions
├── models/
│   ├── user.dart             # User and role models
│   ├── pet.dart              # Pet profile model
│   ├── measurement.dart      # SRR measurement model
│   ├── care_circle_member.dart
│   └── clinical_note.dart    # Vet notes model
├── screens/
│   ├── welcome_screen.dart   # Dual-entry welcome
│   ├── onboarding/           # Pet profile setup flow
│   ├── dashboard/
│   │   ├── vet_dashboard.dart    # Veterinarian view
│   │   └── owner_dashboard.dart  # Pet owner view
│   ├── pet_detail/           # Detailed pet view with notes
│   └── measurement/          # SRR measurement interface
├── widgets/                  # Reusable UI components
├── theme/                    # Colors, typography, assets
└── data/
    └── mock_data.dart        # Demo data for testing
```

## Design System

The app features a neumorphic design with:
- **Primary**: Burgundy (#5B2C3F)
- **Accent**: Soft Pink (#E8B4B8)
- **Success**: Green (#7FBA7A)
- **Warning**: Amber (#F39C12)

## Mock Data

For demo purposes, the app includes:
- **Dr. Smith** (Veterinarian): Can view all clinic pets
- **Hila** (Pet Owner): Owns Princess the Cavalier King Charles

## Tech Stack

- **Framework**: Flutter
- **State Management**: StatefulWidget (simple state)
- **Assets**: SVG graphics via flutter_svg
- **APIs**: 
  - [Dog CEO API](https://dog.ceo/dog-api/) for pet photos
  - [UI Avatars](https://ui-avatars.com/) for user avatars

## Roadmap

- [ ] VisionRR AI-powered measurement
- [ ] Push notifications for measurement reminders
- [ ] Data export (PDF reports)
- [ ] Cloud sync with Firebase
- [ ] Apple Watch / WearOS companion apps

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Inspired by veterinary cardiology best practices for SRR monitoring
- Design based on modern neumorphic UI principles
