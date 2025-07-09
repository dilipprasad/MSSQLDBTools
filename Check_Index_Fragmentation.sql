--Check index Fragmentation

SELECT 
    dbschemas.[name] as 'Schema',
    dbtables.[name] as 'Table',
    dbindexes.[name] as 'Index',
    indexstats.avg_fragmentation_in_percent,
    indexstats.page_count
FROM 
    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS indexstats
    INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
    INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
    INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
        AND indexstats.index_id = dbindexes.index_id
WHERE 
    indexstats.database_id = DB_ID()
    AND indexstats.page_count > 100
ORDER BY 
    indexstats.avg_fragmentation_in_percent DESC;


| Fragmentation % | Page Count | Action                                              |
| --------------- | ---------- | --------------------------------------------------- |
| < 5%            | Any        | Do nothing                                          |
| 5–30%           | > 100      | Reorganize                                          |
| > 30%           | > 100      | Rebuild                                             |
| Any %           | < 100      | Usually not worth it unless performance is impacted |
