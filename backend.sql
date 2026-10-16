-- =============================================================================
--  SIR ROHAIL AHMED · Accounting · Supabase backend for portal.html + admin.html
--  Built by Nexlyr Solutions.
--
--  HOW TO RUN
--   1. supabase.com → New project (Singapore or Mumbai is closest to Karachi).
--   2. SQL Editor → New query → paste this whole file → Run. Safe to run again.
--   3. Authentication → Users → Add user → the admin email + a strong password.
--   4. Put that email in the line marked  >>> ADMIN EMAIL <<<  below and run the
--      file again (or just that INSERT).
--   5. Project Settings → API → copy the Project URL and the anon / publishable
--      key into config.js. NEVER the service_role / secret key.
--   6. In config.js set PORTAL_PREVIEW: false.
--
--  WHAT IS PUBLIC
--   Row level security is on for every table and nothing can be read with the
--   public key. A visitor can only: send the enrolment form, read the list of
--   published lectures (video links only for lectures marked free), and call the
--   student sign-in functions below. Everything else needs the admin login.
-- =============================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------- settings
create or replace function public.max_devices() returns int
language sql immutable as $$ select 2 $$;      -- keep in step with config.js MAX_DEVICES

-- ---------------------------------------------------------------- tables
create table if not exists public.admins (
  email      text primary key,
  created_at timestamptz not null default now()
);

create sequence if not exists public.student_no start 1001;

create table if not exists public.students (
  id            text primary key,
  name          text not null check (char_length(name) between 1 and 80),
  level         text not null check (level in ('7707', '9706-AS', '9706-A2')),
  phone         text check (phone is null or char_length(phone) <= 25),
  code_hash     text not null,
  active        boolean not null default true,
  expires_at    timestamptz,
  fails         int not null default 0,
  locked_until  timestamptz,
  last_login    timestamptz,
  created_at    timestamptz not null default now()
);

create table if not exists public.sessions (
  token       uuid primary key default gen_random_uuid(),
  student_id  text not null references public.students(id) on delete cascade,
  device      text not null,
  label       text,
  created_at  timestamptz not null default now(),
  last_seen   timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '30 days'
);
create index if not exists sessions_student on public.sessions(student_id);

create table if not exists public.lectures (
  id          bigint generated always as identity primary key,
  level       text not null default 'all' check (level in ('all', '7707', '9706-AS', '9706-A2')),
  topic       text check (topic is null or char_length(topic) <= 10),   -- syllabus number, e.g. 3.3
  n           int  not null default 1,
  title       text not null check (char_length(title) between 1 and 160),
  kind        text not null default 'lecture' check (kind in ('lecture', 'workshop', 'solution')),
  minutes     int  check (minutes is null or minutes between 0 and 600),
  video       text,                        -- YouTube link (unlisted is fine) or a direct .mp4 URL
  notes       text,                        -- link to a notes PDF
  free        boolean not null default false,
  published   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists lectures_order on public.lectures(level, topic, n);

create table if not exists public.progress (
  student_id  text   not null references public.students(id) on delete cascade,
  lecture_id  bigint not null references public.lectures(id) on delete cascade,
  done_at     timestamptz not null default now(),
  primary key (student_id, lecture_id)
);

create table if not exists public.announcements (
  id          bigint generated always as identity primary key,
  level       text not null default 'all' check (level in ('all', '7707', '9706-AS', '9706-A2')),
  title       text not null check (char_length(title) between 1 and 140),
  body        text check (body is null or char_length(body) <= 2000),
  pinned      boolean not null default false,
  published   boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists public.marks (
  id          bigint generated always as identity primary key,
  student_id  text not null references public.students(id) on delete cascade,
  title       text not null check (char_length(title) between 1 and 140),
  paper       text check (paper is null or char_length(paper) <= 10),
  score       numeric not null check (score >= 0),
  out_of      numeric not null check (out_of > 0),
  taken_on    date not null default current_date,
  remarks     text check (remarks is null or char_length(remarks) <= 400),
  created_at  timestamptz not null default now()
);
create index if not exists marks_student on public.marks(student_id, taken_on);

create table if not exists public.registrations (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 2 and 80),
  phone       text not null check (char_length(phone) between 7 and 25),
  email       text check (email is null or char_length(email) <= 120),
  level       text check (level is null or char_length(level) <= 20),
  mode        text check (mode is null or char_length(mode) <= 20),
  session     text check (session is null or char_length(session) <= 30),
  message     text check (message is null or char_length(message) <= 600),
  source      text check (source is null or char_length(source) <= 30),
  status      text not null default 'new' check (status in ('new', 'contacted', 'enrolled', 'closed'))
);

-- ---------------------------------------------------------------- who is an admin
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.admins a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  )
$$;

-- >>> ADMIN EMAIL <<<  replace with the email you created in Authentication → Users
insert into public.admins (email) values ('nexlyr.solutions@gmail.com') on conflict do nothing;

-- ---------------------------------------------------------------- row level security
alter table public.admins        enable row level security;
alter table public.students      enable row level security;
alter table public.sessions      enable row level security;
alter table public.lectures      enable row level security;
alter table public.progress      enable row level security;
alter table public.announcements enable row level security;
alter table public.marks         enable row level security;
alter table public.registrations enable row level security;

do $$
declare t text;
begin
  foreach t in array array['admins','students','sessions','lectures','progress','announcements','marks','registrations'] loop
    execute format('drop policy if exists "admin full access" on public.%I', t);
    execute format('create policy "admin full access" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- the website form may add a row; it can never read, change or delete one
drop policy if exists "anyone can register" on public.registrations;
create policy "anyone can register" on public.registrations
  for insert to anon, authenticated
  with check (status = 'new');

-- ---------------------------------------------------------------- helpers
create or replace function public._code() returns text
language plpgsql volatile set search_path = public, extensions as $$
declare
  alphabet text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';     -- no 0/O, 1/I/L
  b bytea := gen_random_bytes(8);
  result text := '';
  i int;
begin
  for i in 0..7 loop
    result := result || substr(alphabet, (get_byte(b, i) % length(alphabet)) + 1, 1);
  end loop;
  return substr(result, 1, 4) || '-' || substr(result, 5, 4);
end $$;

-- the student behind a valid session token (null if expired, inactive or unknown)
create or replace function public._student(p_token uuid) returns public.students
language plpgsql volatile security definer set search_path = public as $$
declare s public.students; sid text;
begin
  update public.sessions set last_seen = now()
   where token = p_token and expires_at > now()
   returning student_id into sid;
  if sid is null then return null; end if;
  select * into s from public.students where id = sid;
  if s.id is null or not s.active or (s.expires_at is not null and s.expires_at < now()) then return null; end if;
  return s;
end $$;

-- ---------------------------------------------------------------- public: lecture list
create or replace function public.public_catalogue() returns json
language sql stable security definer set search_path = public as $$
  select coalesce(json_agg(json_build_object(
           'id', l.id, 'level', l.level, 'topic', l.topic, 'n', l.n, 'title', l.title,
           'kind', l.kind, 'minutes', l.minutes, 'free', l.free,
           'video', case when l.free then l.video else null end)
         order by l.level, l.topic, l.n, l.id), '[]'::json)
  from public.lectures l
  where l.published
$$;

-- ---------------------------------------------------------------- students: sign in / out
create or replace function public.student_login(p_id text, p_code text, p_device text, p_label text default null)
returns json
language plpgsql volatile security definer set search_path = public, extensions as $$
declare s public.students; t uuid; devices int;
begin
  perform pg_sleep(0.35);                                   -- slows guessing
  select * into s from public.students where id = upper(trim(p_id));
  if s.id is null then return json_build_object('ok', false, 'error', 'bad_credentials'); end if;
  if s.locked_until is not null and s.locked_until > now() then
    return json_build_object('ok', false, 'error', 'locked');
  end if;
  if crypt(regexp_replace(upper(coalesce(p_code, '')), '[^A-Z0-9]', '', 'g'), s.code_hash) <> s.code_hash then
    update public.students
       set fails = case when fails + 1 >= 8 then 0 else fails + 1 end,
           locked_until = case when fails + 1 >= 8 then now() + interval '10 minutes' else locked_until end
     where id = s.id;
    return json_build_object('ok', false, 'error', 'bad_credentials');
  end if;
  if not s.active then return json_build_object('ok', false, 'error', 'inactive'); end if;
  if s.expires_at is not null and s.expires_at < now() then return json_build_object('ok', false, 'error', 'expired'); end if;

  update public.students set fails = 0, locked_until = null, last_login = now() where id = s.id;
  delete from public.sessions where student_id = s.id and (expires_at < now() or device = left(p_device, 80));

  select count(distinct device) into devices from public.sessions where student_id = s.id;
  if devices >= public.max_devices() then
    return json_build_object('ok', false, 'error', 'device_limit');
  end if;

  insert into public.sessions (student_id, device, label)
  values (s.id, left(coalesce(p_device, 'unknown'), 80), left(p_label, 40))
  returning token into t;

  return json_build_object('ok', true, 'token', t, 'student_id', s.id, 'name', s.name, 'level', s.level);
end $$;

create or replace function public.student_logout(p_token uuid) returns json
language plpgsql volatile security definer set search_path = public as $$
begin
  delete from public.sessions where token = p_token;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------- students: everything on the dashboard
create or replace function public.student_home(p_token uuid) returns json
language plpgsql volatile security definer set search_path = public as $$
declare s public.students;
begin
  s := public._student(p_token);
  if s.id is null then return json_build_object('ok', false, 'error', 'session'); end if;
  return json_build_object(
    'ok', true, 'student_id', s.id, 'name', s.name, 'level', s.level,
    'lectures', coalesce((
      select json_agg(json_build_object('id', l.id, 'topic', l.topic, 'n', l.n, 'title', l.title, 'kind', l.kind,
                                        'minutes', l.minutes, 'free', l.free,
                                        'has_video', coalesce(l.video, '') <> '', 'has_notes', coalesce(l.notes, '') <> '')
                      order by l.kind, l.topic, l.n, l.id)
      from public.lectures l
      where l.published and l.level in ('all', s.level)), '[]'::json),
    'done', coalesce((select json_agg(p.lecture_id) from public.progress p where p.student_id = s.id), '[]'::json),
    'announcements', coalesce((
      select json_agg(json_build_object('id', a.id, 'title', a.title, 'body', a.body, 'pinned', a.pinned, 'created_at', a.created_at)
                      order by a.pinned desc, a.created_at desc)
      from public.announcements a
      where a.published and a.level in ('all', s.level)), '[]'::json),
    'marks', coalesce((
      select json_agg(json_build_object('id', m.id, 'title', m.title, 'paper', m.paper, 'score', m.score,
                                        'out_of', m.out_of, 'taken_on', m.taken_on, 'remarks', m.remarks)
                      order by m.taken_on, m.id)
      from public.marks m
      where m.student_id = s.id), '[]'::json)
  );
end $$;

create or replace function public.get_lecture(p_token uuid, p_lecture bigint) returns json
language plpgsql volatile security definer set search_path = public as $$
declare s public.students; l public.lectures;
begin
  s := public._student(p_token);
  if s.id is null then return json_build_object('ok', false, 'error', 'session'); end if;
  select * into l from public.lectures where id = p_lecture and published and level in ('all', s.level);
  if l.id is null then return json_build_object('ok', false, 'error', 'not_found'); end if;
  return json_build_object('ok', true, 'video', l.video, 'notes', nullif(l.notes, ''));
end $$;

create or replace function public.set_progress(p_token uuid, p_lecture bigint, p_done boolean) returns json
language plpgsql volatile security definer set search_path = public as $$
declare s public.students;
begin
  s := public._student(p_token);
  if s.id is null then return json_build_object('ok', false, 'error', 'session'); end if;
  if p_done then
    insert into public.progress (student_id, lecture_id)
    select s.id, l.id from public.lectures l where l.id = p_lecture and l.level in ('all', s.level)
    on conflict do nothing;
  else
    delete from public.progress where student_id = s.id and lecture_id = p_lecture;
  end if;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------- admin: student IDs and codes
create or replace function public.admin_create_student(p_name text, p_level text, p_phone text default null, p_expires timestamptz default null)
returns json
language plpgsql volatile security definer set search_path = public, extensions as $$
declare new_id text; new_code text;
begin
  if not public.is_admin() then raise exception 'not allowed'; end if;
  loop
    new_id := 'RA-' || nextval('public.student_no');
    exit when not exists (select 1 from public.students where id = new_id);
  end loop;
  new_code := public._code();
  insert into public.students (id, name, level, phone, code_hash, expires_at)
  values (new_id, trim(p_name), p_level, nullif(trim(coalesce(p_phone, '')), ''), crypt(replace(new_code, '-', ''), gen_salt('bf', 8)), p_expires);
  return json_build_object('id', new_id, 'code', new_code);
end $$;

create or replace function public.admin_reset_code(p_id text) returns json
language plpgsql volatile security definer set search_path = public, extensions as $$
declare new_code text;
begin
  if not public.is_admin() then raise exception 'not allowed'; end if;
  new_code := public._code();
  update public.students set code_hash = crypt(replace(new_code, '-', ''), gen_salt('bf', 8)), fails = 0, locked_until = null where id = p_id;
  if not found then raise exception 'no such student'; end if;
  delete from public.sessions where student_id = p_id;
  return json_build_object('id', p_id, 'code', new_code);
end $$;

create or replace function public.admin_reset_devices(p_id text) returns json
language plpgsql volatile security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'not allowed'; end if;
  delete from public.sessions where student_id = p_id;
  update public.students set fails = 0, locked_until = null where id = p_id;
  return json_build_object('ok', true);
end $$;

-- keep updated_at honest
create or replace function public._touch() returns trigger
language plpgsql as $$ begin new.updated_at := now(); return new; end $$;
drop trigger if exists lectures_touch on public.lectures;
create trigger lectures_touch before update on public.lectures for each row execute function public._touch();

-- ---------------------------------------------------------------- who may call what
revoke all on function public._code()                                from public, anon, authenticated;
revoke all on function public._student(uuid)                         from public, anon, authenticated;
revoke all on function public._touch()                               from public, anon, authenticated;

revoke all on function public.public_catalogue()                     from public;
revoke all on function public.student_login(text, text, text, text)  from public;
revoke all on function public.student_logout(uuid)                   from public;
revoke all on function public.student_home(uuid)                     from public;
revoke all on function public.get_lecture(uuid, bigint)              from public;
revoke all on function public.set_progress(uuid, bigint, boolean)    from public;
revoke all on function public.admin_create_student(text, text, text, timestamptz) from public, anon;
revoke all on function public.admin_reset_code(text)                 from public, anon;
revoke all on function public.admin_reset_devices(text)              from public, anon;

grant execute on function public.public_catalogue()                     to anon, authenticated;
grant execute on function public.student_login(text, text, text, text)  to anon, authenticated;
grant execute on function public.student_logout(uuid)                   to anon, authenticated;
grant execute on function public.student_home(uuid)                     to anon, authenticated;
grant execute on function public.get_lecture(uuid, bigint)              to anon, authenticated;
grant execute on function public.set_progress(uuid, bigint, boolean)    to anon, authenticated;
grant execute on function public.admin_create_student(text, text, text, timestamptz) to authenticated;
grant execute on function public.admin_reset_code(text)                 to authenticated;
grant execute on function public.admin_reset_devices(text)              to authenticated;
grant execute on function public.is_admin()                             to anon, authenticated;
grant usage on sequence public.student_no to authenticated;

-- =============================================================================
--  Done. Students, lectures, announcements, marks and enrolments are all
--  managed from admin.html.
-- =============================================================================
