-- RBAC & Team Management Migration

-- 1. Create Event Assignments Table
create table if not exists event_assignments (
  id uuid default uuid_generate_v4() primary key,
  event_id uuid references events(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  role text default 'scanner', -- 'scanner', 'manager'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(event_id, user_id)
);

alter table event_assignments enable row level security;

-- 2. Update Event Policies for Access Control
-- Drop old public policy if exists (might fail if name differs, ignore if so)
drop policy if exists "Events are viewable by everyone" on events;

-- A. Published events are public (for Guests/Everyone)
create policy "Public events are viewable by everyone" on events for select using (status = 'published');

-- B. Staff can view Draft/Private events IF assigned
create policy "Staff can view assigned events" on events for select using (
  exists (
    select 1 from event_assignments 
    where event_assignments.event_id = events.id  
    and event_assignments.user_id = auth.uid()
  )
);

-- C. Admins/Organizers can view ALL events (including Drafts)
create policy "Admins/Organizers can view all events" on events for select using (
  exists (
    select 1 from profiles 
    where profiles.id = auth.uid() 
    and profiles.role in ('admin', 'organizer')
  )
);

-- 3. Assignments Table Policies
create policy "Admins manage assignments" on event_assignments for all using (
  exists (
    select 1 from profiles 
    where profiles.id = auth.uid() 
    and profiles.role in ('admin', 'organizer')
  )
);

create policy "Users view own assignments" on event_assignments for select using (
  user_id = auth.uid()
);

-- 4. Ensure Profiles Role Column exists (from schema.sql it does)
-- Updates profiles to allow admins to manage others
create policy "Admins can manage profiles" on profiles for all using (
  exists (
    select 1 from profiles as my_profile
    where my_profile.id = auth.uid() 
    and my_profile.role in ('admin', 'organizer')
  )
);





















































