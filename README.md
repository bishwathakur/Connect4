
# Connect4 Flutter

Connect4 Flutter is a mobile application that brings the classic Connect Four game to your fingertips.
Built using Flutter and integrated with Supabase, it offers real-time online multiplayer gameplay, user authentication, and player statistics tracking.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Online Multiplayer**: Challenge players worldwide in real-time matches.
- **User Authentication**: Secure login and signup powered by Supabase.
- **Player Statistics**: Track wins, losses, and win percentages.
- **Interactive Animations**: Enjoy smooth and engaging piece-drop animations.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/yourusername/connect4-flutter.git
   ```

2. **Navigate to the Project Directory**:

   ```bash
   cd connect4-flutter
   ```

3. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

4. **Configure Supabase**:

   - Create a [Supabase](https://supabase.io/) project.
   - Obtain your Supabase URL and API Key.
   - Set up the necessary tables (`profiles`, `games`) and enable Realtime features.
   - Configure Row Level Security (RLS) policies for data protection.

5. **Set Up Environment Variables**:

   Create a `.env` file in the root directory and add your Supabase credentials:

   ```env
   SUPABASE_URL=your-supabase-url
   SUPABASE_API_KEY=your-supabase-api-key
   ```

## Usage

To run the application:

```bash
flutter run
```

Log in or sign up to start playing Connect Four with other online players.

## Architecture

The application follows the Model-View-Controller (MVC) architecture:

- **Model**: Handles data structures and business logic.
- **View**: Manages UI components and animations.
- **Controller**: Facilitates communication between the Model and View, processing user inputs and updating the UI accordingly.

## Contributing

Contributions are welcome! To contribute:

1. **Fork the Repository**.
2. **Create a New Branch**:

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit Your Changes**:

   ```bash
   git commit -m 'Add some feature'
   ```

4. **Push to the Branch**:

   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request**.

## License

Distributed under the MIT License. See `LICENSE` for more information.
