-- Allow completed games to release their join codes for reuse.
-- Apply to existing databases (schema.sql is the source of truth for new installs).

ALTER TABLE friendly_words_game ALTER COLUMN game_code DROP NOT NULL;

UPDATE friendly_words_game
SET game_code = NULL
WHERE status = 'completed' OR completed_at IS NOT NULL;

DROP INDEX IF EXISTS ux_friendly_words_game_code;
CREATE UNIQUE INDEX ux_friendly_words_game_code
  ON friendly_words_game(game_code)
  WHERE game_code IS NOT NULL;
