insert into phrase_generator_queue (prompt, lang)
--select entry || ' ____' as prompt, 'en' as lang
select '____ ' || entry as prompt, 'en' as lang
from entry where entry in (
  select e.entry from entry e
  left join entry_tags et on e.entry = et.entry and et.tag = 'nyt'
  where e.entry_type = 'Word'
  and e.familiarity_bucket in ('Ubiquitous', 'Beginner Core')
  and e.length > 2
  order by e.entry
);
