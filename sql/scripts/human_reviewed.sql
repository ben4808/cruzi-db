select e.display_text, e.classification, e.unity_bucket, e.familiarity_bucket, e.quality_bucket, 
et1.tag as "vulgar", et2.tag as "sensitive"
from entry e
left join entry_tags et1 on et1.entry = e.entry and et1.tag = 'vulgar'
left join entry_tags et2 on et2.entry = e.entry and et2.tag = 'sensitive'
where e.human_reviewed = true;
