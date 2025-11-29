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

## Configuration

The app uses **absolute URLs** for all Supabase API calls to ensure compatibility with web builds and GitHub Pages deployment.

### Step 1: Configure Supabase Credentials

Update the credentials in `lib/config/env_config.dart`:

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://your-project-id.supabase.co', // ← Replace this
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'your-anon-public-key', // ← Replace this
);
```

Find your credentials in your Supabase project dashboard:
- Go to https://app.supabase.com/project/YOUR_PROJECT_ID/settings/api
- Copy your **Project URL** (e.g., `https://xxxxx.supabase.co`)
- Copy your **anon/public** key

**IMPORTANT:** The URL MUST be absolute (`https://...`), not a relative path like `/rest/v1`.

### Step 2: Build with Environment Variables (Recommended for CI/CD)

For production builds, pass credentials at compile time:

```bash
# Web build
flutter build web --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Android APK build
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Step 3: GitHub Secrets (for GitHub Actions)

For automated builds via GitHub Actions, add the following secrets to your repository:

1. Go to your repository → Settings → Secrets and variables → Actions
2. Add two secrets:
   - `SUPABASE_URL` = `https://your-project-id.supabase.co`
   - `SUPABASE_ANON_KEY` = your anon public key

The workflows in `.github/workflows/` are already configured to use these secrets.

### Schema Setup

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

## Mawjood Admin Dashboard (Next.js)

A production-ready admin panel for managing categories and businesses using Next.js 14 (App Router), TypeScript, Tailwind CSS, and Supabase Auth.

### Prerequisites
- Supabase project with the following tables and RLS policies enabled:
  - `public.categories (id uuid pk, name_ar text not null, name_en text, icon text)`
  - `public.businesses (id uuid pk, name text not null, category_id uuid references public.categories(id), description text, city text, address text, phone text, rating numeric, latitude double precision, longitude double precision, images text[], features text[])`
  - `public.admins (id uuid pk default gen_random_uuid(), user_id uuid unique not null, email text unique not null, role text not null default 'admin', created_at timestamptz default now())`
- RLS helpers:
  - `public.is_admin()` returns `true` when `auth.uid()` exists in `public.admins.user_id`.
  - Policies allowing public read on categories/businesses and full access for authenticated users where `is_admin()` is true.

### Environment variables
Create an `.env.local` file inside `admin/` with:

```
NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key-server-only>
```

`SUPABASE_SERVICE_ROLE_KEY` is only used on the server. Never expose it to the browser.

### Running locally

```
cd admin
npm install
npm run dev
```

The app will be available on http://localhost:3000. Log in with a Supabase Auth email/password user that also exists in `public.admins`.

### Deployment (e.g., Vercel)
- Set the environment variables above in your hosting provider (service role key as a server-side secret only).
- Deploy the `admin` directory as a Next.js app connected to your Git repository.
