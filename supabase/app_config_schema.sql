-- Table for application configuration and dynamic strings
create table if not exists app_config (
  key text primary key,
  value text not null,
  description text,
  group_name text, -- e.g. 'agenda', 'app', 'maintenance'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS
alter table app_config enable row level security;

-- Allow read access to everyone
create policy "Public config access"
  on app_config for select
  using (true);

-- Allow write access only to service_role (admins) - usually
-- For now, allowing authenticated users to insert might be unsafe, 
-- but assuming admin control via SQL dashboard.

-- Initial Data Seeding
insert into app_config (key, value, group_name, description) values
('app.latest_apk_url', 'https://fiukytfosrjppbmnrlmp.supabase.co/storage/v1/object/public/releases/app-release.apk', 'app', 'URL for the APK download'),
('agenda.tab_list', 'Prossime', 'agenda', 'Label for upcoming list tab'),
('agenda.tab_map', 'Mappa', 'agenda', 'Label for map tab'),
('agenda.tab_completed', 'Completate', 'agenda', 'Label for completed tab'),
('agenda.no_map_activities', 'Nessuna attività con posizione', 'agenda', 'Message when map is empty'),
('agenda.empty_title', 'Nessuna uscita programmata', 'agenda', 'Title for empty upcoming list'),
('agenda.empty_subtitle', 'Crea una nuova uscita o unisciti a una esistente!', 'agenda', 'Subtitle for empty upcoming list'),
('agenda.empty_completed_title', 'Nessuna uscita completata', 'agenda', 'Title for empty completed list'),
('agenda.empty_completed_subtitle', 'Completa la tua prima uscita per vederla qui!', 'agenda', 'Subtitle for empty completed list')
on conflict (key) do update set value = excluded.value;
