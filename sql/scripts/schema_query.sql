SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    a.attnum AS ordinal_position,
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
    a.attnotnull AS not_null,
    COALESCE(pg_get_expr(d.adbin, d.adrelid), '') AS column_default,
    COALESCE(p.contype = 'p', false) AS is_primary_key,
    COALESCE(fk.contype = 'f', false) AS is_foreign_key,
    COALESCE(fk_table.relname, '') AS foreign_table,
    COALESCE(fk_attrs.attname, '') AS foreign_column
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
LEFT JOIN pg_constraint p ON p.conrelid = a.attrelid AND p.contype = 'p' AND a.attnum = ANY(p.conkey)
LEFT JOIN pg_constraint fk ON fk.conrelid = a.attrelid AND fk.contype = 'f' AND a.attnum = ANY(fk.conkey)
LEFT JOIN pg_class fk_table ON fk_table.oid = fk.confrelid
LEFT JOIN LATERAL (
    SELECT attname FROM pg_attribute fa WHERE fa.attrelid = fk.confrelid AND fa.attnum = fk.confkey[1]
) fk_attrs ON true
WHERE c.relkind IN ('r', 'p')
    AND n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY n.nspname, c.relname, a.attnum;
