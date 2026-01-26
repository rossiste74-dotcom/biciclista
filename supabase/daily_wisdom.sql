-- Create daily_wisdom table
create table if not exists daily_wisdom (
  date date primary key,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table daily_wisdom enable row level security;

-- Policies
-- Anyone can read
create policy "Daily wisdom is viewable by everyone."
  on daily_wisdom for select
  using ( true );

-- Authenticated users (the first one of the day) can insert
create policy "Authenticated users can insert daily wisdom."
  on daily_wisdom for insert
  with check ( auth.role() = 'authenticated' );
