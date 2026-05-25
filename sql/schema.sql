/*
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
*/

create table publication (
  id text not null primary key,
  "name" text not null
);

create table "user" (
  id text not null primary key,
  email text not null unique,
  first_name text,
  last_name text,
  native_lang text,
  created_at timestamp not null default now()
);

create table "entry" (
  "entry" text not null,
  root_entry text, -- For inflected forms, the base form
  lang text not null,
  "length" int not null,
  display_text text,
  entry_type text,
  -- directly set if no senses exist, otherwise the average of sense scores
  familiarity_score int,
  quality_score int,
  loading_status text not null default 'Ready', -- Ready, Processing, Error, Invalid
  primary key("entry", lang)
);

create table puzzle (
  id text not null primary key,
  publication_id text references publication(id) on delete set null,
  "date" date not null,
  lang text not null default 'en',
  author text,
  title text not null,
  copyright text,
  notes text,
  width int not null,
  height int not null,
  source_link text
);

create table clue_collection (
  id text not null primary key,
  puzzle_id text references puzzle(id) on delete set null,
  title text not null,
  lang text not null,
  author text, -- One of author or creator_id might be populated
  creator_id text references "user"(id) on delete set null,
  "description" text,
  is_private boolean not null default false,
  created_date timestamp not null,
  modified_date timestamp not null,
  metadata1 text, -- AI composite score
  metadata2 text,
  "source" text, -- Book it came from? AI source? Important in case I need to remove copyrighted data.
  clue_count int not null default 0,
  clue_count_6_plus int not null default 0
);

create table sense (
  id text not null primary key,
  "entry" text not null,
  lang text not null,
  summary text,
  "definition" text,
  part_of_speech text,
  commonness text,
  -- average of AI opinions
  familiarity_score int,
  quality_score int,
  similar_entries text[],
  source_ai text, -- for summary, definition
  foreign key ("entry", lang) references "entry"("entry", lang) on delete cascade
);

create table sense_translation (
  sense_id text not null references sense(id) on delete cascade,
  lang text not null,
  summary text not null,
  definition text,
  primary key(sense_id, lang)
);

create table entry_tags (
  "entry" text not null,
  lang text not null,
  tag text not null,
  "value" text,
  primary key("entry", lang, tag),
  foreign key ("entry", lang) references "entry"("entry", lang) on delete cascade
);

create table sense_entry_translation (
  sense_id text not null references sense(id) on delete cascade,
  "entry" text not null,
  lang text not null,
  natural_translations text[],
  colloquial_translations text[],
  primary key(sense_id, "entry", lang)
);

create table example_sentence (
  id text not null primary key,
  sense_id text not null references sense(id) on delete cascade
);

create table example_sentence_translation (
  example_sentence_id text not null references example_sentence(id) on delete cascade,
  lang text not null,
  sentence text not null,
  primary key(example_sentence_id, lang)
);

create table sense_entry_score (
  sense_id text not null references sense(id) on delete cascade,
  familiarity_score int,
  quality_score int,
  source_ai text not null,
  primary key(sense_id, source_ai)
);

create table clue (
  id text not null primary key,
  "entry" text not null, -- in some cases only for reference if there is a sense provided
  lang text not null, -- in some cases only for reference if there is a sense provided
  sense_id text references sense(id) on delete set null, -- optional, if linked to a specific sense
  custom_clue text,
  custom_display_text text,
  source text,
  foreign key ("entry", lang) references "entry"("entry", lang) on delete cascade
);

create table collection__clue (
  collection_id text not null references clue_collection(id) on delete cascade,
  clue_id text not null references clue(id) on delete cascade,
  "order" int not null,
  metadata1 text, -- Clue index in puzzle
  metadata2 text,
  primary key(collection_id, clue_id)
);

create table user__collection (
  user_id text not null references "user"(id) on delete cascade,
  collection_id text not null references clue_collection(id) on delete cascade,
  unseen int not null default 0,
  in_progress int not null default 0,
  completed int not null default 0,
  hints_used int not null default 0,
  primary key(user_id, collection_id)
);

create table user__clue (
  user_id text not null references "user"(id) on delete cascade,
  clue_id text not null references clue(id) on delete cascade,
  correct_solves_needed int not null default 2,
  correct_solves int not null default 0,
  incorrect_solves int not null default 0,
  last_solve date,
  primary key(user_id, clue_id)
);

create table user__puzzle_clue (
  user_id text not null references "user"(id) on delete cascade,
  clue_id text not null references clue(id) on delete cascade,
  hints_used int not null default 0,
  primary key(user_id, clue_id)
);

create table entry_info_queue (
  id serial primary key,
  "entry" text not null,
  lang text not null,
  added_at timestamp not null default now()
);

create table example_sentence_queue (
  id serial primary key,
  sense_id text not null references sense(id) on delete cascade,
  added_at timestamp not null default now()
);

create table collection_access (
  collection_id text not null references clue_collection(id) on delete cascade,
  user_id text not null references "user"(id) on delete cascade,
  primary key(collection_id, user_id)
);

create table crossword_familiarity_queue (
  id serial primary key,
  "entry" text not null,
  lang text not null,
  added_at timestamp not null default now()
);

create table crossword_quality_queue (
  id serial primary key,
  "entry" text not null,
  lang text not null,
  added_at timestamp not null default now()
);

-- Indexes
create index ix_clue_collection_created_date on clue_collection(created_date asc);
create index ix_puzzle_publication_date on puzzle(publication_id, "date");
create index ix_clue_collection_puzzle_id on clue_collection(puzzle_id);
create index ix_collection__clue_collection_order on collection__clue(collection_id, "order");
create index ix_user__collection_user_id on user__collection(user_id);
create index ix_sense_entry_lang on sense("entry", lang);
create index ix_entry_loading_status on "entry"(loading_status) where loading_status <> 'Ready';

-- Recompute entry scores from the average of sense scores for that entry/lang.
create or replace function refresh_entry_scores(p_entry text, p_lang text)
returns void
language plpgsql
as $$
begin
  update "entry" e
  set
    familiarity_score = (
      select cast(round(avg(s.familiarity_score)) as int)
      from sense s
      where s."entry" = p_entry
        and s.lang = p_lang
        and s.familiarity_score is not null
    ),
    quality_score = (
      select cast(round(avg(s.quality_score)) as int)
      from sense s
      where s."entry" = p_entry
        and s.lang = p_lang
        and s.quality_score is not null
    )
  where e."entry" = p_entry
    and e.lang = p_lang;
end;
$$;

create or replace function trg_sync_entry_scores_from_senses()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    perform refresh_entry_scores(old."entry", old.lang);
    return old;
  end if;

  if tg_op = 'UPDATE'
     and (old."entry" is distinct from new."entry" or old.lang is distinct from new.lang) then
    perform refresh_entry_scores(old."entry", old.lang);
  end if;

  perform refresh_entry_scores(new."entry", new.lang);
  return new;
end;
$$;

create trigger sync_entry_scores_from_senses
after insert or update of familiarity_score, quality_score, "entry", lang or delete
on sense
for each row
execute procedure trg_sync_entry_scores_from_senses();

-- Recompute sense scores from sense_entry_score rows, then entry scores follow via sense trigger.
create or replace function trg_sync_sense_scores_from_entry_scores()
returns trigger
language plpgsql
as $$
declare
  v_sense_id text := coalesce(new.sense_id, old.sense_id);
begin
  update sense s
  set
    familiarity_score = (
      select cast(round(avg(ses.familiarity_score)) as int)
      from sense_entry_score ses
      where ses.sense_id = v_sense_id
        and ses.familiarity_score is not null
    ),
    quality_score = (
      select cast(round(avg(ses.quality_score)) as int)
      from sense_entry_score ses
      where ses.sense_id = v_sense_id
        and ses.quality_score is not null
    )
  where s.id = v_sense_id;

  return coalesce(new, old);
end;
$$;

create trigger sync_sense_scores_from_entry_scores
after insert or update of familiarity_score, quality_score or delete
on sense_entry_score
for each row
execute procedure trg_sync_sense_scores_from_entry_scores();

-- Recompute user__collection progress for every collection containing the affected clue.
create or replace function trg_sync_user_collection_progress()
returns trigger
language plpgsql
as $$
declare
  v_user_id text := coalesce(new.user_id, old.user_id);
  v_clue_id text := coalesce(new.clue_id, old.clue_id);
begin
  update user__collection uc
  set
    unseen = stats.unseen,
    in_progress = stats.in_progress,
    completed = stats.completed
  from (
    select
      cc.collection_id,
      count(*) filter (where ucl.user_id is null)::int as unseen,
      count(*) filter (
        where ucl.user_id is not null
          and ucl.correct_solves < ucl.correct_solves_needed
      )::int as in_progress,
      count(*) filter (
        where ucl.user_id is not null
          and ucl.correct_solves >= ucl.correct_solves_needed
      )::int as completed
    from collection__clue cc
    left join user__clue ucl
      on ucl.clue_id = cc.clue_id
      and ucl.user_id = v_user_id
    where cc.collection_id in (
      select collection_id
      from collection__clue
      where clue_id = v_clue_id
    )
    group by cc.collection_id
  ) stats
  where uc.user_id = v_user_id
    and uc.collection_id = stats.collection_id;

  return coalesce(new, old);
end;
$$;

create trigger sync_user_collection_progress
after insert or update or delete
on user__clue
for each row
execute procedure trg_sync_user_collection_progress();

-- Recompute user__collection hints_used for every collection containing the affected clue.
create or replace function trg_sync_user_collection_hints()
returns trigger
language plpgsql
as $$
declare
  v_user_id text := coalesce(new.user_id, old.user_id);
  v_clue_id text := coalesce(new.clue_id, old.clue_id);
begin
  update user__collection uc
  set hints_used = stats.hints_used
  from (
    select
      cc.collection_id,
      coalesce(sum(upc.hints_used), 0)::int as hints_used
    from collection__clue cc
    left join user__puzzle_clue upc
      on upc.clue_id = cc.clue_id
      and upc.user_id = v_user_id
    where cc.collection_id in (
      select collection_id
      from collection__clue
      where clue_id = v_clue_id
    )
    group by cc.collection_id
  ) stats
  where uc.user_id = v_user_id
    and uc.collection_id = stats.collection_id;

  return coalesce(new, old);
end;
$$;

create trigger sync_user_collection_hints
after insert or update of hints_used or delete
on user__puzzle_clue
for each row
execute procedure trg_sync_user_collection_hints();
