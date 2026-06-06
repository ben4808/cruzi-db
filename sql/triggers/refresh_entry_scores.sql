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
