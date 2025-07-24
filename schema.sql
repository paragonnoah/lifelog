
---

### 📄 `schema.sql`

```sql
-- Create 'entries' table
create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  title text,
  body text,
  mood integer check (mood between 1 and 5),
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable Row Level Security (RLS)
alter table public.entries enable row level security;

-- Policy: Allow users to insert their own entries
create policy "Users can insert their own entries"
  on public.entries for insert
  with check (auth.uid() = user_id);

-- Policy: Allow users to view their own entries
create policy "Users can view their own entries"
  on public.entries for select
  using (auth.uid() = user_id);
