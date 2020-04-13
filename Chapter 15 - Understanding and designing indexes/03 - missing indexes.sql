--You can find the following query, which concatenates together the CREATE INDEX statement for you, according to a simple, self-explanatory naming convention. 
-- As you can see from the use of system views, this query is intended to be run in a single database
--At the bottom of this query are a series of filters that you can use to find only the most-used, highest-value index suggestions.
-- If you have hundreds or thousands of rows returned by this query, consider spending an afternoon crafting together indexes to
-- improve the performance of the actual user activity that generated this data.
SELECT mid.[statement], create_index_statement = 
	CONCAT('CREATE NONCLUSTERED INDEX IDX_NC_', 
	 TRANSLATE(replace(mid.equality_columns, ' ' ,''), '],[' ,'___')
    , TRANSLATE(replace(mid.inequality_columns, ' ' ,''), '],[' ,'___') 
    , ' ON ' , mid.[statement]	, ' (' , mid.equality_columns
    , CASE WHEN mid.equality_columns IS NOT NULL
     AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
    , mid.inequality_columns , ')'
    , ' INCLUDE (' , mid.included_columns , ')' )
, migs.unique_compiles, migs.user_seeks, migs.user_scans
, migs.last_user_seek, migs.avg_total_user_cost
, migs.avg_user_impact, mid.equality_columns
, mid.inequality_columns, mid.included_columns
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid
ON mig.index_handle = mid.index_handle
INNER JOIN sys.tables t ON t.object_id = mid.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE mid.database_id = DB_ID()  
-- count of query compilations that needed this proposed index
--AND       migs.unique_compiles > 10
-- count of query seeks that needed this proposed index
--AND       migs.user_seeks > 10
-- average percentage of cost that could be alleviated with this proposed index
--AND       migs.avg_user_impact > 75
-- Sort by indexes that will have the most impact to the costliest queries
ORDER BY migs.avg_user_impact * migs.avg_total_user_cost desc;  


--Missing Index suggestions may overlap each other. For example, you might see these three index suggestions:
CREATE NONCLUSTERED INDEX IDX_NC_Gamelog_Team1 ON dbo.gamelog (Team1) INCLUDE (GameYear, GameWeek, Team1Score, Team2Score);
CREATE NONCLUSTERED INDEX IDX_NC_Gamelog_Team1_GameWeek_GameYear ON dbo.gamelog (Team1, GameWeek, GameYear) INCLUDE (Team1Score);
CREATE NONCLUSTERED INDEX IDX_NC_Gamelog_Team1_GameWeek_GameYear_Team2 ON dbo.gamelog (Team1, GameWeek, GameYear, Team2);

--You should not create all three of these indexes. Instead, you should combine the indexes you deem useful 
--and worthwhile into a single index that matches the order of the needed key columns and covers all the included columns, as well. 
--Here is the properly combined index suggestion:
CREATE NONCLUSTERED INDEX IDX_NC_Gamelog_Team1_GameWeek_GameYear_Team2 ON dbo.gamelog (Team1, GameWeek, GameYear, Team2) INCLUDE (Team1Score, Team2Score);


