# LifeLink: Blood Donor Finder

> Every drop counts.

LifeLink is a mobile app that helps people find blood donors of the right group in their city quickly. Donors register with their blood group and city. Anyone can search donors, post a blood request, and call or SMS directly.

**SDG 3: Good Health and Well-being**

Mobile Application Development Lab, Mini Project
Dayananda Sagar College of Engineering, Department of CSE

## Features
- Register and log in with email and password
- Donor profile with blood group, city and availability switch
- Find donors by blood group and city, with compatible blood groups
- Call or SMS a donor directly
- Post blood requests with urgency (Critical, High, Normal)
- Real-time request list, mark requests as fulfilled
- Dark mode

## Tech stack
- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Provider (state management)

## Architecture
Screen -> ViewModel (Provider) -> Service -> Firestore

```
lib/
  core/        theme, colours, constants, routes, shared widgets
  models/      UserModel, RequestModel
  services/    Firebase access
  viewmodels/  app state and logic
  screens/     auth, profile, donors, requests, home
```

## Run the project
1. Install Flutter and run `flutter doctor`
2. Clone the repo: `git clone <repo-url>`
3. Run `flutter pub get`
4. Connect a phone or emulator and run `flutter run`

## Team
| Name | Role |
|---|---|
| HARSHITHA D | Authentication and Profile |
| MANYA KAMATH | Find Donors |
| MALLIKA | Blood Requests |
| LAVANYA | UI Design, Navigation and Documentation |

## Screenshots
yet to be added
