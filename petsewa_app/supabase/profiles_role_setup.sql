-- ============================================================================
-- PetSewa — user role management setup
-- Run this once in the Supabase Dashboard -> SQL Editor.
--
-- Creates a `profiles` table that stores each user's role
-- ('customer' | 'provider') in the database, keeps it in sync with the role
-- chosen at sign-up (auth user metadata), and protects it with RLS.
-- The Flutter app reads/writes this table via AuthService.resolveIsProvider()
-- and AuthService.persistUserRole().
-- ============================================================================

-- 1. Profiles table -----------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  full_name text,
  role text not null default 'customer' check (role in ('customer', 'provider')),
  is_provider boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. Row Level Security -------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 3. Auto-create a profile row (with the chosen role) on sign-up --------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role, is_provider)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'customer'),
    coalesce((new.raw_user_meta_data ->> 'is_provider')::boolean, false)
  )
  on conflict (id) do update
    set email       = excluded.email,
        full_name   = excluded.full_name,
        role        = excluded.role,
        is_provider = excluded.is_provider,
        updated_at  = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4. Backfill profiles for already-existing users ------------------------------
insert into public.profiles (id, email, full_name, role, is_provider)
select
  u.id,
  u.email,
  coalesce(u.raw_user_meta_data ->> 'full_name', ''),
  coalesce(u.raw_user_meta_data ->> 'role', 'customer'),
  coalesce((u.raw_user_meta_data ->> 'is_provider')::boolean, false)
from auth.users u
on conflict (id) do nothing;

-- 5. Repair accounts that were wrongly converted to 'customer' ----------------
-- If a user registered as a provider but their metadata was overwritten by the
-- old login bug, restore the provider role for every user that has a row in
-- the `providers` table (idempotent — safe to re-run):

update auth.users
set raw_user_meta_data = raw_user_meta_data
  || jsonb_build_object('role', 'provider', 'is_provider', true)
where id in (select user_id from public.providers);

update public.profiles
set role = 'provider', is_provider = true, updated_at = now()
where id in (select user_id from public.providers);

-- NOTE: a provider account that never submitted the verification form has no
-- row in `providers`, so it cannot be auto-detected. Repair such an account
-- manually by replacing the e-mail below and running:
--
-- update auth.users
-- set raw_user_meta_data = raw_user_meta_data
--   || jsonb_build_object('role', 'provider', 'is_provider', true)
-- where email = 'vendor@example.com';
--
-- update public.profiles
-- set role = 'provider', is_provider = true, updated_at = now()
-- where id = (select id from auth.users where email = 'vendor@example.com');
