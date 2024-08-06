# GharKaBazaar Admin Flutter Web

GharKaBazaar Admin is a Flutter web application that allows administrators to manage products, buyers, orders, categories, banners, and more. This project leverages Firebase for backend services.

## Features

- **Product Management**: View, add, and manage products.
- **Buyer Management**: View and manage buyers.
- **Order Management**: View and manage orders.
- **Category Management**: View and manage product categories.
- **Banner Management**: Upload and manage promotional banners.
- **Responsive UI**: Optimized for various screen sizes.

## Screenshots

Screenshots will be added here

## Getting Started

Follow these instructions to set up the project on your local machine for development and testing purposes.

### Prerequisites

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Firebase Account: [Sign Up](https://firebase.google.com/)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/Rahilsamani/gharKaBazaar-Admin.git
   cd gharKaBazaar-Admin
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:

   - Go to the Firebase Console.
   - Create a new project.
   - Add a web app to your project and copy the Firebase configuration.
   - Create a `.env` file in the root of the project and add your Firebase configuration:

4. **Run the application**:

   ```bash
   flutter run -d chrome
   ```

## Project Structure

- **lib**
  - **provider**: Contains providers for state management.
  - **views/screens**: Contains the screen widgets for the application.
  - **views/screens/inner_screens**: Contains inner screen widgets.
  - **views/screens/inner_screens/widgets**: Contains reusable widgets.

## Dependencies

- `firebase_core`
- `provider`
- `flutter_admin_scaffold`
- `cupertino_icons`

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Create a new Pull Request.

## Acknowledgments

- Thanks to the Flutter community for the amazing resources and support.
- Firebase for the robust backend services.

