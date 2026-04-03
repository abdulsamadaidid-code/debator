create extension if not exists pgcrypto;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'debate_side') then
    create type public.debate_side as enum ('for', 'against', 'undecided');
  end if;

  if not exists (select 1 from pg_type where typname = 'debate_status') then
    create type public.debate_status as enum ('live', 'scheduled', 'closed');
  end if;

  if not exists (select 1 from pg_type where typname = 'debate_format') then
    create type public.debate_format as enum ('quickfire', 'structured', 'tribunal');
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_handle text;
  candidate_handle text;
  suffix integer := 0;
begin
  base_handle := lower(
    coalesce(
      new.raw_user_meta_data ->> 'preferred_username',
      new.raw_user_meta_data ->> 'user_name',
      split_part(coalesce(new.email, ''), '@', 1),
      'debator'
    )
  );
  base_handle := regexp_replace(base_handle, '[^a-z0-9_]+', '_', 'g');
  base_handle := trim(both '_' from base_handle);

  if length(base_handle) < 3 then
    base_handle := 'debator';
  end if;

  candidate_handle := '@' || left(base_handle, 31);

  while exists (select 1 from public.profiles where handle = candidate_handle) loop
    suffix := suffix + 1;
    candidate_handle :=
      '@' || left(base_handle, greatest(1, 31 - length(suffix::text) - 1)) || '_' || suffix;
  end loop;

  insert into public.profiles (
    id,
    handle,
    display_name
  ) values (
    new.id,
    candidate_handle,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      nullif(new.raw_user_meta_data ->> 'name', ''),
      nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
      'Debator'
    )
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  handle text not null unique check (handle ~ '^@[a-z0-9_]{3,32}$'),
  display_name text not null check (char_length(display_name) between 1 and 80),
  avatar_url text,
  rating integer not null default 1200 check (rating between 0 and 5000),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.topics (
  id text primary key,
  name text not null unique check (char_length(name) between 1 and 64),
  tagline text not null check (char_length(tagline) between 1 and 120),
  description text not null check (char_length(description) between 1 and 400),
  sort_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.debates (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles (id) on delete restrict,
  topic_id text not null references public.topics (id) on delete restrict,
  title text not null check (char_length(title) between 3 and 120),
  proposition text not null check (char_length(proposition) between 12 and 280),
  overview text not null check (char_length(overview) between 12 and 1000),
  status public.debate_status not null default 'live',
  format public.debate_format not null default 'structured',
  judging_prompt text not null check (char_length(judging_prompt) between 12 and 1000),
  watching_now integer not null default 0 check (watching_now >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.debate_participants (
  id uuid primary key default gen_random_uuid(),
  debate_id uuid not null references public.debates (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  side public.debate_side not null default 'undecided',
  rating_snapshot integer not null default 1200 check (rating_snapshot between 0 and 5000),
  joined_at timestamptz not null default timezone('utc', now()),
  unique (debate_id, profile_id)
);

create table if not exists public.debate_rounds (
  id uuid primary key default gen_random_uuid(),
  debate_id uuid not null references public.debates (id) on delete cascade,
  speaker_profile_id uuid not null references public.profiles (id) on delete cascade,
  side public.debate_side not null,
  label text not null check (char_length(label) between 1 and 60),
  summary text not null check (char_length(summary) between 12 and 4000),
  evidence_note text not null default '',
  round_order integer not null check (round_order >= 1),
  created_at timestamptz not null default timezone('utc', now()),
  unique (debate_id, round_order)
);

create table if not exists public.debate_votes (
  id uuid primary key default gen_random_uuid(),
  debate_id uuid not null references public.debates (id) on delete cascade,
  voter_id uuid not null references public.profiles (id) on delete cascade,
  side public.debate_side not null check (side in ('for', 'against')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (debate_id, voter_id)
);

create index if not exists topics_sort_order_idx
  on public.topics (sort_order, name);

create index if not exists debates_topic_created_at_idx
  on public.debates (topic_id, created_at desc);

create index if not exists debates_status_created_at_idx
  on public.debates (status, created_at desc);

create index if not exists debate_participants_debate_idx
  on public.debate_participants (debate_id);

create index if not exists debate_participants_profile_idx
  on public.debate_participants (profile_id);

create index if not exists debate_rounds_debate_order_idx
  on public.debate_rounds (debate_id, round_order);

create index if not exists debate_votes_debate_side_idx
  on public.debate_votes (debate_id, side);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute procedure public.set_updated_at();

drop trigger if exists debates_set_updated_at on public.debates;
create trigger debates_set_updated_at
before update on public.debates
for each row
execute procedure public.set_updated_at();

drop trigger if exists debate_votes_set_updated_at on public.debate_votes;
create trigger debate_votes_set_updated_at
before update on public.debate_votes
for each row
execute procedure public.set_updated_at();

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.topics enable row level security;
alter table public.debates enable row level security;
alter table public.debate_participants enable row level security;
alter table public.debate_rounds enable row level security;
alter table public.debate_votes enable row level security;

create policy "Profiles are viewable by everyone"
on public.profiles
for select
using (true);

create policy "Users can update their own profile"
on public.profiles
for update
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy "Topics are viewable by everyone"
on public.topics
for select
using (true);

create policy "Debates are viewable by everyone"
on public.debates
for select
using (true);

create policy "Authenticated users can create debates"
on public.debates
for insert
to authenticated
with check ((select auth.uid()) = created_by);

create policy "Debate creators can update their debates"
on public.debates
for update
to authenticated
using ((select auth.uid()) = created_by)
with check ((select auth.uid()) = created_by);

create policy "Participants are viewable by everyone"
on public.debate_participants
for select
using (true);

create policy "Users can join debates as themselves"
on public.debate_participants
for insert
to authenticated
with check ((select auth.uid()) = profile_id);

create policy "Users can change their own debate side"
on public.debate_participants
for update
to authenticated
using ((select auth.uid()) = profile_id)
with check ((select auth.uid()) = profile_id);

create policy "Rounds are viewable by everyone"
on public.debate_rounds
for select
using (true);

create policy "Participants can add their own rounds"
on public.debate_rounds
for insert
to authenticated
with check (
  (select auth.uid()) = speaker_profile_id
  and exists (
    select 1
    from public.debate_participants participant
    where participant.debate_id = debate_rounds.debate_id
      and participant.profile_id = (select auth.uid())
  )
);

create policy "Votes are viewable by everyone"
on public.debate_votes
for select
using (true);

create policy "Users can vote as themselves"
on public.debate_votes
for insert
to authenticated
with check ((select auth.uid()) = voter_id);

create policy "Users can update their own vote"
on public.debate_votes
for update
to authenticated
using ((select auth.uid()) = voter_id)
with check ((select auth.uid()) = voter_id);

alter publication supabase_realtime add table public.debates;
alter publication supabase_realtime add table public.debate_participants;
alter publication supabase_realtime add table public.debate_rounds;
alter publication supabase_realtime add table public.debate_votes;
