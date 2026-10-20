-- NORTH KNOWLEDGE: run this in Supabase SQL Editor for a NEW project.
create table if not exists public.knowledge_articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'أخرى',
  description text not null,
  body text not null,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.knowledge_articles enable row level security;
alter table public.admins enable row level security;

-- Admin can read their own admin membership.
create policy "Admins can read their own membership"
on public.admins for select to authenticated
using (user_id = auth.uid());

-- Everyone can read published articles only.
create policy "Public can read published articles"
on public.knowledge_articles for select to anon, authenticated
using (published = true);

-- Admin members can read all articles, including drafts.
create policy "Admins can read all articles"
on public.knowledge_articles for select to authenticated
using (exists (select 1 from public.admins where admins.user_id = auth.uid()));

create policy "Admins can insert articles"
on public.knowledge_articles for insert to authenticated
with check (exists (select 1 from public.admins where admins.user_id = auth.uid()));

create policy "Admins can update articles"
on public.knowledge_articles for update to authenticated
using (exists (select 1 from public.admins where admins.user_id = auth.uid()))
with check (exists (select 1 from public.admins where admins.user_id = auth.uid()));

create policy "Admins can delete articles"
on public.knowledge_articles for delete to authenticated
using (exists (select 1 from public.admins where admins.user_id = auth.uid()));

-- After creating your admin account in Authentication, add its user UUID:
-- insert into public.admins (user_id) values ('PASTE_AUTH_USER_UUID_HERE');
-- Never place the service_role key in HTML or expose it to visitors.
