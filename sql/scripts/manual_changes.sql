select e.display_text, et.tag, et.value from entry_tags et
inner join entry e on e.entry = et.entry
where et.tag like 'manual %'
order by et.tag;

select s.display_text, st.tag, st.value from sense_tags st
inner join sense s on s.id = st.sense_id
where st.tag like 'manual %'
order by st.tag;
