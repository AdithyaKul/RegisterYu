-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Profiles Table (extends Supabase Auth)
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  email text,
  full_name text,
  avatar_url text,
  role text default 'student' check (role in ('student', 'organizer', 'admin')),
  college_id text,
  phone text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Events Table
create table events (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  date timestamp with time zone not null,
  location text not null,
  category text not null,
  price_amount numeric default 0,
  price_currency text default 'INR',
  capacity integer default 100,
  image_url text,
  organizer_id uuid references profiles(id),
  status text default 'published' check (status in ('draft', 'published', 'cancelled', 'completed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Registrations (Tickets) Table
create table registrations (
  id uuid default uuid_generate_v4() primary key,
  event_id uuid references events(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  status text default 'active' check (status in ('active', 'checked_in', 'cancelled')),
  ticket_code text unique default substring(md5(random()::text) from 1 for 8), -- Simple unique code
  qr_data text, -- Can store a signed JWT or just the UUID
  payment_id text,
  check_in_time timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(event_id, user_id)
);

-- 4. Certificate Templates Table
create table certificate_templates (
  id uuid default uuid_generate_v4() primary key,
  event_id uuid references events(id) on delete cascade not null unique,
  template_url text not null, -- Supabase Storage URL
  config jsonb not null, -- JSON storing x, y, fontSize, etc.
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies (Row Level Security)
alter table profiles enable row level security;
alter table events enable row level security;
alter table registrations enable row level security;
alter table certificate_templates enable row level security;

-- Profiles: Public read, Self update
create policy "Public profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- Events: Public read, Organizer create/update
create policy "Events are viewable by everyone" on events for select using (true);
create policy "Organizers can insert events" on events for insert with check (auth.uid() in (select id from profiles where role in ('organizer', 'admin')));
create policy "Organizers can update own events" on events for update using (auth.uid() = organizer_id);

-- Registrations: User view own, Organizer view event's
create policy "Users can view own registrations" on registrations for select using (auth.uid() = user_id);
create policy "Organizers can view registrations for their events" on registrations for select using (
  exists (select 1 from events where id = registrations.event_id and organizer_id = auth.uid())
);
create policy "Users can register" on registrations for insert with check (auth.uid() = user_id);

-- Storage (Buckets)
-- You must create buckets: 'event-images', 'certificates' manually in dashboard
