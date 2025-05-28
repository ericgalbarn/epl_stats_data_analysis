WITH home_advantage_stats AS (
    SELECT 
        season,
        COUNT(*) as total_matches,
        SUM(CASE WHEN fulltimeresult = 'H' THEN 1 ELSE 0 END) as home_wins,
        SUM(CASE WHEN fulltimeresult = 'D' THEN 1 ELSE 0 END) as draws,
        SUM(CASE WHEN fulltimeresult = 'A' THEN 1 ELSE 0 END) as away_wins,
        ROUND(AVG(fulltimehometeamgoals), 2) as avg_home_goals,
        ROUND(AVG(fulltimeawayteamgoals), 2) as avg_away_goals
    FROM epl_cleaned_partial_explored_data 
    GROUP BY season
)
SELECT 
    season,
    total_matches,
    ROUND((home_wins * 100.0 / total_matches), 1) as home_win_percentage,
    ROUND((draws * 100.0 / total_matches), 1) as draw_percentage,
    ROUND((away_wins * 100.0 / total_matches), 1) as away_win_percentage,
    avg_home_goals,
    avg_away_goals,
    ROUND((avg_home_goals - avg_away_goals), 2) as goal_advantage
FROM home_advantage_stats
ORDER BY season;

-- Summary insight
SELECT 
    'Overall Home Advantage' as insight,
    ROUND(AVG(CASE WHEN fulltimeresult = 'H' THEN 1.0 ELSE 0 END) * 100, 1) as home_win_rate,
    ROUND(AVG(fulltimehometeamgoals - fulltimeawayteamgoals), 2) as avg_goal_difference
FROM epl_cleaned_partial_explored_data;