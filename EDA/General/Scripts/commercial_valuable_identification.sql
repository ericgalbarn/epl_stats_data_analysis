-- High Value Match Characteristics Summary
WITH match_excitement AS (
    SELECT
        matchid,
        season,
        date,
        hometeam,
        awayteam,
        CAST(fulltimehometeamgoals AS INTEGER) + CAST(fulltimeawayteamgoals AS INTEGER) AS total_goals,
        CAST(hometeamshots AS REAL) + CAST(awayteamshots AS REAL) AS total_shots,
        ABS(CAST(fulltimehometeamgoals AS INTEGER) - CAST(fulltimeawayteamgoals AS INTEGER)) AS goal_margin,

        -- Handling possible non-numeric values for yellow cards
        COALESCE(NULLIF(hometeamyellowcards, '')::NUMERIC::INTEGER, 0) +
        COALESCE(NULLIF(awayteamyellowcards, '')::NUMERIC::INTEGER, 0) AS total_cards,

        -- Excitement score calculation
        (CAST(fulltimehometeamgoals AS INTEGER) + CAST(fulltimeawayteamgoals AS INTEGER)) * 2 +
        (CAST(hometeamshots AS REAL) + CAST(awayteamshots AS REAL)) * 0.1 +
        CASE WHEN ABS(CAST(fulltimehometeamgoals AS INTEGER) - CAST(fulltimeawayteamgoals AS INTEGER)) <= 1 THEN 3 ELSE 0 END +
        (COALESCE(NULLIF(hometeamyellowcards, '')::NUMERIC::INTEGER, 0) +
         COALESCE(NULLIF(awayteamyellowcards, '')::NUMERIC::INTEGER, 0)) * 0.5 AS excitement_score
    FROM epl_cleaned_partial_explored_data
    WHERE fulltimehometeamgoals IS NOT NULL AND fulltimeawayteamgoals IS NOT NULL
)
SELECT
    'High Value Match Characteristics' AS analysis,
    ROUND(AVG(CASE WHEN excitement_score > 8 THEN total_goals END)::NUMERIC, 1) AS high_excitement_avg_goals,
    ROUND(AVG(CASE WHEN excitement_score <= 8 THEN total_goals END)::NUMERIC, 1) AS normal_match_avg_goals,
    ROUND(AVG(CASE WHEN excitement_score > 8 THEN total_shots END)::NUMERIC, 1) AS high_excitement_avg_shots,
    COUNT(CASE WHEN excitement_score > 8 THEN 1 END) AS high_excitement_matches,
    ROUND(COUNT(CASE WHEN excitement_score > 8 THEN 1 END) * 100.0 / COUNT(*), 1) AS percentage_exciting_matches
FROM match_excitement;

-- Top 10 Most Exciting Matches (Run this separately)

WITH match_excitement AS (
    SELECT
        matchid,
        season,
        date,
        hometeam,
        awayteam,
        CAST(fulltimehometeamgoals AS INTEGER) + CAST(fulltimeawayteamgoals AS INTEGER) AS total_goals,
        CAST(hometeamshots AS REAL) + CAST(awayteamshots AS REAL) AS total_shots,
        ABS(CAST(fulltimehometeamgoals AS INTEGER) - CAST(fulltimeawayteamgoals AS INTEGER)) AS goal_margin,

        -- Handling possible non-numeric values for yellow cards
        COALESCE(NULLIF(hometeamyellowcards, '')::NUMERIC::INTEGER, 0) +
        COALESCE(NULLIF(awayteamyellowcards, '')::NUMERIC::INTEGER, 0) AS total_cards,

        -- Excitement score calculation
        (CAST(fulltimehometeamgoals AS INTEGER) + CAST(fulltimeawayteamgoals AS INTEGER)) * 2 +
        (CAST(hometeamshots AS REAL) + CAST(awayteamshots AS REAL)) * 0.1 +
        CASE WHEN ABS(CAST(fulltimehometeamgoals AS INTEGER) - CAST(fulltimeawayteamgoals AS INTEGER)) <= 1 THEN 3 ELSE 0 END +
        (COALESCE(NULLIF(hometeamyellowcards, '')::NUMERIC::INTEGER, 0) +
         COALESCE(NULLIF(awayteamyellowcards, '')::NUMERIC::INTEGER, 0)) * 0.5 AS excitement_score
    FROM epl_cleaned_partial_explored_data
    WHERE fulltimehometeamgoals IS NOT NULL AND fulltimeawayteamgoals IS NOT NULL
)
SELECT
    season,
    date,
    hometeam || ' vs ' || awayteam AS fixture,
    total_goals,
    goal_margin,
    total_shots,
    ROUND(excitement_score::NUMERIC, 1) AS excitement_score
FROM match_excitement
ORDER BY excitement_score DESC
LIMIT 10;