-- Create tables for dashboard messages

-- 1. Weather Messages
create table if not exists weather_messages (
  id uuid default gen_random_uuid() primary key,
  condition_key text not null unique, -- rain, wind_high, hot, perfect, good, cool, cold
  message_text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Stats Messages
create table if not exists stats_messages (
  id uuid default gen_random_uuid() primary key,
  condition_key text not null unique, -- km_0_50, km_50_100, km_100_150, km_150_200, km_200_plus
  message_text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Maintenance Messages
create table if not exists maintenance_messages (
  id uuid default gen_random_uuid() primary key,
  condition_key text not null unique, -- all_ok, critical, warning, attention
  message_text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Challenge Messages
create table if not exists challenge_messages (
  id uuid default gen_random_uuid() primary key,
  condition_key text not null unique, -- start, quarter, half, quarter_left, completed
  message_text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table weather_messages enable row level security;
alter table stats_messages enable row level security;
alter table maintenance_messages enable row level security;
alter table challenge_messages enable row level security;

-- Policies: viewable by everyone, insert by authenticated/admin only (simplifying to authenticated for now)
create policy "Weather messages viewable by everyone" on weather_messages for select using (true);
create policy "Stats messages viewable by everyone" on stats_messages for select using (true);
create policy "Maintenance messages viewable by everyone" on maintenance_messages for select using (true);
create policy "Challenge messages viewable by everyone" on challenge_messages for select using (true);

-- Seed Data (from current hardcoded strings)

-- Weather
insert into weather_messages (condition_key, message_text) values
('rain', 'Piove? E allora? Non sei mica di zucchero! I veri ciclisti escono anche con l''acquazzone.'),
('wind_high', 'Vento contrario in andata significa vento a favore al ritorno. Pensa positivo (o fai un giro ad anello).'),
('hot', 'Fa caldo! Parti presto la mattina o la sera, che a mezzogiorno ti sciogli sull''asfalto.'),
('perfect', 'Che aspetti? Il meteo è perfetto, le gambe si muovono da sole!'),
('good', 'Temperature ideali per pedalare. Né troppo caldo né troppo freddo, solo scuse non accettate.'),
('cool', 'Fa freschetto, ma con l''abbigliamento giusto vai benissimo. Copri le estremità e parti!'),
('cold', 'Fa freddo da lupi. Copriti bene o fai un giro corto, che poi ti chiamano ghiacciolo.')
on conflict (condition_key) do nothing;

-- Stats
insert into stats_messages (condition_key, message_text) values
('km_0_50', '50km in una settimana? I miei nonni facevano di più per andare a prendere il pane!'),
('km_50_100', 'Niente male, ma non è che stai preparando il Giro d''Italia...'),
('km_100_150', 'Adesso sì che si ragiona! Continua così e tra un anno ti sponsorizza la pasta.'),
('km_150_200', 'Bravo! Anche se probabilmente hai trascurato famiglia e lavoro per questi km.'),
('km_200_plus', 'Ma tu vivi in bici o cosa? Rispetta anche il divano ogni tanto!')
on conflict (condition_key) do nothing;

-- Maintenance
insert into maintenance_messages (condition_key, message_text) values
('all_ok', 'Per una volta la bici è in ordine. Adesso non hai più scuse per non uscire!'),
('critical', 'Il limite è superato! Cambia subito quel componente o preparati a camminare.'),
('warning', 'grida aiuto! Fra poco si rompe e ti lascia a piedi... anzi, a pedali.'),
('attention', 'richiede attenzione. Non aspettare l''ultimo momento, che poi ti costa il doppio!'),
('notice', 'ha visto giorni migliori. Cambialo prima di ritrovarti con una sorpresa in salita.')
on conflict (condition_key) do nothing;

-- Challenge
insert into challenge_messages (condition_key, message_text) values
('start', 'Ancora niente? La settimana fugge, muoviti!'),
('quarter', 'Appena iniziato! Dai che la strada è ancora lunga.'),
('half', 'Un quarto fatto. Continua così, ma senza mollare adesso!'),
('quarter_left', 'A metà! Adesso non mollare proprio sul più bello.'),
('almost_there', 'Quasi arrivato! Manca poco, stringi i denti!'),
('completed', 'Complimenti! Vedi che quando ti impegni?')
on conflict (condition_key) do nothing;
