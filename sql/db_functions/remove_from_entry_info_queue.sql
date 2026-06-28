CREATE OR REPLACE FUNCTION remove_from_entry_info_queue(
    p_entry text,
    p_lang text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM entry_info_queue
    WHERE "entry" = p_entry AND lang = p_lang;
END;
$$;
