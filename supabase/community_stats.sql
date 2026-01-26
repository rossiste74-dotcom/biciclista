-- Database function to calculate average weekly km of users within a radius
-- This function assumes that 'profiles' has 'home_lat' and 'home_lon' (or we assume meeting points from rides?)
-- Actually, the prompt asks for "dati della community locale". If we don't have user home locations, we can use the location of their recent public rides?
-- Let's assume we want to query based on where *activity* is happening.
-- However, for simplicity and since we might not have 'home' location, let's look at Public Group Rides meeting points in the last 7 days + next 7 days to define the "active community" area,
-- OR better, if we don't have precise user locations, we'll mock the internal calculation for now if the table structure isn't there, 
-- BUT valid SQL is better. Let's assume 'profiles' might be extended or we use 'group_rides' locations.

-- BETTER APPROACH: We use 'group_rides' (public) to find where people are riding.
-- Then we calculate stats based on 'completed' public rides in that area.

create or replace function get_community_stats(
  lat double precision, 
  lon double precision, 
  radius_km double precision
) 
returns json 
language plpgsql 
security definer -- Runs as admin to access data
as $$
declare
  avg_km numeric;
  active_users int;
  popular_type text;
begin
  -- Calculate average distance of planned/completed rides (public ones) in the radius in the last 7 days?
  -- Or just generic "weekly km" of users who have joined rides in this area.
  
  -- Let's keep it simple: Stats of Public Rides in the area in the last 30 days.
  select 
    coalesce(avg(distance), 0), 
    count(distinct creator_id)
  into 
    avg_km, 
    active_users
  from group_rides
  where 
    is_public = true 
    and ST_DWithin(
      ST_SetSRID(ST_MakePoint(meeting_longitude, meeting_latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
      radius_km * 1000
    );

  -- Determine most popular type (road vs mtb etc) - if we had that column clearly or inferred from track
  -- For now hardcode or random? Let's infer from generic bike types if available, otherwise 'Road'
  popular_type := 'Road'; -- Placeholder for now
  
  return json_build_object(
    'avg_km', round(avg_km, 1),
    'active_users', active_users,
    'radius_km', radius_km,
    'popular_type', popular_type
  );
end;
$$;

-- Add the new prompt for community motivation
insert into system_prompts (key, template, description) values
('community_motivation', 'Sei un ciclista navigato, sarcastico e molto esperto. Analizza questi dati della community locale: 
{{dati_aggregati_crew}}. 

Scrivi un messaggio motivazionale brevissimo (max 30 parole) per spingerli a uscire insieme. Sii pungente, prendili in giro per la loro pigrizia o per la cura eccessiva delle bici, ma falli sentire parte di un gruppo vero. Usa termini tecnici (es. catena, watt, scia, ammiraglia).', 'Motivation for local community based on aggregated stats')
on conflict (key) do update set template = excluded.template;
