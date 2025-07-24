LifeLog - Daily Journal App
Setup Instructions

Clone the repository.
Install Flutter and configure it for Android/iOS.
Set up Supabase with the provided URL and anon key in main.dart.
Create a journal_entries table with columns: id, user_id, title, body, mood, created_at.
Configure Supabase RLS with: policy for select: (auth.uid() = user_id).
Run flutter pub get and then flutter run.

Schema Design Decisions

Used a single journal_entries table for simplicity.
created_at ensures date-based grouping and one-entry-per-day enforcement in the edge function.

Assumptions/Tradeoffs

Assumes Supabase edge function create-journal-entry handles one-entry-per-day logic.
Basic UI with no advanced styling for focus on functionality.

Known Limitations/Issues

No offline support.
Edge function implementation not included (to be implemented server-side).
