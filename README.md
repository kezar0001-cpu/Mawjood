# Mawjood – The Modern Iraqi Business Directory App
Mawjood is a fast, reliable, Arabic-first business directory designed specifically for Iraq. The app focuses on accuracy, speed, and simplicity, giving users a clean way to find real businesses with verified information. Built with Flutter and structured for scalability, Mawjood aims to become the most trusted discovery platform in the country.

---

# Vision
Iraq suffers from outdated, unreliable directory apps with inaccurate numbers, broken locations, and poor user experience. Mawjood changes this by delivering a mobile-first interface, verified listings, and instant actions. The long-term goal is to evolve Mawjood into a complete ecosystem for business discovery, verification, user reviews, and business-owner management dashboards.

---

# Features

## Core MVP Features
- **Home Screen**
  - Arabic-first RTL interface
  - Category-based browsing
  - Search for businesses instantly
  - Smooth navigation and clean UI hierarchy

- **Category Listings**
  - Business listings grouped by category
  - Quick-action buttons for Call and WhatsApp
  - Thumbnail previews for each business

- **Search System**
  - Full-text keyword search
  - Fast results with ranking
  - Graceful empty states when no match

- **Business Details**
  - Photo carousel
  - Contact buttons: Call, WhatsApp, Google Maps
  - Opening hours, address, city, district, and business description
  - Clean, modern Arabic UI design

- **Settings Screen**
  - Language information
  - About section
  - Support section

---

# Tech Stack

## Frontend (Flutter)
- Flutter 3.19+
- Dart
- url_launcher
- cached_network_image

## Backend (Supabase)
- PostgreSQL
- Supabase Auth (future)
- Supabase Storage (future)
- REST/RPC Integration
- Mock backend mode (active by default)

---

# Project Structure
```
lib/
 ├── main.dart
 ├── screens/
 │     ├── home_screen.dart
 │     ├── business_list_screen.dart
 │     ├── business_detail_screen.dart
 │     ├── search_screen.dart
 │     └── settings_screen.dart
 ├── widgets/
 │     ├── business_card.dart
 │     └── category_card.dart
 ├── models/
 │     ├── business.dart
 │     └── category.dart
 ├── services/
 │     └── supabase_service.dart
 └── utils/
       ├── app_colors.dart
       └── app_text.dart
```

---

# Installation & Setup

## Clone the repository
```
git clone https://github.com/yourusername/mawjood.git
cd mawjood
```

## Install dependencies
```
flutter pub get
```

## Run the app
```
flutter run
```

## Build release APK (Android)
```
flutter build apk --release
```

---

# Supabase Integration Guide

Mawjood ships with **mock mode enabled**, so it runs without any backend setup.

To connect to real Supabase:

1. Install Supabase CLI (optional)
```
npm install -g supabase
```

2. Add your Supabase keys inside `main.dart` or an env file:
```dart
await Supabase.initialize(
  url: "<YOUR_SUPABASE_URL>",
  anonKey: "<YOUR_SUPABASE_ANON_KEY>",
);
```

3. Disable mock mode:
```dart
useMock = false;
```

4. Replace mock queries with real Supabase RPC/REST calls.

A fully prepared SQL schema can be provided on request.

---

# Mock Mode
Mock mode gives developers the ability to test the full UI without connecting to any backend. This is useful for:

- UI prototyping  
- Offline development  
- Reviewing UI/UX with stakeholders  
- Faster iteration with no database migrations  

Mock mode is enabled inside:
```
supabase_service.dart → useMock = true
```

---

# Roadmap

## Phase 1 (MVP – Completed)
✔ Home screen  
✔ Categories  
✔ Search  
✔ Business detail  
✔ RTL support  
✔ Mock mode  

## Phase 2 (Short‑term Improvements)
◻ Real Supabase backend  
◻ Add multi-image support  
◻ Business hours formatting improvement  
◻ Shimmer loading UI  
◻ Better error handling  
◻ Internal admin dashboard for adding businesses  

## Phase 3 (Growth Features)
◻ User accounts  
◻ Reviews and ratings  
◻ Advanced analytics for business owners  
◻ Branch management  
◻ Offline mode  
◻ Push notifications  

## Phase 4 (Monetization)
◻ Featured listings  
◻ Sponsored businesses  
◻ Paid verification badge  
◻ B2B data access API  

---

# Contributing
Contributions are welcome. Please create a pull request with details about your changes. For large changes, open an issue first for discussion.

---

# License
This project is licensed under the **MIT License**, allowing commercial and private use.

---

# Contact
For inquiries, feature requests, or business onboarding:
**Email:** yourname@example.com  
**Project Owner:** Kezar  
