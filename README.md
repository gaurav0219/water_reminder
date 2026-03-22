# Water Reminder & Hydration Tracker 💧

A beautifully designed Flutter application to help you stay hydrated through smart tracking and intelligent background reminders.

## 🌟 Features

*   **Intelligent Beverage Tracking**: Track not just water, but Coffee, Tea, Milk, and Custom liquids. The app automatically calculates the true hydration multiplier of different beverages (e.g., Coffee adds less effective hydration than pure water).
*   **Stunning UI & Animations**: Built with premium aesthetics in mind. Enjoy sleek dark/light themes, glassmorphism UI elements, smooth transitions, and a delightful confetti celebration when you hit your daily goal!
*   **Precise Background Reminders**: 
    *   Schedules exact-timing notifications using Android 12+ `SCHEDULE_EXACT_ALARM` APIs.
    *   Works flawlessly in the background and gracefully falls back on older or restricted devices.
    *   Survives device reboots seamlessly.
*   **Granular User Controls**: Customize your settings! Toggle notification sound, vibration, customize your sleep/wake boundaries so you aren't disturbed at night, and change your reminder intervals.
*   **History & Calendar**: View your hydration trends over time using the interactive calendar view, which shows you exactly how much you drank on any given day.

## 📱 Screenshots

*(Add screenshots here showing the Dashboard, History Calendar, and Settings panel natively on devices)*

## 🛠️ Technical Stack

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Language:** Dart
*   **State Management:** `provider`
*   **Local Storage:** `shared_preferences`
*   **Background Tasks:** `flutter_local_notifications`, `timezone`

## 🚀 Getting Started

If you want to run this app locally:

1.  **Ensure you have Flutter installed** matching the version in `pubspec.yaml` (>=3.38.4).
2.  Clone this repository.
3.  Run `flutter pub get` in the terminal to install dependencies.
4.  Run `flutter run` or use your IDE to deploy to a connected Android/iOS device or emulator.

## 🤝 Contributing

Feel free to fork this project, open an issue, or submit a pull request if you want to improve the app, add new beverages, or translate it into another language!
