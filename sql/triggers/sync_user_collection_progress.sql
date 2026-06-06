-- Recompute user__collection progress for every collection containing the affected clue.
create or replace function trg_sync_user_collection_progress()
returns trigger
language plpgsql
as $$
declare
  v_user_id text := coalesce(new.user_id, old.user_id);
  v_clue_id text := coalesce(new.clue_id, old.clue_id);
begin
  insert into user__collection (user_id, collection_id, unseen, in_progress, completed)
  select
    v_user_id,
    stats.collection_id,
    stats.unseen,
    stats.in_progress,
    stats.completed
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
  on conflict (user_id, collection_id) do update
  set
    unseen = excluded.unseen,
    in_progress = excluded.in_progress,
    completed = excluded.completed;

  return coalesce(new, old);
end;
$$;

create trigger sync_user_collection_progress
after insert or update or delete
on user__clue
for each row
execute procedure trg_sync_user_collection_progress();
