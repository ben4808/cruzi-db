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
