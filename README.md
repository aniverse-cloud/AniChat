# AnChat - Setup Guide

Welcome to **AnChat** ⚡! This modern, high-performance chat application is built with Flutter and Supabase.

## 🚀 Getting Started

To get the app fully functional, follow these steps:

### 1. Supabase Backend Setup
1. Create a free project at [supabase.com](https://supabase.com).
2. In your Supabase dashboard, go to **Project Settings > API**.
3. Copy your **Project URL** and **anon public key**.
4. Open `lib/core/supabase_config.dart` and paste them into the `url` and `anonKey` variables.
5. In the **Database** section, create a `messages` table with the following columns:
   - `id` (uuid, default: gen_random_uuid())
   - `sender_id` (uuid)
   - `receiver_id` (uuid)
   - `text` (text)
   - `created_at` (timestamp with time zone, default: now())

### 2. Google Sign-In (Optional)
If you wish to activate Google Sign-In:
1. Follow the [official FlutterFire documentation](https://firebase.google.com/docs/auth/flutter/google-signin) to set up your Android and Web clients in the Google Cloud Console.
2. Update the `google_sign_in` configuration in the app.

### 3. AI Service (Optional)
The Customer Service AI currently uses a simulated logic. To connect it to a real LLM:
1. Get an API key from OpenAI (ChatGPT) or Google (Gemini).
2. Implement the API call in `lib/features/ai_customer_service/presentation/ai_service_screen.dart`.

## 🛠 Features
- **Modern UI**: iOS-style Cupertino design with translucent bars and clean typography.
- **Lightning Fast**: Built with Bolt's performance philosophy, using Riverpod for state management and Hive for instant offline caching.
- **AI Recovery**: A smart customer service interface that can verify account ownership via security questions.
- **Admin Power**: Hidden admin panel for moderation and admin link generation.

## 📦 Running the App
```bash
flutter run
```
