# Mawjood MVP Documentation

This document outlines the implementation details, architectural changes, and key features delivered as part of the Mawjood Minimum Viable Product (MVP). The primary goal was to create a functional and complete application based on the existing project structure and Supabase integration, while also enhancing testability and maintainability through the adoption of Riverpod for state management.

## 1. Core Application Features Implemented

The following user-facing features have been implemented or significantly enhanced:

*   **Onboarding Flow**: A simplified onboarding screen (`OnboardingScreen`) is displayed on first launch. Upon completion, it navigates to the `HomeScreen` and uses `shared_preferences` to ensure it's not shown again.
*   **Home Screen (`HomeScreen`)**:
    *   Displays a list of business categories.
    *   Displays a list of featured/initial businesses (currently populated from the first available category).
    *   Includes a `MawjoodSearchBar` that navigates to the `SearchScreen`.
    *   Integrates an `OfflineIndicator` to visually inform the user about connectivity status.
*   **Business List Screen (`BusinessListScreen`)**: Displays businesses filtered by a selected category, allowing navigation to individual business details.
*   **Search Screen (`SearchScreen`)**: Provides a search input field and displays recent search queries. Submitting a query navigates to `SearchResultsScreen`.
*   **Search Results Screen (`SearchResultsScreen`)**: Displays a list of businesses matching the user's search query.
*   **Business Detail Screen (`BusinessDetailScreen`)**: Presents comprehensive information about a selected business, including its description, address, contact options (call, WhatsApp), sharing functionality, and customer reviews. It also lists related businesses.
*   **Reviews Screen (`ReviewsScreen`)**: Allows users to view existing reviews for a business and submit new reviews.

## 2. Architectural & Refactoring Changes

Significant architectural changes were made to improve modularity, testability, and adherence to modern Flutter development practices:

*   **Riverpod Integration**: Riverpod was adopted as the primary state management solution across the application.
*   **SupabaseService Refactoring**:
    *   The `SupabaseService` class was refactored from a collection of static methods into an instantiable class.
    *   It now takes a `SupabaseClient` instance in its constructor, making it injectable and testable.
    *   A Riverpod `Provider` (`supabaseServiceProvider`) was created to provide a singleton instance of the initialized `SupabaseService` throughout the app.
    *   An `initializeAndCreate` static factory method was added to `SupabaseService` to handle its initial setup (including `Supabase.initialize`) at application startup.
*   **CacheService Refactoring**:
    *   The `CacheService` class was refactored from a collection of static methods into an instantiable class, managing Hive operations for caching.
    *   A Riverpod `Provider` (`cacheServiceProvider`) was created to provide a singleton instance of the `CacheService`.
    *   The `CacheService.create()` factory method handles `Hive.initFlutter()` and adapter registration.
*   **ConnectivityService Refactoring**:
    *   The `ConnectivityService` was refactored from a singleton pattern into a `StateNotifierProvider` (`connectivityStatusProvider`) managed by Riverpod.
    *   This provider now directly manages and exposes the application's online/offline status, allowing UI components to react to connectivity changes.
*   **EnvConfig Integration**: The `EnvConfig` class, responsible for loading environment variables, was integrated as a Riverpod `Provider` (`envConfigProvider`), making environment configuration easily mockable in tests.
*   **Repository Layer Updates**: Both `CategoryRepository` and `BusinessRepository` were updated to take their respective service dependencies (`SupabaseService`) via their constructors, and Riverpod providers were created for them.
*   **UI Updates**: All relevant UI screens and widgets (`HomeScreen`, `BusinessListScreen`, `SearchScreen`, `SearchResultsScreen`, `BusinessDetailScreen`, ``ReviewsScreen`, `OfflineIndicator`) were updated to consume data and interact with services using Riverpod providers.

## 3. Testing Strategy

The refactoring focused heavily on improving the application's testability.

*   **Unit Tests**:
    *   `app_flow_test.dart`: A widget test was added to verify the core application flow, including the onboarding logic and navigation to the home screen, correctly mocking `shared_preferences`.
    *   Further unit tests for providers (e.g., `category_provider`) were initiated to demonstrate the testability of the refactored architecture, though not fully completed as per user request to finalize the work. The setup for mocking `SupabaseService`, `CacheService`, and `Connectivity` is now in place for future test expansion.
*   **Test Environment Setup**: Mocking strategies were implemented for `shared_preferences`, `EnvConfig`, `SupabaseService`, `CacheService`, `Connectivity`, and the repositories, showcasing how to isolate units for testing.

## 4. How to Run the Application

1.  **Environment Setup**:
    *   Ensure you have Flutter installed and configured (`flutter doctor`).
    *   Create a `.env` file in the project root (next to `pubspec.yaml`) based on `_env.example`. Replace placeholders with your actual Supabase URL and anonymous key.
        ```
        SUPABASE_URL=YOUR_SUPABASE_URL_HERE
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE
        ```
2.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate Hive Adapters (if models change)**:
    ```bash
    flutter pub run build_runner build
    ```
4.  **Run the Application**:
    *   For Web: `flutter run -d chrome`
    *   For Android: `flutter run`
    *   For iOS: `flutter run` (or open in Xcode)

## 5. Next Steps / Future Considerations

*   **Complete Test Coverage**: Implement comprehensive unit and widget tests for all providers, widgets, and critical business logic.
*   **Error Handling and UI Feedback**: Enhance user-facing error messages and loading indicators for a smoother experience.
*   **User Authentication**: Implement user registration, login, and profile management if required by future phases.
*   **Advanced Features**: Implement submitting reviews, business claims fully, location-based services, and other features as per requirements.
*   **UI/UX Polish**: Fine-tune the user interface and user experience based on `BRANDING.md` and `UX_PRINCIPLES.md` documents.
*   **Performance Optimization**: Continue to optimize performance for large datasets and complex UI interactions.