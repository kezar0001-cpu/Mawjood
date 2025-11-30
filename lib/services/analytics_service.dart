import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable collection in release mode
      await _analytics?.setAnalyticsCollectionEnabled(!kDebugMode);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = _crashlytics?.recordFlutterFatalError;

      // Pass all uncaught async errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      _isInitialized = true;
    } catch (e) {
      // Firebase not configured, continue without analytics
      debugPrint('Analytics initialization failed: $e');
    }
  }

  // Screen View Events
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  // Search Events
  Future<void> logSearch(String query, {int? resultCount}) async {
    try {
      await _analytics?.logSearch(
        searchTerm: query,
        parameters: {
          'result_count': resultCount ?? 0,
          'query_length': query.length,
        },
      );
    } catch (e) {
      debugPrint('Error logging search: $e');
    }
  }

  // Business View Events
  Future<void> logBusinessView(String businessId, String businessName) async {
    try {
      await _analytics?.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: businessId,
            itemName: businessName,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error logging business view: $e');
    }
  }

  // Call Button Tap
  Future<void> logCallButtonTap(String businessId, String businessName) async {
    try {
      await _analytics?.logEvent(
        name: 'call_business',
        parameters: {
          'business_id': businessId,
          'business_name': businessName,
          'action_type': 'phone_call',
        },
      );
    } catch (e) {
      debugPrint('Error logging call button tap: $e');
    }
  }

  // WhatsApp Button Tap
  Future<void> logWhatsAppTap(String businessId, String businessName) async {
    try {
      await _analytics?.logEvent(
        name: 'whatsapp_business',
        parameters: {
          'business_id': businessId,
          'business_name': businessName,
          'action_type': 'whatsapp',
        },
      );
    } catch (e) {
      debugPrint('Error logging WhatsApp tap: $e');
    }
  }

  // Filter Application
  Future<void> logFilterApplied({
    required String sortBy,
    int? minRating,
    List<String>? tags,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'filter_applied',
        parameters: {
          'sort_by': sortBy,
          'min_rating': minRating ?? 0,
          'tags_count': tags?.length ?? 0,
          'tags': tags?.join(',') ?? '',
        },
      );
    } catch (e) {
      debugPrint('Error logging filter applied: $e');
    }
  }

  // Category Selection
  Future<void> logCategorySelect(String categoryId, String categoryName) async {
    try {
      await _analytics?.logEvent(
        name: 'select_category',
        parameters: {
          'category_id': categoryId,
          'category_name': categoryName,
        },
      );
    } catch (e) {
      debugPrint('Error logging category select: $e');
    }
  }

  // Review Submission
  Future<void> logReviewSubmitted(String businessId, double rating) async {
    try {
      await _analytics?.logEvent(
        name: 'submit_review',
        parameters: {
          'business_id': businessId,
          'rating': rating,
        },
      );
    } catch (e) {
      debugPrint('Error logging review submission: $e');
    }
  }

  // Share Event
  Future<void> logShare(String businessId, String businessName) async {
    try {
      await _analytics?.logShare(
        contentType: 'business',
        itemId: businessId,
        method: 'share_button',
      );
    } catch (e) {
      debugPrint('Error logging share: $e');
    }
  }

  // Navigation Events
  Future<void> logNavigation(String from, String to) async {
    try {
      await _analytics?.logEvent(
        name: 'navigation',
        parameters: {
          'from_screen': from,
          'to_screen': to,
        },
      );
    } catch (e) {
      debugPrint('Error logging navigation: $e');
    }
  }

  // Directions/Map Event
  Future<void> logDirectionsRequest(String businessId, String businessName) async {
    try {
      await _analytics?.logEvent(
        name: 'get_directions',
        parameters: {
          'business_id': businessId,
          'business_name': businessName,
        },
      );
    } catch (e) {
      debugPrint('Error logging directions request: $e');
    }
  }

  // Claim Business Event
  Future<void> logBusinessClaimRequest(String businessId) async {
    try {
      await _analytics?.logEvent(
        name: 'claim_business',
        parameters: {
          'business_id': businessId,
        },
      );
    } catch (e) {
      debugPrint('Error logging business claim: $e');
    }
  }

  // Error Logging
  Future<void> logError(dynamic error, StackTrace? stackTrace, {String? reason}) async {
    try {
      await _crashlytics?.recordError(error, stackTrace, reason: reason);
    } catch (e) {
      debugPrint('Error logging to Crashlytics: $e');
    }
  }

  // Set User Properties
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }
}
