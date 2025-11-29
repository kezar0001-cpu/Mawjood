# Supabase Configuration Guide for Mawjood

This guide explains how to properly configure Supabase credentials for the Mawjood Flutter app to ensure all API calls use absolute URLs (not relative paths).

## Why This Matters

When deploying Flutter Web apps to GitHub Pages or other static hosting platforms, relative API URLs will fail because they resolve to the hosting domain (e.g., `https://yourusername.github.io/rest/v1/categories`) instead of your Supabase backend.

This configuration ensures all API calls use the full Supabase URL format:
```
https://your-project-id.supabase.co/rest/v1/table_name
```

## Configuration Steps

### 1. Get Your Supabase Credentials

1. Go to your Supabase project dashboard: https://app.supabase.com
2. Select your project
3. Navigate to **Settings** → **API**
4. Copy the following values:
   - **Project URL** (e.g., `https://abcdefghijk.supabase.co`)
   - **anon public** key (the public API key, safe for client-side use)

### 2. Update Local Configuration

Edit the file `lib/config/env_config.dart` and replace the placeholder values:

```dart
class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co', // ← Replace with your actual URL
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-public-key', // ← Replace with your actual anon key
  );
}
```

**Important:**
- The `supabaseUrl` MUST be an absolute URL starting with `https://`
- The `supabaseUrl` MUST contain `.supabase.co`
- Never use relative paths like `/rest/v1` or `rest/v1`
- The anon key is safe to commit in client code (it's meant to be public)

### 3. Configure GitHub Actions (for CI/CD)

If you're using GitHub Actions to build and deploy your app, add secrets to your repository:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:
   - Name: `SUPABASE_URL`
     Value: `https://your-project-id.supabase.co`
   - Name: `SUPABASE_ANON_KEY`
     Value: Your anon public key

The workflows in `.github/workflows/flutter-web.yml` and `.github/workflows/flutter-apk.yml` are already configured to use these secrets via `--dart-define` flags.

### 4. Local Development Builds

For local development, you can either:

**Option A: Use the default values from env_config.dart**
```bash
flutter run
```

**Option B: Pass values at build time**
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 5. Production Builds

For production builds (web or mobile), pass the credentials at compile time:

**Web Build:**
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

**Android APK:**
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

**iOS:**
```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Verification

To verify your configuration is correct, check the following:

1. **Build succeeds without errors:** The app should initialize Supabase successfully
2. **No validation errors:** The `EnvConfig.configurationError` should return `null`
3. **API calls use absolute URLs:** All network requests should go to `https://your-project-id.supabase.co/rest/v1/...`
4. **Web build works on GitHub Pages:** The deployed web app should successfully fetch data from Supabase

## Troubleshooting

### Error: "Supabase configuration error: Supabase URL has not been configured"

**Cause:** The default placeholder values in `env_config.dart` haven't been replaced.

**Solution:** Update `lib/config/env_config.dart` with your actual Supabase URL and anon key.

### Error: API calls return 404 or fail on web build

**Cause:** The app is trying to make API calls to relative URLs like `/rest/v1/categories`, which resolve to your GitHub Pages domain instead of Supabase.

**Solution:** Ensure you've:
1. Updated `env_config.dart` with absolute URLs
2. Added GitHub secrets for automated builds
3. Rebuilt the app with the correct configuration

### Error: "Invalid Supabase URL"

**Cause:** The URL doesn't meet validation requirements.

**Solution:** Ensure the URL:
- Starts with `https://`
- Contains `.supabase.co`
- Is a complete URL (e.g., `https://abcdefg.supabase.co`)

## Security Notes

- ✅ The **anon/public key** is safe to use in client-side code and can be committed to your repository
- ✅ The **Project URL** is public information and can be committed
- ❌ **Never** commit your **service role key** (used only in backend/admin code)
- ✅ Row Level Security (RLS) policies on your Supabase tables protect your data, not the anon key

## Additional Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Environment Variables](https://docs.flutter.dev/deployment/flavors)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
