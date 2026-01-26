-- Function to get sarcastic leaderboard data (Dashboard Card)
-- Logic updated:
-- 1. Fuggitivo: Sum of distance from ALL completed rides (planned_rides) in last 30 days. Includes 0km users.
-- 2. Cartografo: Count of created tracks (personal_tracks) total. Includes 0 tracks users.
-- 3. Turista: Lowest distance in last 30 days (0km users included).

create or replace function get_sarcastic_leaderboard()
returns json
language plpgsql
security definer
as $$
declare
  active_winner record;
  cartographer_winner record;
  lazy_winner record;
begin
  -- 1. Most Active (Il Fuggitivo)
  -- Left join profiles -> rides to include everyone
  select 
    p.display_name,
    p.profile_image_url,
    coalesce(sum(r.distance), 0) as score
  into active_winner
  from public_profiles p
  left join planned_rides r on p.user_id = r.user_id 
    and r.is_completed = true 
    and r.ride_date > (now() - interval '30 days')
  group by p.display_name, p.profile_image_url
  order by score desc
  limit 1;

  -- 2. Best Organizer -> The Cartographer (Il Cartografo)
  select 
    p.display_name, 
    p.profile_image_url,
    count(t.id) as score
  into cartographer_winner
  from public_profiles p
  left join personal_tracks t on p.user_id = t.user_id
  group by p.display_name, p.profile_image_url
  order by score desc
  limit 1;

  -- 3. Laziest (Il Turista)
  -- Users with 0km will be at the top (lowest score)
  select 
    p.display_name, 
    p.profile_image_url,
    coalesce(sum(r.distance), 0) as score
  into lazy_winner
  from public_profiles p
  left join planned_rides r on p.user_id = r.user_id
    and r.is_completed = true
    and r.ride_date > (now() - interval '30 days')
  group by p.display_name, p.profile_image_url
  order by score asc
  limit 1;

  -- Construct JSON
  return json_build_object(
    'most_active', json_build_object(
      'name', coalesce(active_winner.display_name, 'Nessuno'),
      'avatar', active_winner.profile_image_url,
      'value', coalesce(active_winner.score, 0),
      'key', 'most_active'
    ),
    'organizer', json_build_object(
      'name', coalesce(cartographer_winner.display_name, 'Nessuno'),
      'avatar', cartographer_winner.profile_image_url,
      'value', coalesce(cartographer_winner.score, 0),
      'key', 'cartographer'
    ),
    'laziest', json_build_object(
      'name', coalesce(lazy_winner.display_name, 'Nessuno'),
      'avatar', lazy_winner.profile_image_url,
      'value', coalesce(lazy_winner.score, 0),
      'key', 'laziest'
    )
  );
end;
$$;
