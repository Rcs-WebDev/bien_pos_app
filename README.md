# 🛍️ Flutter POS - Point of Sale Application

[![Flutter](https://img.shields.io/badge/Flutter-3.47.0-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.0-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)](https://flutter.dev)

A modern, feature-rich **Point of Sale (POS)** mobile and web application built with Flutter. Designed for retail stores, coffee shops, and small-to-medium businesses to handle daily sales transactions, product inventory, thermal receipt printing via Bluetooth, and comprehensive financial reports.

---

## ✨ Features

- **🛒 Cashier & Checkout Management**:
  - Interactive grid product catalog with instant category filtering and search.
  - Cart drawer with real-time total, tax, discount calculations, and item quantity updates.
  - Flexible payment methods: **Cash**, **QRIS / E-Wallet**, and **Debit / Credit Card**.

- **📦 Inventory & Product Management**:
  - Full CRUD operations for products and categories.
  - Real-time stock tracking and low-stock indicators.

- **📜 Transaction History & Digital Receipts**:
  - Instant digital thermal receipt modal upon successful checkout.
  - ESC/POS Bluetooth thermal printer integration for printing physical receipts.
  - Comprehensive history log with search and transaction details breakdown.

- **📊 Reports & Cash Flow Analytics**:
  - Daily & monthly sales revenue summary.
  - Shift closing reports and cash register drawer management.
  - Best-selling products analytics.

- **🌐 Cross-Platform (Android & Web)**:
  - Supports native **Android APK** build for mobile devices & POS handheld terminals.
  - Supports **Web** deployment (e.g., GitHub Pages, Vercel) for interactive portfolio demos.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider) pattern
- **Local Persistence**: `shared_preferences` / local storage service
- **Hardware Integration**: ESC/POS Bluetooth Printer service
- **CI/CD**: GitHub Actions (`.github/workflows/deploy.yml`) for automated Flutter Web deployment to GitHub Pages.

---

## 📁 Project Structure

```text
lib/
├── models/             # Data models (Product, CartItem, Transaction, CashFlow, ShiftClosing)
├── providers/          # State management (PosProvider, ProductProvider, AuthProvider)
├── screens/            # App screens (Login, Cashier, Products, Transactions, Reports, Settings)
├── services/           # Services (BluetoothPrinterService, StorageService)
├── widgets/            # Reusable UI components (CartDrawer, PaymentDialog, ReceiptDialog, ProductCard)
└── main.dart           # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:
- **Flutter SDK** (v3.0.0 or higher)
- **Dart SDK** (v3.0.0 or higher)
- **Android Studio** / **VS Code** with Flutter extension installed
- **Git**

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Rcs-WebDev/bien_pos_app.git
   cd bien_pos_app
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run the app locally**:
   - **For Web**:
     ```bash
     flutter run -d chrome
     ```
   - **For Android Emulator / Connected Device**:
     ```bash
     flutter run
     ```

---

## 📦 Building Releases

### 📱 Build Android APK

To generate a release APK for Android handheld devices or testing:
```bash
flutter build apk --release
```
The output APK file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

### 🌐 Build Web Version

To generate static web files for hosting:
```bash
flutter build web --release
```
The static files will be generated in `build/web/`.

---

## 🚀 Automated Deployment (GitHub Pages)

This repository includes a GitHub Actions workflow `.github/workflows/deploy.yml`. When you push to the `main` branch, it automatically builds the Flutter Web application and deploys it to **GitHub Pages**.

1. Go to your repository **Settings** -> **Pages**.
2. Set **Source** to **Deploy from a branch** (select `gh-pages` branch) or **GitHub Actions**.
3. Push changes to `main`:
   ```bash
   git push origin main
   ```
4. Access your live web demo at: `https://Rcs-WebDev.github.io/bien_pos_app/`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

