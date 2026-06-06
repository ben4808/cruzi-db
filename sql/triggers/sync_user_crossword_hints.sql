-- Recompute user__collection hints_used and completed for every collection containing the affected clue.
create or replace function trg_sync_user_crossword_hints()
returns trigger
language plpgsql
as $$
declare
  v_user_id text := coalesce(new.user_id, old.user_id);
  v_clue_id text := coalesce(new.clue_id, old.clue_id);
begin
  insert into user__collection (user_id, collection_id, hints_used, completed)
  select
    v_user_id,
    stats.collection_id,
    stats.hints_used,
    stats.completed
  from (
    select
      cc.collection_id,
      coalesce(sum(upc.hints_used), 0)::int as hints_used,
      count(upc.clue_id)::int as completed
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
  on conflict (user_id, collection_id) do update
  set
    hints_used = excluded.hints_used,
    completed = excluded.completed;

  return coalesce(new, old);
end;
$$;

create trigger sync_user_crossword_hints
after insert or update of hints_used or delete
on user__puzzle_clue
for each row
execute procedure trg_sync_user_crossword_hints();
