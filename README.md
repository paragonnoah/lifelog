# Mood Journal App (Flutter + Supabase) 🌟

A **mood journaling app** built with Flutter and Supabase, allowing users to log in, write one mood entry per day, and rate their mood on a scale of 1–5.

---

## 📦 Features

- ✍️ **Daily Journaling**: Write one journal entry per day, enforced by a Supabase edge function.
- 😊 **Mood Tracking**: Use a mood slider to rate your emotional state (1 = bad, 5 = excellent).
- 🔐 **Secure Authentication**: Email/password login powered by Supabase Auth.
- ☁️ **Cloud Storage**: Store entries in Supabase Postgres with Row-Level Security (RLS) for privacy.
- 📱 **Elegant UI**: Beautiful, user-friendly interface with Material Design principles.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.x or later)
- **Dart SDK**
- **Git**
- **Supabase Account** (sign up at [supabase.com](https://supabase.com))

---

### 🔧 Setup Instructions

#### 1. Clone the Repository
```bash
git clone https://github.com/paragonnoah/lifelog.git
cd lifelog
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Set Up Supabase Project
1. Visit [supabase.com](https://supabase.com) and create a new project.
2. In the Supabase dashboard, go to the **SQL Editor** and run the following to create the `journal_entries` table with Row-Level Security (RLS):
```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
  user_id UUID REFERENCES auth.users(id),
  title TEXT,
  body TEXT,
  mood INTEGER CHECK (mood >= 1 AND mood <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can insert their own entries" ON journal_entries
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own entries" ON journal_entries
  FOR SELECT USING (auth.uid() = user_id);
```
> **Note**: If the table already exists, drop it first using `DROP TABLE journal_entries;` before recreating.

#### 4. Configure Edge Function
1. In the Supabase dashboard, navigate to **Edge Functions** > `super-function`.
2. Replace the existing code with the following and deploy:
```typescript
// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface ReqPayload {
  user_id: string;
  title: string;
  body: string;
  mood: number;
}

Deno.serve(async (req: Request) => {
  let payload: ReqPayload;
  try {
    payload = await req.json();
  } catch (e) {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON input' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }
  const { user_id, title, body, mood } = payload;

  // Initialize Supabase client with environment variables
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Check for existing entry today
  const { data: existing } = await supabase
    .from('journal_entries')
    .select('id')
    .eq('user_id', user_id)
    .gte('created_at', new Date().toISOString().split('T')[0])
    .lte('created_at', new Date().toISOString().split('T')[0] + ' 23:59:59');

  if (existing && existing.length > 0) {
    return new Response(
      JSON.stringify({ error: 'One entry per day limit reached' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const { error } = await supabase
    .from('journal_entries')
    .insert({ user_id, title, body, mood });

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  return new Response(
    JSON.stringify({ success: true }),
    { status: 200, headers: { 'Content-Type': 'application/json' } }
  );
});
```
3. In **Settings > Environment Variables**, add:
   - `SUPABASE_URL`: Your project URL (e.g., `https://hmepjhizsstnqqeaarpy.supabase.co`).
   - `SUPABASE_SERVICE_ROLE_KEY`: Your project’s service role key (found in **Settings > API**).

#### 5. Configure Flutter App
1. Open `lib/main.dart` and update the Supabase initialization with your credentials:
```dart
await Supabase.initialize(
  url: 'https://YOUR_PROJECT.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
);
```
   Replace `YOUR_PROJECT` and `YOUR_ANON_KEY` with values from your Supabase project settings.

#### 6. Run the App
```bash
flutter run
```
Log in with a test user (e.g., `paragonnoah@gmail.com` with your set password).

---

## 🧠 Schema Design Decisions

- **Table Structure**:
  - `id` (UUID): Unique identifier for each entry.
  - `user_id` (UUID): Links entries to users via `auth.users`.
  - `title` (TEXT): Short title for the journal entry.
  - `body` (TEXT): Main content of the journal entry.
  - `mood` (INTEGER): Mood rating (1–5), validated with a CHECK constraint.
  - `created_at` (TIMESTAMP): Auto-set to the entry’s creation time.
- **RLS Policies**: Restrict access to a user’s own entries for enhanced privacy and security.
- **One-Entry-Per-Day**: Enforced via edge function logic, offering flexibility for future edits without rigid database constraints.

---

## 📌 Assumptions & Tradeoffs

- ✅ **Authentication Required**: All actions require a logged-in user, leveraging Supabase Auth.
- ❌ **No Entry Editing**: Focuses on creation only to keep the MVP simple.
- 👁️ **Read-Only Detail View**: Entries are viewable but not editable, aligning with the journaling focus.
- 🎚️ **Mood Range**: Uses a simple 1–5 integer scale, which may limit nuanced mood tracking.
- ⚖️ **Tradeoff**: Edge function for one-entry-per-day limit avoids database constraints, enabling easier logic adjustments but requiring server-side execution.

---

## ⚠️ Known Limitations

- ❌ **No Offline Support**: Requires an internet connection to sync with Supabase.
- ❌ **Limited Auth Options**: Only email/password; no Google Sign-In or password reset in this version.
- ❌ **No Past Entry Management**: Users cannot view or edit previous entries yet.
- ⚙️ **Manual Schema Setup**: RLS policies and table creation must be applied manually in the SQL Editor.
- 🐛 **Edge Function Issues**: `supabaseClient` injection failed, requiring manual initialization with environment variables, which may need further testing.

---

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── constants.dart         # Shared constants like colors, paddings
├── widgets/               # Reusable UI components
│   └── mood_picker.dart   # Emoji mood selector
├── screens/               # Pages/screens of the app
│   ├── auth_gate.dart     # Checks user auth status
│   ├── login_page.dart    # Supabase login
│   ├── home_page.dart     # List of entries
│   ├── create_entry.dart  # Add mood + journal text
│   ├── entry_detail.dart  # Full view of a single journal entry

```

---

## 📜 License

**MIT License**. Feel free to fork, improve, and share!
