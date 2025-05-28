SELECT *
FROM epl_cleaned_partial_explored_data;

-- **Data exploration setup**

-- Check for data completeness before analysis
SELECT 
    'Total Matches' as metric,
    COUNT(*)::text as value,
    'Records' as unit
FROM epl_cleaned_partial_explored_data

UNION ALL

SELECT 
    'Date Range',
    CONCAT(MIN(date), ' to ', MAX(date)),
    'Period'
FROM epl_cleaned_partial_explored_data

UNION ALL

SELECT 
    'Unique Seasons',
    COUNT(DISTINCT season)::text,
    'Seasons'
FROM epl_cleaned_partial_explored_data

UNION ALL

SELECT 
    'Missing Goals Data',
    COUNT(*)::text,
    'Records'
FROM epl_cleaned_partial_explored_data
WHERE fulltimehometeamgoals IS NULL OR fulltimeawayteamgoals IS NULL;