-- Migration: update AWS schema to match local schema (cruzi-db/sql/schema.sql)
-- Source: comparison of aws-schema.csv (current AWS) vs schema.sql (target)
--
-- Destructive notes (data loss possible):
--   * entry.idiomactivity_score is dropped
--   * clue.source is dropped
--   * sense_translation table is dropped
-- Everything else is additive or rename-only.

BEGIN;

-- ============================================================
-- 1. entry table
-- ============================================================
ALTER TABLE "entry" RENAME COLUMN root_entry TO base_form;
ALTER TABLE "entry" DROP COLUMN idiomactivity_score;
ALTER TABLE "entry" ADD COLUMN familiarity_bucket text;
ALTER TABLE "entry" ADD COLUMN quality_bucket text;
ALTER TABLE "entry" ADD COLUMN unity_bucket text;
ALTER TABLE "entry" ADD COLUMN unity_score int;
ALTER TABLE "entry" ADD COLUMN is_vulgar boolean;
ALTER TABLE "entry" ADD COLUMN reviewed_status text;

-- ============================================================
-- 2. clue table: drop source column
-- ============================================================
ALTER TABLE clue DROP COLUMN source;

-- ============================================================
-- 3. user table: add unique constraint on email
--    (will fail if duplicate emails exist; if so, dedupe first)
-- ============================================================
ALTER TABLE "user" ADD CONSTRAINT user_email_unique UNIQUE (email);

-- ============================================================
-- 4. Drop sense_translation table (not in local schema)
-- ============================================================
DROP TABLE IF EXISTS sense_translation;

-- ============================================================
-- 5. Create new tables
-- ============================================================
CREATE TABLE IF NOT EXISTS short_phrase_result (
  id serial primary key,
  prompt text not null,
  "entry" text not null,
  lang text not null,
  display_text text,
  unity_bucket text,
  frequency text,
  familiarity_bucket text
);

CREATE TABLE IF NOT EXISTS short_phrase_summary (
  result_id int not null references short_phrase_result(id) on delete cascade,
  "entry" text not null,
  lang text not null,
  summary text not null,
  frequency text not null
);

CREATE TABLE IF NOT EXISTS short_phrase_queue (
  prompt text not null,
  lang text not null,
  "length" int not null,
  added_at timestamp not null default now(),
  primary key(prompt, lang)
);

CREATE TABLE IF NOT EXISTS friendly_words_game (
  id text not null primary key,
  game_code text,
  title text not null,
  host_player_id text not null,
  "status" text not null default 'lobby', -- lobby | playing | completed
  lang text not null default 'en',         -- en | es
  created_at timestamp not null default now(),
  completed_at timestamp,
  player1 text,
  player2 text,
  player3 text,
  player4 text,
  waitlist jsonb not null default '[]'::jsonb,
  "state" jsonb not null default '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS friendly_words_turn (
  id text not null primary key,
  game_id text not null references friendly_words_game(id) on delete cascade,
  player text not null,
  turn_number int not null,
  rack text not null,
  "action" text not null,
  gross_score int,
  total_multiplier text,
  net_score int,
  start_score int not null default 0,
  end_score int not null default 0
);

CREATE TABLE IF NOT EXISTS friendly_words_played_word (
  id text not null primary key,
  turn_id text not null,
  "entry" text not null,
  lang text not null,
  gross_score int not null default 0,
  multiplier text not null
);

CREATE TABLE IF NOT EXISTS friendly_words_rating (
  played_word_id text not null,
  player_id text not null,
  "entry" text not null,
  lang text not null,
  multiplier text not null,
  was_updated boolean not null default false,
  primary key(played_word_id, player_id)
);

-- ============================================================
-- 6. Indexes (IF NOT EXISTS keeps script idempotent)
-- ============================================================
CREATE INDEX IF NOT EXISTS ix_clue_collection_created_date ON clue_collection(created_date asc);
CREATE INDEX IF NOT EXISTS ix_puzzle_publication_date ON puzzle(publication_id, "date");
CREATE INDEX IF NOT EXISTS ix_clue_collection_puzzle_id ON clue_collection(puzzle_id);
CREATE INDEX IF NOT EXISTS ix_collection__clue_collection_order ON collection__clue(collection_id, "order");
CREATE INDEX IF NOT EXISTS ix_user__collection_user_id ON user__collection(user_id);
CREATE INDEX IF NOT EXISTS ix_sense_entry_lang ON sense("entry", lang);
CREATE INDEX IF NOT EXISTS ix_entry_loading_status ON "entry"(loading_status) WHERE loading_status <> 'Ready';
CREATE UNIQUE INDEX IF NOT EXISTS ux_friendly_words_game_code ON friendly_words_game(game_code) WHERE game_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_friendly_words_turn_game_id ON friendly_words_turn(game_id, turn_number);
CREATE INDEX IF NOT EXISTS ix_friendly_words_played_word_turn_id ON friendly_words_played_word(turn_id);

COMMIT;
