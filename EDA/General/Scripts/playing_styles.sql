-- Team Performance by Playing Style (Most Recent Season)
WITH team_playing_styles AS (
    -- Home matches
    SELECT 
        hometeam as team,
        season,
        AVG(hometeamshots) as avg_shots,
        AVG(hometeamshotsontarget) as avg_shots_on_target,
        AVG(fulltimehometeamgoals) as avg_goals_scored,
        AVG(fulltimeawayteamgoals) as avg_goals_conceded,
        COUNT(*) as matches_played,
        SUM(hometeampoints) as total_points
    FROM epl_cleaned_partial_explored_data 
    GROUP BY hometeam, season
    
    UNION ALL
    
    -- Away matches  
    SELECT 
        awayteam as team,
        season,
        AVG(awayteamshots) as avg_shots,
        AVG(awayteamshotsontarget) as avg_shots_on_target,
        AVG(fulltimeawayteamgoals) as avg_goals_scored,
        AVG(fulltimehometeamgoals) as avg_goals_conceded,
        COUNT(*) as matches_played,
        SUM(awayteampoints) as total_points
    FROM epl_cleaned_partial_explored_data 
    GROUP BY awayteam, season
),
team_season_summary AS (
    SELECT 
        team,
        season,
        ROUND(AVG(avg_shots)::numeric, 1) as shots_per_game,
        ROUND(AVG(avg_shots_on_target)::numeric, 1) as shots_on_target_per_game,
        ROUND(AVG(avg_goals_scored)::numeric, 2) as goals_per_game,
        ROUND(AVG(avg_goals_conceded)::numeric, 2) as goals_conceded_per_game,
        SUM(matches_played) as total_matches,
        SUM(total_points) as season_points,
        ROUND((AVG(avg_shots_on_target) * 100.0 / NULLIF(AVG(avg_shots), 0))::numeric, 1) as shot_accuracy
    FROM team_playing_styles
    GROUP BY team, season
)
SELECT 
    team,
    season,
    season_points,
    goals_per_game,
    goals_conceded_per_game,
    ROUND((goals_per_game - goals_conceded_per_game)::numeric, 2) as goal_difference,
    shots_per_game,
    shot_accuracy,
    CASE 
        WHEN goals_per_game > 1.5 AND shots_per_game > 12 THEN 'High Attack'
        WHEN goals_conceded_per_game < 1.2 THEN 'Strong Defense' 
        WHEN shot_accuracy > 40 THEN 'Efficient Attack'
        ELSE 'Balanced'
    END as playing_style
FROM team_season_summary
WHERE season = (SELECT MAX(season) FROM epl_cleaned_partial_explored_data) -- Most recent season
ORDER BY season_points DESC;


-- Playing Style Effectiveness Analysis (Separate Query)
WITH team_playing_styles_analysis AS (
    -- Home matches
    SELECT 
        hometeam as team,
        season,
        AVG(hometeamshots) as avg_shots,
        AVG(hometeamshotsontarget) as avg_shots_on_target,
        AVG(fulltimehometeamgoals) as avg_goals_scored,
        AVG(fulltimeawayteamgoals) as avg_goals_conceded,
        COUNT(*) as matches_played,
        SUM(hometeampoints) as total_points
    FROM epl_cleaned_partial_explored_data 
    GROUP BY hometeam, season
    
    UNION ALL
    
    -- Away matches  
    SELECT 
        awayteam as team,
        season,
        AVG(awayteamshots) as avg_shots,
        AVG(awayteamshotsontarget) as avg_shots_on_target,
        AVG(fulltimeawayteamgoals) as avg_goals_scored,
        AVG(fulltimehometeamgoals) as avg_goals_conceded,
        COUNT(*) as matches_played,
        SUM(awayteampoints) as total_points
    FROM epl_cleaned_partial_explored_data 
    GROUP BY awayteam, season
),
style_classification AS (
    SELECT 
        team,
        season,
        SUM(total_points) as season_points,
        ROUND((AVG(avg_goals_scored) - AVG(avg_goals_conceded))::numeric, 2) as goal_difference,
        CASE 
            WHEN AVG(avg_goals_scored) > 1.5 AND AVG(avg_shots) > 12 THEN 'High Attack'
            WHEN AVG(avg_goals_conceded) < 1.2 THEN 'Strong Defense' 
            WHEN (AVG(avg_shots_on_target) * 100.0 / NULLIF(AVG(avg_shots), 0)) > 40 THEN 'Efficient Attack'
            ELSE 'Balanced'
        END as playing_style
    FROM team_playing_styles_analysis
    GROUP BY team, season
)
SELECT 
    playing_style,
    COUNT(*) as teams_count,
    ROUND(AVG(season_points)::numeric, 1) as avg_points,
    ROUND(AVG(goal_difference)::numeric, 2) as avg_goal_diff
FROM style_classification
GROUP BY playing_style
ORDER BY avg_points DESC;