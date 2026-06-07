create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  age integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
add column if not exists age integer;

create table if not exists public.sleep_schedules (
  user_id uuid primary key references auth.users(id) on delete cascade,
  target_sleep_time text not null default '22:00',
  target_wake_time text not null default '05:30',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_sleep_schedules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Jadwal Tidur',
  target_sleep_time text not null,
  target_wake_time text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sleep_records (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  record_date timestamptz not null,
  sleep_start timestamptz not null,
  wake_up timestamptz not null,
  duration_minutes integer not null,
  status text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.active_sleep_sessions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  sleep_start timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_music_tracks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  file_name text not null,
  storage_path text not null,
  public_url text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_music_tracks
add column if not exists id uuid;

update public.user_music_tracks
set id = gen_random_uuid()
where id is null;

alter table public.user_music_tracks
alter column id set default gen_random_uuid();

alter table public.user_music_tracks
alter column id set not null;

alter table public.user_music_tracks
drop constraint if exists user_music_tracks_pkey;

alter table public.user_music_tracks
add constraint user_music_tracks_pkey primary key (id);

insert into storage.buckets (id, name, public)
values ('sleep-music', 'sleep-music', true)
on conflict (id) do nothing;

update storage.buckets
set public = true
where id = 'sleep-music';

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create or replace function public.handle_new_user()
returns trigger
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', 'Pengguna'),
    coalesce(new.email, '')
  )
  on conflict (id) do update
    set name = excluded.name,
        email = excluded.email;

  insert into public.sleep_schedules (user_id, target_sleep_time, target_wake_time)
  values (new.id, '22:00', '05:30')
  on conflict (user_id) do nothing;

  return new;
end;
$$ language plpgsql;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_sleep_schedules_updated_at on public.sleep_schedules;
create trigger set_sleep_schedules_updated_at
before update on public.sleep_schedules
for each row execute function public.set_updated_at();

drop trigger if exists set_saved_sleep_schedules_updated_at on public.saved_sleep_schedules;
create trigger set_saved_sleep_schedules_updated_at
before update on public.saved_sleep_schedules
for each row execute function public.set_updated_at();

drop trigger if exists set_active_sleep_sessions_updated_at on public.active_sleep_sessions;
create trigger set_active_sleep_sessions_updated_at
before update on public.active_sleep_sessions
for each row execute function public.set_updated_at();

drop trigger if exists set_user_music_tracks_updated_at on public.user_music_tracks;
create trigger set_user_music_tracks_updated_at
before update on public.user_music_tracks
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.sleep_schedules enable row level security;
alter table public.saved_sleep_schedules enable row level security;
alter table public.sleep_records enable row level security;
alter table public.active_sleep_sessions enable row level security;
alter table public.user_music_tracks enable row level security;

drop policy if exists "Users can manage own profile" on public.profiles;
create policy "Users can manage own profile"
on public.profiles
for all
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can manage own sleep schedule" on public.sleep_schedules;
create policy "Users can manage own sleep schedule"
on public.sleep_schedules
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own saved sleep schedules" on public.saved_sleep_schedules;
create policy "Users can manage own saved sleep schedules"
on public.saved_sleep_schedules
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own sleep records" on public.sleep_records;
create policy "Users can manage own sleep records"
on public.sleep_records
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own active sleep session" on public.active_sleep_sessions;
create policy "Users can manage own active sleep session"
on public.active_sleep_sessions
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own music track" on public.user_music_tracks;
create policy "Users can manage own music track"
on public.user_music_tracks
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can read sleep music files" on storage.objects;
create policy "Users can read sleep music files"
on storage.objects
for select
using (bucket_id = 'sleep-music');

drop policy if exists "Users can upload own sleep music files" on storage.objects;
create policy "Users can upload own sleep music files"
on storage.objects
for insert
with check (
  bucket_id = 'sleep-music'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update own sleep music files" on storage.objects;
create policy "Users can update own sleep music files"
on storage.objects
for update
using (
  bucket_id = 'sleep-music'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'sleep-music'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can delete own sleep music files" on storage.objects;
create policy "Users can delete own sleep music files"
on storage.objects
for delete
using (
  bucket_id = 'sleep-music'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create index if not exists sleep_records_user_date_idx
on public.sleep_records (user_id, record_date desc);

create index if not exists saved_sleep_schedules_user_created_idx
on public.saved_sleep_schedules (user_id, created_at desc);

create index if not exists user_music_tracks_user_created_idx
on public.user_music_tracks (user_id, created_at desc);
