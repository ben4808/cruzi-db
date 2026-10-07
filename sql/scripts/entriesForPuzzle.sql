update clue set sense_id = null, match_attempted = false where "id" in (
select c.id from clue c
inner join collection__clue colc on colc.clue_id = c.id
inner join clue_collection cc on cc.id = colc.collection_id
where cc.puzzle_id in ('K4wgQE33rE_', 'f9xql2v7-u0', 'la3jJRFVheO', 'nMI3w5otM7b')
and c.entry in ('WENTHALFSIESON', 'POSSUM')
order by c.entry
);
