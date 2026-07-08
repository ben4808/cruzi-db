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
  idiomacity_score int,
  loading_status text not null default 'Ready', -- Ready, Processing, Error, Invalid
  primary key("entry", lang)
);

create table puzzle (
  id text not null primary key,
  publication_id text,
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
  frequency text,
  classification text,
  -- average of AI opinions
  familiarity_score int,
  quality_score int,
  similar_entries text[],
  source_ai text, -- for summary, definition
  foreign key ("entry", lang) references "entry"("entry", lang) on delete cascade
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

create table example_sentence_improvement (
  id text not null primary key,
  example_sentence_id text not null references example_sentence(id) on delete cascade,
  old_sentence text not null,
  new_sentence text not null,
  new_translation text not null
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
  custom_display_text text
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
  collection_completed boolean not null default false, -- for crosswords where they might only complete entries 6 letters or longer
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

create table idiomacity_queue (
  id serial primary key,
  "entry" text not null,
  lang text not null,
  added_at timestamp not null default now()
);

create table phrase_generator_queue (
  id serial primary key,
  prompt text not null,
  lang text not null,
  added_at timestamp not null default now()
);

create table phrase_generator_result (
  phrase_generator_queue_id int not null references phrase_generator_queue(id) on delete cascade,
  phrase text not null,
  added_at timestamp not null default now(),
  primary key(phrase_generator_queue_id, phrase)
);

-- Indexes
create index ix_clue_collection_created_date on clue_collection(created_date asc);
create index ix_puzzle_publication_date on puzzle(publication_id, "date");
create index ix_clue_collection_puzzle_id on clue_collection(puzzle_id);
create index ix_collection__clue_collection_order on collection__clue(collection_id, "order");
create index ix_user__collection_user_id on user__collection(user_id);
create index ix_sense_entry_lang on sense("entry", lang);
create index ix_entry_loading_status on "entry"(loading_status) where loading_status <> 'Ready';
