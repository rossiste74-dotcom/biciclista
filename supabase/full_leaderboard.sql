-- Function to get full leaderboard data for the detailed screen
-- Logic updated: Includes users with 0 activity (LEFT JOIN from profiles)

create or replace function get_full_leaderboard()
returns json
language plpgsql
security definer
as $$
declare
  active_list json;
  cartographer_list json;
  lazy_list json;
begin
  -- 1. Most Active (Il Fuggitivo)
  select json_agg(t) into active_list from (
    select 
      p.display_name as name,
      p.profile_image_url as avatar,
      coalesce(sum(r.distance), 0) as value,
      rank() over (order by coalesce(sum(r.distance), 0) desc) as rank
    from public_profiles p
    left join planned_rides r on p.user_id = r.user_id 
      and r.is_completed = true 
      and r.ride_date > (now() - interval '30 days')
    group by p.display_name, p.profile_image_url
    order by value desc
    limit 50
  ) t;

  -- 2. Il Cartografo (Tracks created)
  select json_agg(t) into cartographer_list from (
    select 
      p.display_name as name,
      p.profile_image_url as avatar,
      count(t.id) as value,
      rank() over (order by count(t.id) desc) as rank
    from public_profiles p
    left join personal_tracks t on p.user_id = t.user_id
    group by p.display_name, p.profile_image_url
    order by value desc
    limit 50
  ) t;

  -- 3. Il Turista (Laziest - Lowest distance including 0)
  select json_agg(t) into lazy_list from (
    select 
      p.display_name as name,
      p.profile_image_url as avatar,
      coalesce(sum(r.distance), 0) as value,
      rank() over (order by coalesce(sum(r.distance), 0) asc) as rank
    from public_profiles p
    left join planned_rides r on p.user_id = r.user_id
      and r.is_completed = true
      and r.ride_date > (now() - interval '30 days')
    group by p.display_name, p.profile_image_url
    order by value asc
    limit 50
  ) t;

  -- Construct JSON
  return json_build_object(
    'most_active', coalesce(active_list, '[]'::json),
    'organizers', coalesce(cartographer_list, '[]'::json),
    'laziest', coalesce(lazy_list, '[]'::json)
  );
end;
$$;
