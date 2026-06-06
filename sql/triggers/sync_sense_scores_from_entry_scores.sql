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
